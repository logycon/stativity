//
//  Endomondo.h
//  Stativity
//
//  Created by Igor Nakshin on 8/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
		2:	'Cycling, sport',
		1:	'Cycling, transport',
		14:	'Fitness walking',
		15:	'Golfing',
		16:	'Hiking',
		9:	'Kayaking',
		10:	'Kite surfing',
		3:	'Mountain biking',
		17:	'Orienteering',
		19:	'Riding',
		5:	'Roller skiing',
		11:	'Rowing',
		0:	'Running',
		12:	'Sailing',
		4:	'Skating',
		6:	'Skiing, cross country',
		7:	'Skiing, downhill',
		8:	'Snowboarding',
		21:	'Spinning',
		20:	'Swimming',
		18:	'Walking',
		13:	'Windsurfing',
		22:	'Other',
		23:	'Aerobics',
		24:	'Badminton',
		25:	'Baseball',
		26:	'Basketball',
		27:	'Boxing',
		28:	'Climbing stairs',
		29:	'Cricket',
		30:	'Cross training',
		31:	'Dancing',
		32:	'Fencing',
		33:	'Football, American',
		34:	'Football, rugby',
		35:	'Football, soccer',
		49:	'Gymnastics',
		36:	'Handball',
		37:	'Hockey',
		48:	'Martial arts',
		38:	'Pilates',
		39:	'Polo',
		40:	'Scuba diving',
		41:	'Squash',
		42:	'Table tennis',
		43:	'Tennis',
		44:	'Volleyball, beach',
		45:	'Volleyball, indoor',
		46:	'Weight training',
		47:	'Yoga',
		50:	'Step counter'
*/

@interface Endomondo : NSObject 

+(Endomondo *) sharedInstance;

-(BOOL) connected;
-(void) connect;
-(void) disconnect;

-(NSString *) getToken;
-(void) setToken : (NSString *) token;

-(NSString *) connectUser : (NSString *) email withPassword : (NSString *) password;

-(int) getFitnessActivities : (NSString *) ofType;
-(int) getFitnessActivitiesAfter : (NSDate *) date ofType : (NSString *) type;
-(NSArray *) getActivityDetail : (NSString *) activityId;

+(NSString *) sportToActivityType : (NSNumber * ) sport;

@end
