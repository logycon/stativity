//
//  JSONActivityPathPoint.h
//  Stativity
//
//  Created by Igor Nakshin on 7/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityDetail.h"

@interface RunKeeperJSONActivityPathPoint : NSObject

@property (nonatomic, strong) NSNumber * timestamp;
@property (nonatomic, strong) NSNumber * altitude;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSString * type; // "start", "end", "gps", "pause", "resume", "manual"

-(NSDictionary *) fromDetail : (ActivityDetail *) detail andType : (NSString *) pointType;

@end
