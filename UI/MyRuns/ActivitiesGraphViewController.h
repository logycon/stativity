//
//  ActivitiesGraphViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 01/10/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface ActivitiesGraphViewController : StativityViewController
	<CPTPlotDataSource>

@property (nonatomic, strong) NSArray * graphData;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property (strong, nonatomic) IBOutlet UIButton *btnDone;

@end
