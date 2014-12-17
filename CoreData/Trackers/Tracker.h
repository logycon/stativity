//
//  Tracker.h
//  Stativity
//
//  Created by Igor Nakshin on 8/18/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tracker : NSObject

+(BOOL) connected;
+(int) getFitnessActivities : (NSString *) ofType;
+(int) getFitnessActivitiesAfter : (NSDate *) date ofType : (NSString *) type;
+(NSArray *) getActivityDetail : (NSString *) uri;
+(NSString *) getTrackerHashTag;
+(NSString *) getTrackerIconName;

@end
