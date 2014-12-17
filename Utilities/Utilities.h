//
//  Utilities.h
//  
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utilities : NSObject

+(UIViewController *) getActiveViewController;

+(BOOL) isTwitterAvailable;
+(BOOL) isSocialAvailable;

+ (void) startNetworkActivity;
+ (void) stopNetworkActivity;

// returns string containing time difference between date and now
// in the "ago" format, i.e. 5 minutes ago
// takes string version of date and date format of that version 
// as parameters
+(NSString *) getTimeFromNow : (NSString *) fromDate withFormat : (NSString *) format;
+(NSString *) getDateAsString : (NSDate *) date withFormat : (NSString *) format;

// returns string containing time difference between date and now
// in the "ago" format, i.e. 5 minutes ago
+ (NSString *) getTimeFromDate : (NSDate *) date;
+(int) getNumberOfDaysAgo : (NSDate *) date;

+(NSString *) fontFamily;
+(NSString *) fontFamilyRegular;

+(NSDate *) currentLocalTime;
+(NSDate *) currentLocalDate;
+(NSDate *) getEndOfToday;

+(NSDate *) getFirstDayOfWeek : (NSDate *) date;
+(NSDate *) getLastDayOfWeek : (NSDate *) date;

+(NSDate *) getFirstDayOfMonth : (NSDate *) date;
+(NSDate *) getLastDayOfMonth : (NSDate *) date;

+(NSDate *) getFirstDayOfYear : (NSDate *) date;

+(NSDate *) getFirstDayOfPreviousWeek:(NSDate *) date;
+(NSDate *) getLastDayOfPreviousWeek:(NSDate *) date;

+(NSDate *) getFirstDayOfPreviousMonth: (NSDate *) date;
+(NSDate *) getLastDayOfPreviousMonth : (NSDate *) date;

+(NSDate *) getFirstDayOfPreviousYear : (NSDate *) date;
+(NSDate *) getLastDayOfPreviousYear : (NSDate *) date;

+(NSDate *)dateFromRFC1123String:(NSString *)string;

+(NSString*) getSecondsAsDuration : (float) seconds;
+(NSString*) getSecondsAsDurationShort : (float) seconds;

+(NSString*)ordinalNumberFormat:(NSInteger)num;
            
+(NSDate *) startOfDateFromDateTime : (NSDate *) dateTime;
+(NSDate *) endOfDateFromDateTime : (NSDate *) dateTime;
+(BOOL) isDateInRange : (NSDate *) date : (NSDate *) from : (NSDate *) to;


@end
