//
//  DashboardItem.h
//  Stativity
//
//  Created by Igor Nakshin on 7/21/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DashboardItem : NSManagedObject

@property (nonatomic, retain) NSString * activityType;
@property (nonatomic, retain) NSNumber * defaultOrder;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * itemCategory;
@property (nonatomic, retain) NSString * itemCode;
@property (nonatomic, retain) NSNumber * itemOrder;
@property (nonatomic, retain) NSNumber * userSelected;

@end
