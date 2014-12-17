//
//  Garmin.h
//  Stativity
//
//  Created by Igor Nakshin on 9/1/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Garmin : NSObject 

+(Garmin *) sharedInstance;

-(NSString *) connectUser : (NSString *) email withPassword : (NSString *) password;
-(BOOL) connected;
-(void) disconnect;

-(int) getFitnessActivities : (NSString *) ofType;
-(int) getFitnessActivitiesAfter : (NSDate *) date ofType : (NSString *) type;
-(NSArray *) getActivityDetail : (NSString *) activityId;

@end
