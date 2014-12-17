//
//  RunKeeperData.h
//  Stativity
//
//  Created by Igor Nakshin on 6/30/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Activity.h"
#import "MBProgressHUD.h"
#import "ActivityFormatter.h"
#import "ActivitySegment.h"
#import "Goal.h"
#import "DistanceGoal.h"

@interface StativityData : NSObject <MBProgressHUDDelegate>

+(StativityData *) get;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void) removeAllActivities : (NSString *) ofType : (BOOL) showProgress withContext : (NSManagedObjectContext *) ctx;
-(void) removeAllActivities:(NSString *)ofType :(BOOL)showProgress withContext: (NSManagedObjectContext *) ctx;
-(void) userRemoveAllActivities;
// returns array of NSString id's of activities which were removed
-(NSArray *) removeActivitiesAfter : (NSDate *) date ofType : (NSString *) type withContext : (NSManagedObjectContext *) ctx;
-(void) removeActivitiesAfter : (NSDate *) date withContext : (NSManagedObjectContext *) ctx;
-(void) removeActivity:(NSString *)activityId withContext : (NSManagedObjectContext *) ctx;
-(void) removeActivityDetail : (NSString *) activityId withContext : (NSManagedObjectContext *) ctx;

-(int) getDetailCount : (NSString *) activityId;

// saves
-(int) saveActivities : (NSArray *) activities partial : (BOOL) isPartial ofType : (NSString *) type fromSource : (NSString *) source;
-(void) saveDetail : (NSString *) activityId detail : (NSArray *) detail;
-(void) updateProfile;
//-(void) saveSegments :(NSString *) activityId fromDetails :(NSArray *) fromDetail;


-(Activity *) fetchActivity : (NSString *) activityId;
-(Activity *) fetchActivity:(NSString *)activityId withContext : (NSManagedObjectContext *) ctx;

-(NSArray *) fetchAllActivities;
-(NSArray *) fetchActivities : (NSString *) type;
-(NSArray *) fetchActivitiesAfterDate : (NSDate *) date ofType : (NSString *) type;
-(NSArray *) fetchActivitiesBetweenStartDate : (NSDate *) startDate andEndDate: (NSDate *) endDate  ofType : (NSString *) type;
-(NSArray *) fetchActivityDetail : (NSString *) activityId;
-(NSArray *) fetchActivityDetail:(NSString *)activityId withContext : (NSManagedObjectContext *) ctx;
-(NSArray *) fetchAllSegments;

-(NSArray *) fetchSegments : (NSString *) activityId;
-(NSArray *) fetchSegments : (NSString *) activityId withContext : (NSManagedObjectContext *) ctx;
-(NSArray *) fetchSegments : (NSString *) activityId ofUnit : (NSString *) unit;

-(ActivitySegment *) fetchSegmentFromActivity : (NSString *) activityId 
	withTitle : (NSString *) title
	andUnits : (NSString *) units;
	
-(NSArray *) fetchSegmentsOfType : (NSString *) type withTitle : (NSString *) title andUnit : (NSString *) unit;
-(NSArray *) fetchSegmentsBetweenStartDate : (NSDate *) startDate andEndDate : (NSDate *) endDate 
	ofType : (NSString *) type
	withTitle : (NSString *) title
	andUnits : (NSString *) units;

-(Activity *) getFarthestActivityOfType : (NSString *) type;
-(Activity *) getFarthestActivityAfterDate : (NSDate *) date ofType : (NSString *) type;
-(Activity *) getFarthestActivityBetweenStartDate : (NSDate *) startDate andEndDate : (NSDate *) endDate ofType : (NSString *) type;

-(Activity *) getLongestActivityOfType : (NSString *) type;
-(Activity *) getLongestActivityBetweenStartDate : (NSDate *) startDate andEndDate : (NSDate *) endDate ofType : (NSString *) type;

-(ActivitySegment *) getFastestSegmentOfType : (NSString *) type withTitle : (NSString *) title andUnits : (NSString *) units;
-(ActivitySegment *) getFastestSegmentBetweenStartDate : (NSDate *) startDate andEndDate : (NSDate *) endDate 
	ofType : (NSString *) type
	withTitle : (NSString *) title
	andUnits : (NSString *) units;
	
-(NSArray *) getSegmentsBetweenStartDate : (NSDate *) startDate andEndDate : (NSDate *) endDate
   ofType : (NSString *) type
   withTitle : (NSString *) title
   andUnits : (NSString *) units;

-(Activity *) getLongestRunAfterDate : (NSDate *) date;
-(Activity *) getQuickestRunAfterDate : (NSDate *) date;
-(Activity *) getFastestRunAfterDate : (NSDate *) date;
-(Activity *) getLastRun;
-(Activity *) getLastActivity;
-(Activity *) getLastActivityOfType : (NSString *) type;
-(Activity *) getFirstActivity;
-(Activity *) getFirstActivityOfType : (NSString *) type;

// weekly things
-(ActivityFormatter *) getFarthestWeekOfType : (NSString *) type;
-(ActivityFormatter *) getFarthestWeekBetweenStartDate : (NSDate *) startDate andEndDate : (NSDate *) endDate ofType : (NSString *) type;

// goals
-(void) removeAllGoals : (NSManagedObjectContext *) ctx;
// i.e. type = Running and kind = Weekly/Monthly/Annual
-(Goal *) fetchCurrentGoalForActivity : (NSString *) activityType ofKind : (NSString *) kind; 
-(NSArray *) fetchGoalsForActivity : (NSString *) activityType ofKind : (NSString *) kind;

// DistanceGoal
-(DistanceGoal *) findDistanceGoalForActivity : (NSString *) activity
	andFrequency : (NSString *) frequency;
	
-(DistanceGoal *) findDistanceGoalForActivity : (NSString *) activity
	andFrequency : (NSString *) frequency
	noLaterThan : (NSDate *) date;
	
-(void) setDistanceGoalForActivity : (NSString *) activity
	andFrequency : (NSString *) frequency
	atDistance : (NSNumber *) distance
	andUnits : (NSString *) units;


// post
-(void) postActivities;

// Dashboard Items
-(void) removeAllDashboardItems : (NSManagedObjectContext *) ctx;
-(NSUInteger) getNumberOfDashboardItems;
-(NSArray *) fetchDashboardItemsWithCode : (NSString *) itemCode;
-(NSArray *) fetchDashboardItemsForActivity : (NSString *) activityType;
-(NSArray *) fetchSelectedDashboardItemsForActivity : (NSString*) activityType;
-(NSArray *) fetchUnselectedDashboardItemsForActivity : (NSString *) activityType;
-(void) createDashboardItems;
-(void) updateDashboardItems;
-(void) selectDashboardItems : (NSArray *) itemCodes forActivity : (NSString *) activityType;
-(void) deselectDashboardItem : (NSString *) itemCode forActivity : (NSString *) activityType;
-(void) updateItemOrders : (NSArray *) formatters forActivity : (NSString *) activityType;



@end
