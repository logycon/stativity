//
//  TrainingPeaksExporter.h
//  Stativity
//
//  Created by Igor Nakshin on 10/30/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TrainingPeaksExporter : NSObject

-(void) sendActivityWithID : (NSString *) activityId;

@end
