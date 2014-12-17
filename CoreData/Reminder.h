//
//  Reminder.h
//  Stativity
//
//  Created by Igor Nakshin on 8/24/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reminder : NSObject

+(void) updateReminder;
+(void) showSample;
+(NSString *) getNextReminderDate;

@end
