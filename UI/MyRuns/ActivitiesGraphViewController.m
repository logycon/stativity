//
//  ActivitiesGraphViewController.m
//  Stativity
//
//  Created by Igor Nakshin on 01/10/2012.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import "ActivitiesGraphViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "CPTColor.h"
#import "CPTFill.h"
#import "CPTGradient.h"
#import "CPTBarPlot.h"
#import "GraphPoint.h"

@interface ActivitiesGraphViewController ()

@end

static const NSTimeInterval oneDay = 24 * 60 * 60;

@implementation ActivitiesGraphViewController

@synthesize graphView;
@synthesize graphData;
@synthesize btnDone;

-(void) viewDidAppear:(BOOL)animated {
	[self configureBars];
	[btnDone setFrame : CGRectMake(415, 10, 56, 33)];
	btnDone.hidden = NO;
}

-(void) configureBars {
    CGRect bounds = self.graphView.bounds;
	CPTGraph * graph = [[CPTXYGraph alloc] initWithFrame: self.graphView.bounds];
	self.graphView.hostedGraph = graph;
	self.graphView.allowPinchScaling = YES;
	//[graph applyTheme: [CPTTheme themeNamed:kCPTDarkGradientTheme]];
	graph.borderColor = [UIColor whiteColor].CGColor;
    
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = round(bounds.size.height / (CGFloat)20.0);
	
	// title
	/*
	graph.title = @"Activities";
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = round(bounds.size.height / (CGFloat)20.0);
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CGPointMake( 0.0f, round(bounds.size.height / (CGFloat)18.0) ); // Ensure that title displacement falls on an integral pixel
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	*/
	
	// padding
	
	//CGFloat boundsPadding = round(bounds.size.width / (CGFloat)20.0); // Ensure that padding falls on an integral pixel
    //graph.paddingLeft = boundsPadding;
    //if ( graph.titleDisplacement.y > 0.0 ) {
    //    graph.paddingTop = graph.titleDisplacement.y * 2;
   // }
   // else {
    //    graph.paddingTop = boundsPadding;
   // }
	graph.borderColor = [UIColor redColor].CGColor;
    //graph.paddingRight  = 30; //boundsPadding;
    //graph.paddingBottom = 30; //boundsPadding;
	//graph.plotAreaFrame.paddingTop += 30;
	//graph.plotAreaFrame.paddingLeft += 30;
	//graph.plotAreaFrame.paddingRight += 30;

	//graph.plotAreaFrame.paddingBottom = 10;
	//graph.plotAreaFrame.paddingLeft = 10;
	
	graph.paddingBottom = 50;
	graph.paddingTop = 10;
	graph.paddingRight = 10;
	graph.paddingLeft = 10;
	
	graph.plotAreaFrame.paddingBottom = 50;
	graph.plotAreaFrame.paddingLeft = 20;
	graph.plotAreaFrame.paddingRight = 20;
	graph.plotAreaFrame.paddingTop = 20;

    // Add plot space for bar charts
    CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
	int numBars = [self.graphData count];
	
    barPlotSpace.xRange = [CPTPlotRange
		plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(numBars)];
		
    barPlotSpace.yRange = [CPTPlotRange
		plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(11.0f)];
		
    [graph addPlotSpace:barPlotSpace];

    // Create grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1.0f;
    majorGridLineStyle.lineColor = [[CPTColor grayColor] colorWithAlphaComponent:0.75];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 1.0f;
    minorGridLineStyle.lineColor = [[CPTColor grayColor] colorWithAlphaComponent:0.25];

    // Create axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	
	GraphPoint * firstPoint = [self.graphData objectAtIndex: 0];
	NSDate * firstDate = [firstPoint.data objectForKey: @"from"];
	CPTXYAxis * x = axisSet.xAxis;
    x.majorIntervalLength   =  CPTDecimalFromDouble(1); //CPTDecimalFromDouble(oneDay);
    x.minorTicksPerInterval = 0;
	x.majorGridLineStyle = majorGridLineStyle;
	x.minorGridLineStyle = minorGridLineStyle;
	x.axisLineStyle      = nil;
	x.majorTickLineStyle = nil;
	x.minorTickLineStyle = nil;
	x.labelOffset        = 10.0;
	x.labelRotation = M_PI / 2;
	
	
    
	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //dateFormatter.dateStyle = kCFDateFormatterShortStyle;
	[dateFormatter setDateFormat: @"MM/dd"];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = firstDate;
    x.labelFormatter = timeFormatter;
	
	/*
    CPTXYAxis *x          = axisSet.xAxis;
	x.majorIntervalLength         = CPTDecimalFromInteger(1);
	x.minorTicksPerInterval       = 0;
	//x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-0.5);

	x.majorGridLineStyle = majorGridLineStyle;
	x.minorGridLineStyle = minorGridLineStyle;
	x.axisLineStyle      = nil;
	x.majorTickLineStyle = nil;
	x.minorTickLineStyle = nil;
	x.labelOffset        = 10.0;
	//x.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
	//x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.5f) length:CPTDecimalFromFloat(10.0f)];
	//x.title       = @"Date";
	//x.titleOffset = 0.0f;
	//x.titleLocation = CPTDecimalFromInteger(55);
	*/
	
	
	
	x.plotSpace = barPlotSpace;
	
	
 
    CPTXYAxis *y = axisSet.yAxis;
	y.majorIntervalLength         = CPTDecimalFromInteger(1);
	y.minorTicksPerInterval       = 0;
	y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
	y.preferredNumberOfMajorTicks = 8;
	y.majorGridLineStyle          = majorGridLineStyle;
	y.minorGridLineStyle          = minorGridLineStyle;
	y.axisLineStyle               = nil;
	y.majorTickLineStyle          = nil;
	y.minorTickLineStyle          = nil;
	y.labelOffset                 = 10.0;
	y.labelRotation               = M_PI / 2;
	//y.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.5f) length:CPTDecimalFromFloat(10.0f)];
	//y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
	y.title       = @"Distance";
	y.titleOffset = 2;
	y.titleLocation = CPTDecimalFromInteger(5);
	y.plotSpace = barPlotSpace;
    

    // Set axes
    graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];

    // Create a bar line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor grayColor];

    // Create first bar plot
    CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
    barPlot.lineStyle       = barLineStyle;
    barPlot.fill            = [CPTFill fillWithColor:
		[CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.5f alpha:0.5f]];
    barPlot.barBasesVary    = YES;
    barPlot.barWidth        = CPTDecimalFromFloat(0.75f); // bar is 75% of the available space
    barPlot.barCornerRadius = 0;
    barPlot.barsAreHorizontal = NO;

    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color   = [CPTColor redColor];
    barPlot.labelTextStyle = whiteTextStyle;

    barPlot.delegate   = self;
    barPlot.dataSource = self;
    barPlot.identifier = @"Distance";

    [graph addPlot:barPlot toPlotSpace:barPlotSpace];

/*
    // Create second bar plot
    CPTBarPlot *barPlot2 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];

    barPlot2.lineStyle    = barLineStyle;
    barPlot2.fill         = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0f green:1.0f blue:0.5f alpha:0.5f]];
    barPlot2.barBasesVary = YES;

    barPlot2.barWidth = CPTDecimalFromFloat(1.0f); // bar is full (100%) width
//	barPlot2.barOffset = -0.125f; // shifted left by 12.5%
    barPlot2.barCornerRadius = 2.0f;
#if HORIZONTAL
    barPlot2.barsAreHorizontal = YES;
#else
    barPlot2.barsAreHorizontal = NO;
#endif
    barPlot2.delegate   = self;
    barPlot2.dataSource = self;
    barPlot2.identifier = @"Bar Plot 2";

    [graph addPlot:barPlot2 toPlotSpace:barPlotSpace];
*/
    // Add legend
	/*
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfRows    = 2;
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:0.15]];
    theLegend.borderLineStyle = barLineStyle;
    theLegend.cornerRadius    = 10.0;
    theLegend.swatchSize      = CGSizeMake(20.0, 20.0);
    whiteTextStyle.fontSize   = 16.0;
    theLegend.textStyle       = whiteTextStyle;
    theLegend.rowMargin       = 10.0;
    theLegend.paddingLeft     = 12.0;
    theLegend.paddingTop      = 12.0;
    theLegend.paddingRight    = 12.0;
    theLegend.paddingBottom   = 12.0;

#if HORIZONTAL
    NSArray *plotPoint = [NSArray arrayWithObjects:[NSNumber numberWithInteger:95], [NSNumber numberWithInteger:0], nil];
#else
    NSArray *plotPoint = [NSArray arrayWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:95], nil];
#endif
    CPTPlotSpaceAnnotation *legendAnnotation = [[CPTPlotSpaceAnnotation alloc]
		initWithPlotSpace:barPlotSpace anchorPlotPoint:plotPoint];
    legendAnnotation.contentLayer = theLegend;

#if HORIZONTAL
    legendAnnotation.contentAnchorPoint = CGPointMake(1.0, 0.0);
#else
    legendAnnotation.contentAnchorPoint = CGPointMake(0.0, 1.0);
#endif
    [graph.plotAreaFrame.plotArea addAnnotation:legendAnnotation];
	*/
}


-(void) configureBarGraph {
	CPTGraph * graph = [[CPTXYGraph alloc] initWithFrame: self.graphView.bounds];
	self.graphView.hostedGraph = graph;
	
	// create plot space
	CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
    [graph addPlotSpace:barPlotSpace];
	
	// Create a bar line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor redColor];
	
	// create bar plot
	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
	barPlot.identifier = @"Distance";
	barPlot.lineStyle = barLineStyle;
   
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color   = [CPTColor whiteColor];
    barPlot.labelTextStyle = whiteTextStyle;

    barPlot.delegate   = self;
    barPlot.dataSource = self;
    barPlot.identifier = @"Distance";

    [graph addPlot:barPlot toPlotSpace:barPlotSpace];
	
}



#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return [self.graphData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	NSNumber *num = nil;
	// can check plot.identifier
	//NSLog(@"%i", index);
	int dataIndex = index;
	GraphPoint * point = [self.graphData objectAtIndex: dataIndex];
	
	switch(fieldEnum) {
		case CPTBarPlotFieldBarLocation : {
			num = [NSNumber numberWithInt : index];
			break;
		}
		case CPTBarPlotFieldBarTip : {
			num = [point.data objectForKey: @"YValue"];
			NSLog(@"%i = %@", index, num);
			break;
		}
		case CPTBarPlotFieldBarBase : {
			num = [NSNumber numberWithInt: 0];
			break;
		}
	
	}
	
	return num;

}



-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
	// 1 - Define label text style
	static CPTMutableTextStyle *labelText = nil;
	if (!labelText) {
		labelText= [[CPTMutableTextStyle alloc] init];
		labelText.color = [CPTColor grayColor];
	}
	
	GraphPoint * point = [self.graphData objectAtIndex: index];
	NSNumber * distance = [point.data objectForKey: @"YValue"];
	
	// 2 - Calculate portfolio total value
	//NSDecimalNumber *portfolioSum = [NSDecimalNumber zero];
	
	//for (NSDecimalNumber *price in [[CPDStockPriceStore sharedInstance] dailyPortfolioPrices]) {
	//	portfolioSum = [portfolioSum decimalNumberByAdding:price];
	//}
	// 3 - Calculate percentage value
	//NSDecimalNumber *price = [[[CPDStockPriceStore sharedInstance] dailyPortfolioPrices] objectAtIndex:index];
	//NSDecimalNumber *percent = [price decimalNumberByDividingBy:portfolioSum];
	// 4 - Set up display label
	//NSString *labelValue = [NSString stringWithFormat:@"$%0.2f USD (%0.1f %%)", [price floatValue], ([percent floatValue] * 100.0f)];
	// 5 - Create and return layer with label text
	
	NSString * labelValue = @"";
	if ([distance floatValue] > 0) {
		labelValue = [NSString stringWithFormat: @"%.02f", [distance floatValue]];
	}

	return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
	//if (index < [[[CPDStockPriceStore sharedInstance] tickerSymbols] count]) {
		//return [[[CPDStockPriceStore sharedInstance] tickerSymbols] objectAtIndex:index];
		return [NSString stringWithFormat: @"Legend %i", index];
	//}
	//return @"N/A";
}


- (IBAction)btnDoneClick:(id)sender {
	[self dismissModalViewControllerAnimated:YES];

}

-(BOOL) shouldAutorotate {
	return YES;
}

/*
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	NSLog(@"%d", toInterfaceOrientation);
	
	if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
		(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)){
		// ok
	}
	else {
		[self dismissModalViewControllerAnimated:YES];
	}
}*/

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
		(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)){
		return YES;
	}
	else {
		return NO;
	}

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidUnload {
	[self setGraphView:nil];
	[self setBtnDone:nil];
	[super viewDidUnload];
}
@end
