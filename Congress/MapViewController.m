//
//  MapViewController.m
//  Congress
//
//  Created by points Panchenko on 9/20/15.
//  Copyright © 2015 points Panchenko. All rights reserved.
//

#import "MapViewController.h"
#import "UIAlertController+Blocks.h"

@interface MapViewController ()

@end

@implementation MapViewController

MKPolygon *myPolygon;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.progress = [[Progress alloc] init];
    
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
    [self.hud addGestureRecognizer:_HUDSingleTap];
    self.mapView.delegate = self;
    [self fetchMap];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    return _lineView;
}


-(void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    
    [Progress dismissGlobalHUD];
    
    [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Error Loading The Map" cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
        
    }];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
    
    if ([self.legislator.party isEqualToString:@"R"]) {
        polygonView.strokeColor = [UIColor redColor];
    }
    else if ([self.legislator.party isEqualToString:@"D"]) {
        polygonView.strokeColor = [UIColor blueColor];
    }
    else {
        polygonView.strokeColor = [UIColor grayColor];
    }
    
    polygonView.fillColor = [polygonView.strokeColor colorWithAlphaComponent:0.2];

    return polygonView;
    
    }

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    
    [Progress dismissGlobalHUD];
}

- (void)fetchMap {
    
    NSString *urlString;
    BOOL stateMap = NO;
    
    if ([self.legislator.district isKindOfClass:[NSNull class]] || [self.legislator.district intValue] == 0) {
        urlString = [NSString stringWithFormat:@"https://raw.githubusercontent.com/unitedstates/districts/gh-pages/states/%@/shape.geojson",[self.legislator.state uppercaseString]];
        stateMap = YES;
    }
    else {
        urlString = [NSString stringWithFormat:@"https://raw.githubusercontent.com/unitedstates/districts/gh-pages/cds/2012/%@-%d/shape.geojson",[self.legislator.state uppercaseString],[self.legislator.district intValue]];
    }
    
    [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [Progress dismissGlobalHUD];
                
                [UIAlertController showAlertInViewController:self withTitle:@"Error" message:[error localizedDescription] cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                    
                }];
            });
        }
        else {

            // convert to an object
            NSError *jsonError;
            NSDictionary *dictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                                        options:NSJSONReadingAllowFragments
                                                                                          error: &jsonError];
            
            NSArray *coordinates = dictionary[@"coordinates"];
            NSArray *c2;
            
            int numPoints = 0;
            
            for (int i = 0; i < [coordinates count]; i++) {
                c2 = coordinates[i][0];
                
                numPoints += (int)[c2 count];
            }
            
            CLLocationCoordinate2D points[numPoints];
            CLLocation *location;
            numPoints = 0;
            
            for (int i = 0; i < [coordinates count]; i++) {
                c2 = coordinates[i][0];
                
                for (int j = 0; j < [c2 count]; j++) {
                    
                    location = [[CLLocation alloc] initWithLatitude:[c2[j][1] doubleValue] longitude:[c2[j][0] doubleValue]];
                    
                    points[numPoints] = CLLocationCoordinate2DMake([c2[j][1] doubleValue],[c2[j][0] doubleValue] );
                    
                    numPoints++;
                }
            }
            
            myPolygon = [MKPolygon polygonWithCoordinates:points count:numPoints];
                        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.mapView.region = MKCoordinateRegionForMapRect([myPolygon boundingMapRect]);
                
                if (!stateMap && ![self.legislator.state isEqualToString:@"AK"]) {
                    [self.mapView addOverlay:myPolygon];
                }
            });
        }
    }] resume];
}

@end
