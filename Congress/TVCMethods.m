//
//  TVCMethods.m
//  Congress
//
//  Created by ERIC on 7/19/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "TVCMethods.h"


@implementation TVCMethods


- (void)didChangePreferredContentSize:(NSNotification *)notification; {
    [self.tableView reloadData];
}

+(NSString *)getStateName:(NSString *)abbreviation {
    
    States *stateManager = [States sharedInstance];
    
    return stateManager.stateDict[abbreviation];
}

+ (NSString *)getTitle:(NSString*)abbreviation {
    States *stateManager = [States sharedInstance];
    
    if (stateManager.terrDict[abbreviation] != nil)
        return @"Del";
    
    return @"Rep";
}

+(NSString *) addSuffixToNumber:(int) number
{
    NSString *suffix;
    int ones = number % 10;
    int tens = (number/10) % 10;
    
    if (tens ==1) {
        suffix = @"th";
    } else if (ones ==1){
        suffix = @"st";
    } else if (ones ==2){
        suffix = @"nd";
    } else if (ones ==3){
        suffix = @"rd";
    } else {
        suffix = @"th";
    }
    
    return [NSString stringWithFormat:@"%d%@", number, suffix];
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr {
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }
                                         if (error == nil) {
                                             result = data;
                                         }
                                         dispatch_semaphore_signal(sem);
                                     }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return result;
}

+ (NSString *)getAmendmentURL:(NSString*)bill_id chamber:(NSString*)chamber {
    
    NSArray *array = [bill_id componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    NSString *number = array[0];

    for (int i = 0; i < [number length]; i++) {
        if (isdigit([number characterAtIndex:i])) {
            number = [number substringFromIndex:i];
            break;
        }
    }

    return [NSString stringWithFormat:@"https://www.congress.gov/bill/%@-congress/%@-bill/%@/amendments",
                        [TVCMethods addSuffixToNumber:[array[1] intValue]],chamber,number];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

/*
+ (NSString *)getAmendmentNumber:(NSData*)data response:(NSURLResponse*)response roll_id:(NSString*)roll_id {
    
    BOOL found = false;
    NSString *amendNumber;
    
    NSString *contentType = nil;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
        contentType = headers[@"Content-Type"];
    }
    
    HTMLDocument *home = [HTMLDocument documentWithData:data contentTypeHeader:contentType];
    NSArray *array = [home nodesMatchingSelector:@"span"];
    NSString *string;
    NSDictionary *dict;
    NSArray *array2 = [roll_id componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    
    roll_id = array2[0];
    
    for (int i = 0; i < [roll_id length]; i++) {
        if (isdigit([roll_id characterAtIndex:i])) {
            roll_id = [roll_id substringFromIndex:i];
            break;
        }
    }
    
    for (HTMLElement *element in array) {
        
        dict = element.attributes;
        
        if (!found && [dict[@"class"] isEqualToString:@"result-heading amendment-heading"]) {
            amendNumber = [[element.textContent substringWithRange: NSMakeRange(0, [element.textContent rangeOfString: @"—"].location)] stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            for (int i = 0; i < [amendNumber length]; i++) {
                if (isdigit([amendNumber characterAtIndex:i])) {
                    amendNumber = [amendNumber substringFromIndex:i];
                    break;
                }
            }            
        }
        
        else if ([dict[@"class"] isEqualToString:@"result-item"]) {
            
            string = [element.textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if ([[string substringToIndex:13] isEqualToString:@"Latest Action"]
                
                && [[[string substringFromIndex:15] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] localizedCaseInsensitiveContainsString:[NSString stringWithFormat:@"(Roll no. %@)",roll_id]]) {
                found = true;
                break;
            }
            
        }
    }
    

    if (found) {
        return amendNumber;
    }
    
    return @"";
}
*/
@end
