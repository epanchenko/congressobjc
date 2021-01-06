//
//  MapViewController.h
//  Congress
//
//  Created by Eric Panchenko on 9/20/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Legislator.h"
#import "Progress.h"
#import "SlideNavigationController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong,nonatomic) Legislator *legislator;
@property (nonatomic,strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic,strong) MKOverlayView *lineView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;

@end
