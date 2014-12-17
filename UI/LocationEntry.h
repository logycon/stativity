//
//  LocationEntry.h
//  Stativity
//
//  Created by Igor Nakshin on 6/20/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationEntry : NSObject

@property (nonatomic, strong) NSDate * timeStamp;
@property (nonatomic, strong) CLLocation * prevLocation;
@property (nonatomic, strong) CLLocation * curLocation;


-(CLLocationDistance) metersFromPrevious;

@end
