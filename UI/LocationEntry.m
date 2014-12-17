//
//  LocationEntry.m
//  Stativity
//
//  Created by Igor Nakshin on 6/20/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "LocationEntry.h"

@implementation LocationEntry

@synthesize timeStamp;
@synthesize prevLocation;
@synthesize curLocation;

-(CLLocationDistance) metersFromPrevious {
	return [curLocation distanceFromLocation: prevLocation];
};

@end
