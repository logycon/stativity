//
//  RunKeeper.h
//  RunKeeperTest
//
//  Created by Igor Nakshin on 7/14/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunKeeper : NSObject <UIAlertViewDelegate>

+(RunKeeper *) sharedInstance;

-(void) handleOpenURL : (NSURL *) url;
-(void) connect;
-(void) disconnect;
-(BOOL) connected;

-(NSString *) getToken;
-(void) setToken : (NSString *) token;

-(BOOL) getUserProfile;
-(int) getFitnessActivities : (NSString *) ofType;
-(int) getFitnessActivitiesAfter : (NSDate *) date ofType : (NSString *) type;
-(NSArray *) getActivityDetail : (NSString *) uri;

-(void) postNewActivity : (NSString *) acivityId;

@end
