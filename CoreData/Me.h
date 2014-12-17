//
//  NikePlus.h
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunKeeper.h"

typedef enum {
	Today = 1,
	ThisWeek = 2,
	ThisMonth = 3,
	ThisYear = 4,
	AllTime = 5,
	LastWeek = 6,
	LastMonth = 7,
	LastYear = 8,
	Days7 = 9,
	Days14 = 10,
	Days30 = 11,
	Days60 = 12,
	Days90 = 13
} Timeframe;


@interface Me 

+(NSString *) getMyID;
+(void) setMyID : (NSString *) theID;

+(BOOL) getElite;
+(void) setElite : (BOOL) elite;

+(NSString *) getMyUnits;
+(void) setMyUnits : (NSString *) theUnits;

+(int) getFirstDayOfWeek;
+(void) setFirstDayOfWeek : (int) theDay;

+(NSString *) getTotalKM;
+(void) setTotalKM : (NSNumber *) theKM;

+(NSString *) getTotalRuns;
+(void) setTotalRuns : (NSNumber *) theRuns;

+(NSString *) getMyTimeframe;
+(void) setMyTimeframe : (NSString *) theTimeframe;

+(Timeframe) toTimeframe : (NSString *) theTimeframe;
+(NSString *) fromTimeframe : (Timeframe) theTimeframe;

+(Timeframe) getTimeframe;
+(void) setTimeframe : (Timeframe) theTimeframe;

+(UIColor *) getUIColor;
+(void) refreshUIColor;
+(UIColor *) getUIColorWithAlpha : (float) alpha;
+(UIColor *) getTabBarColor;
+(UIColor *) getTextColor;

+(NSDate *) getTimeframeStart;
+(NSDate *) getTimeframeEnd;
+(NSDate *) getPrevTimeframeStart;
+(NSDate *) getPrevTimeframeEnd;
+(NSString *) getTimeframeName;
+(NSString *) getTimeFrameFrequency;
+(NSString *) getPrevTimeframeName;
+(NSString *) getTimeframeText;
+(NSString *) getTimeFrameProperCased;
+(BOOL) isTimeframeThis;

+(NSString *) getHomeScreenImageName;
+(void) setHomeScreenImage : (NSString *) path;
+(NSNumber *) getHomeImageOpacity;
+(void) setHomeImageOpacity : (NSNumber *) opacity;

@end
