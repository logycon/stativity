//
//  DistanceGoal.h
//  Stativity
//
//  Created by Igor Nakshin on 8/21/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DistanceGoal : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * activityType;
@property (nonatomic, retain) NSString * frequency;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * units;

@end
