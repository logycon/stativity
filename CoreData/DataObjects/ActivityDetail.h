//
//  ActivityDetail.h
//  Stativity
//
//  Created by Igor Nakshin on 8/9/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ActivityDetail : NSManagedObject

@property (nonatomic, retain) NSString * activityId;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * heartRate;

-(void) fromDict:(NSDictionary *)dict;

@end
