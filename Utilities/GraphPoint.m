//
//  GraphPoint.m
//  Stativity
//
//  Created by Igor Nakshin on 04/10/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "GraphPoint.h"

@implementation GraphPoint

@synthesize data;

-(GraphPoint *) init {
	self = [super init];
	self.data = [[NSMutableDictionary alloc] init];
	return self;
}

@end
