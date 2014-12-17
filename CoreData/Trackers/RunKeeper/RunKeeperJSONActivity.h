//
//  JSONActivity.h
//  Stativity
//
//  Created by Igor Nakshin on 7/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Activity.h"

@interface RunKeeperJSONActivity : NSObject

@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * equipment;
@property (nonatomic, strong) NSString * start_time;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSMutableArray * path;
@property (nonatomic, strong) NSString * post_to_facebook;
@property (nonatomic, strong) NSString * post_to_twitter;

-(NSDictionary *) fromActivity : (NSString *) activityId;

@end
