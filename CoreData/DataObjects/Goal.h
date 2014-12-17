//
//  Goal.h
//  Stativity
//
//  Created by Igor Nakshin on 8/21/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Goal : NSManagedObject

@property (nonatomic, retain) NSString * activityType;
@property (nonatomic, retain) NSString * bestActivityId;
@property (nonatomic, retain) NSNumber * goalDistance;
@property (nonatomic, retain) NSNumber * goalDuration;
@property (nonatomic, retain) NSNumber * goalMeters;
@property (nonatomic, retain) NSString * goalUnits;
@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) NSDate * created;

@end
