//
//  NSDate+Time.h
//  
//
//  Created by Eric Panchenko on 6/17/16.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (Time)

-(NSDate *) dateWithHour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second;
@end
