//
//  RunKeeperData.m
//  Stativity
//
//  Created by Igor Nakshin on 6/30/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "StativityData.h"
#import "Activity.h"
#import "ActivityDetail.h"
#import "RunKeeper.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "ActivitySegment.h"
#import "ActivityWeek.h"
#import "Me.h"
#import "Goal.h"
#import "DashboardItem.h"
#import "DashboardItemFormatter.h"
#import "Endomondo.h"

#define FT_SAVE_MOC(_ft_moc) \
do { \
  NSError* _ft_save_error; \
  if(![_ft_moc save:&_ft_save_error]) { \
    NSLog(@"Failed to save to data store: %@", [_ft_save_error localizedDescription]); \
    NSArray* _ft_detailedErrors = [[_ft_save_error userInfo] objectForKey:NSDetailedErrorsKey]; \
    if(_ft_detailedErrors != nil && [_ft_detailedErrors count] > 0) { \
      for(NSError* _ft_detailedError in _ft_detailedErrors) { \
        NSLog(@"DetailedError: %@", [_ft_detailedError userInfo]); \
      } \
    } \
    else { \
      NSLog(@"%@", [_ft_save_error userInfo]); \
    } \
  } \
} while(0);

@implementation StativityData

StativityData * _appData;

int totalItems = 0;
int currentItem = 0;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

+(StativityData *) get {
	if (_appData == nil) {
		_appData = [[StativityData alloc] init];
	}
	return _appData;
}

-(void) updateProfile {
	RunKeeper * rk = [RunKeeper sharedInstance];
	[rk getUserProfile];
}

-(void) saveDetail:(NSString *)activityId detail : (NSArray *)detail {
	NSManagedObjectContext * ctx = [[NSManagedObjectContext alloc] init];
	[ctx setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
	
	[self removeActivityDetail : activityId withContext: ctx];
	
	UIViewController * activeController = [Utilities getActiveViewController];
	MBProgressHUD * HUD = [MBProgressHUD HUDForView: activeController.view];
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	HUD.labelText = @"Saving Details...";
	
	int totalItems = [detail count];
	for(int i = 0; i < [detail count]; i++) {
		NSDictionary * dict = [detail objectAtIndex: i];
		
		float progress = (1.0 * i) / totalItems;
		NSNumber * pct = [NSNumber numberWithFloat: progress * 100];
		NSString * strProgress = [NSString  stringWithFormat : @"Saving Details...\n%d%@", [pct intValue], @"%"];
		HUD.labelText = strProgress;
		HUD.progress = progress;
		
		ActivityDetail * det = [NSEntityDescription 
					insertNewObjectForEntityForName: @"ActivityDetail" 
					inManagedObjectContext: ctx];
				det.activityId = activityId;
				[det fromDict: dict];
				
		
		FT_SAVE_MOC(ctx)
	}
	// post notification
	[[NSNotificationCenter defaultCenter] 
			postNotificationName:@"detailLoaded" 
			object:self];

}

-(NSArray *) getActivityDetail : (NSString *) uri {
	NSArray * retval = nil;
	RunKeeper * rk = [RunKeeper sharedInstance];
	if ([rk connected]) {
		retval = [rk getActivityDetail: uri];
	}
	else {
		Endomondo * en = [Endomondo sharedInstance];
		if ([en connected]) {
			retval = [en getActivityDetail: uri];
		}
	}
	return retval;
}

// inside a thread!
-(int) saveActivities:(NSArray *)activities partial:(BOOL)isPartial ofType:(NSString *)type fromSource:(NSString *)source {
	int retval = 0;
	
	// runkeeper
	if ([source isEqualToString: @"RunKeeper"]) {
		retval = [self saveRunkeeperActivities: activities
			partial: isPartial ofType: type fromSource: source];
	}
	
	// endomondo
	if ([source isEqualToString: @"Endomondo"]) {
		retval = [self saveEndomondoActivities: activities 
			partial:isPartial ofType: type fromSource:source];
	}
	
	return retval;
}

-(int) saveEndomondoActivities:(NSArray *)activities partial:(BOOL)isPartial ofType:(NSString *)type fromSource:(NSString *)source {
	int retval = 0;
	
	NSManagedObjectContext * _context = [[NSManagedObjectContext alloc] init];
	[_context setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
	
	if (!isPartial) {
		[self removeAllActivities: type : NO withContext: _context];
	}
	
	NSMutableArray * list = [activities mutableCopy];
	// remove items which are found in activities from the list
	for(int i = [list count] - 1; i >= 0; i--) {
		NSDictionary * dict = [list objectAtIndex: i];
		NSString * activityId = [NSString stringWithFormat: @"%d", [[dict objectForKey: @"id"] intValue]];
		Activity * activity = [self fetchActivity: activityId];
		if (activity != nil) {
			[list removeObject: dict];
		}
	}
	
	UIViewController * activeController = [Utilities getActiveViewController];
	MBProgressHUD * HUD = [MBProgressHUD HUDForView: activeController.view];
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	HUD.labelText = @"Saving Activities...";

	NSMutableArray * saveList = [[NSMutableArray alloc] init];
	
	// sort in start_time ascending order
	// endomondo date formatter here
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	[df setDateFormat: @"yyyy-MM-dd HH:mm:ss z"];
	[df setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: [NSTimeZone systemTimeZone].secondsFromGMT]];

	
	NSMutableArray * _activities = [activities mutableCopy];
	for(int i = 0; i < [_activities count]; i++) {
		NSDictionary * item = [_activities objectAtIndex:i];
		NSString * strDate = [item objectForKey: @"start_time"];
		NSDate * sortDate = [df dateFromString: strDate];
		[item setValue: sortDate forKey: @"sorter_date"];
	}
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sorter_date"  ascending:YES];
	activities = 
		[[_activities sortedArrayUsingDescriptors: [NSArray arrayWithObject: descriptor]] copy];
		
	totalItems = [activities count];
	int numberOfItemsToSave = 0;
	
	for(int i = 0; i < [activities count]; i++) {
		NSDictionary * dict = [activities objectAtIndex:i];
		NSString * activityType = [dict objectForKey: @"sport"];
		
		currentItem = i;
		float progress = (1.0 * currentItem + 1) / (totalItems + 1);
		NSNumber * pct = [NSNumber numberWithFloat: progress * 100.0];
		NSString * strProgress = [NSString  stringWithFormat : @"Saving Activities...\n%.1f%@", [pct floatValue], @"%"];
		HUD.labelText = strProgress;
		HUD.progress = progress;
		
		if ([type isEqualToString: @""] || [activityType isEqualToString: type]) {
			
			NSNumber * numActivityId = [NSNumber numberWithInt : [[dict objectForKey: @"id"] intValue]];
			NSString * activityId  = [numActivityId stringValue];
			Activity * existingRun = [self fetchActivity: activityId];
			if (existingRun == nil) {
				retval++;
				
				NSMutableArray * detail = [[self getActivityDetail: activityId] mutableCopy];
				
				NSNumber * total_calories = [dict objectForKey: @"calories"];
				NSNumber * min_altitude = [dict objectForKey: @"altitude_m_min"];
				NSNumber * max_altitude = [dict objectForKey: @"altitude_m_max"];
				NSNumber * climb = [NSNumber numberWithFloat: [max_altitude floatValue] - [min_altitude floatValue]];
				
				NSMutableDictionary * saveItem = [[NSMutableDictionary alloc] initWithCapacity:2];
				[saveItem setObject: dict forKey: @"activityDict"];
				numberOfItemsToSave++;
				if (!detail) detail = [[NSMutableArray alloc] init];
				[saveItem setObject: detail forKey : @"activityDetail"];
				numberOfItemsToSave += [detail count];
				[saveList addObject: saveItem];
				
				// save
				NSDictionary * activityDict = [saveItem objectForKey: @"activityDict"];
				NSArray * activityDetail = [saveItem objectForKey: @"activityDetail"];
							
				// add activity
				Activity * activity = [NSEntityDescription 
						insertNewObjectForEntityForName: @"Activity" 
						inManagedObjectContext: _context];
				[activity fromEndomondoDict: activityDict];
				activity.detailCount = [NSNumber numberWithInt: [activityDetail count]];
				activity.climb =[NSNumber numberWithFloat : [climb floatValue]];
				activity.total_calories = [NSNumber numberWithFloat: [total_calories floatValue]];
				activity.source = source;
				

				// save the calculations
				activity.avgAltitude = [NSNumber numberWithFloat: 0];
				activity.maxAltitude = [NSNumber numberWithFloat: 0];
				activity.minAltitude = [NSNumber numberWithFloat: 0];
				activity.stdevAltitude = [NSNumber numberWithFloat: 0];
				activity.averageGrade = [NSNumber numberWithFloat: 0];
				
				// save details for activity
				for(int j = 0; j < [activityDetail count]; j++) {
					currentItem ++;
					NSDictionary * detailDict = [activityDetail objectAtIndex: j];
					
					ActivityDetail * det = [NSEntityDescription 
						insertNewObjectForEntityForName: @"ActivityDetail" 
						inManagedObjectContext: _context];
					det.activityId = activity.id;
					[det fromDict: detailDict];
				}
	
				// delete segments
				NSArray * toDelete = [self fetchSegments: activity.id withContext : _context];
				for(int i = 0; i < [toDelete count]; i++) {
					ActivitySegment * seg = [toDelete objectAtIndex: i];
					[_context deleteObject: seg];
				}	
					
				FT_SAVE_MOC(_context) // need that to fetch details for segments		
								
				// calculate segments
				NSArray * details = [self fetchActivityDetail: activity.id withContext: _context];
				//NSArray * details = [self fetchActivityDetail: activity.id];
				[self saveSegmentsForActivity: activity fromDetails: details withContext : _context];
				
				FT_SAVE_MOC(_context)
				
			}
			else {
				//NSLog(@"found existing run - not adding");
			}
		}
	}
	
	// update colors
	[Me refreshUIColor];
	
	return retval;
}

-(int) saveRunkeeperActivities:(NSArray *)activities partial:(BOOL)isPartial ofType:(NSString *)type fromSource:(NSString *)source {
	int retval = 0;
	
	NSManagedObjectContext * _context = [[NSManagedObjectContext alloc] init];
	[_context setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
	
	if (!isPartial) {
		[self removeAllActivities: type : NO withContext: _context];
	}
	/*
	else {
		#if LITE 
			[self removeAllActivities: type : NO withContext: _context];
		#endif 
	}*/
	
	NSMutableArray * list = [activities mutableCopy];
	// remove items which are found in activities from the list
	for(int i = [list count] - 1; i >= 0; i--) {
		NSDictionary * dict = [list objectAtIndex: i];
		NSString * activityId = [NSString stringWithFormat: @"%d", [[dict objectForKey: @"id"] intValue]];
		Activity * activity = [self fetchActivity: activityId];
		if (activity != nil) {
			[list removeObject: dict];
		}
	}
	
	UIViewController * activeController = [Utilities getActiveViewController];
	MBProgressHUD * HUD = [MBProgressHUD HUDForView: activeController.view];
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	HUD.labelText = @"Saving Activities...";
	
	NSMutableArray * saveList = [[NSMutableArray alloc] init];
	
	// sort in start_time ascending order
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss"];  	
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSLocale *locale = [[NSLocale alloc]  initWithLocaleIdentifier:@"en_US_POSIX"];
	[dateFormatter setLocale: locale];
	
	NSMutableArray * _activities = [activities mutableCopy];
	for(int i = 0; i < [_activities count]; i++) {
		NSDictionary * item = [_activities objectAtIndex:i];
		NSString * strDate = [item objectForKey: @"start_time"];
		NSDate * sortDate = [dateFormatter dateFromString: strDate];
		[item setValue: sortDate forKey: @"sorter_date"];
	}
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sorter_date"  ascending:YES];
	activities = 
		[[_activities sortedArrayUsingDescriptors: [NSArray arrayWithObject: descriptor]] copy];
		
	#ifdef LITE
		
	
		// remove activities which are older than 30 days for lite version
		NSDate * cutoff = [[NSDate date] dateByAddingTimeInterval: -1 * 60 * 60 * 24 * 30];
		NSMutableArray * _temp = [[NSMutableArray alloc] init];
		for(int i = 0; i < [_activities count]; i++) {
			NSDictionary * item = [_activities objectAtIndex : i];
			NSDate * dt = [item objectForKey: @"sorter_date"];
			// if activity date is later than cutoff 
			if ([dt compare: cutoff] == NSOrderedDescending) {
				[_temp addObject: item];
			}
		}
		activities = [_temp copy];
	#endif
	
	totalItems = [activities count];
	int numberOfItemsToSave = 0;
		
	for(int i = 0; i < [activities count]; i++) {
		NSDictionary * dict = [activities objectAtIndex:i];
		NSString * activityType = [dict objectForKey: @"type"];
		
		currentItem = i;
		float progress = (1.0 * currentItem + 1) / (totalItems + 1);
		NSNumber * pct = [NSNumber numberWithFloat: progress * 100.0];
		NSString * strProgress = [NSString  stringWithFormat : @"Saving Activities...\n%.1f%@", [pct floatValue], @"%"];
		HUD.labelText = strProgress;
		HUD.progress = progress;
		
		if ([type isEqualToString: @""] || [activityType isEqualToString: type]) {
			NSString * uri = [dict objectForKey: @"uri"];
			NSString * activityId  = [uri stringByReplacingOccurrencesOfString: @"/fitnessActivities/" withString: @""];
		
			Activity * existingRun = [self fetchActivity: activityId];
			if (existingRun == nil) {
				retval++;
				
				NSMutableArray * detail = [[self getActivityDetail: uri] mutableCopy];
				// first object is climb
				NSNumber * climb = [NSNumber numberWithInt: 0];
				if ([detail count] > 0) {
					climb = (NSNumber *) [detail objectAtIndex: 0];
					[detail removeObjectAtIndex: 0];
				}
				// second object is calories
				NSNumber * total_calories = [NSNumber numberWithInt: 0];
				if ([detail count] > 0) {
					total_calories = (NSNumber *) [detail objectAtIndex: 0];
					[detail removeObjectAtIndex: 0];
				}
				
				NSMutableDictionary * saveItem = [[NSMutableDictionary alloc] initWithCapacity:2];
				[saveItem setObject: dict forKey: @"activityDict"];
				numberOfItemsToSave++;
				if (!detail) detail = [[NSMutableArray alloc] init];
				[saveItem setObject: detail forKey : @"activityDetail"];
				numberOfItemsToSave += [detail count];
				[saveList addObject: saveItem];
				
				// save
				NSDictionary * activityDict = [saveItem objectForKey: @"activityDict"];
				NSArray * activityDetail = [saveItem objectForKey: @"activityDetail"];
							
				// add activity
				Activity * activity = [NSEntityDescription 
						insertNewObjectForEntityForName: @"Activity" 
						inManagedObjectContext: _context];
				[activity fromDict: activityDict];
				activity.detailCount = [NSNumber numberWithInt: [activityDetail count]];
				activity.climb =[NSNumber numberWithFloat : [climb floatValue]];
				activity.total_calories = [NSNumber numberWithFloat: [total_calories floatValue]];
				activity.source = source;
				
				// heart rate
				float hr = 0;
				float minHr = 999;
				float maxHr = 0;
				for(int i = 0; i < [activityDetail count]; i++) {
					NSDictionary * detailDict = [activityDetail objectAtIndex: i];
					double heartRate = [[detailDict objectForKey: @"heart_rate"] floatValue];
					hr += heartRate;
					
					if (heartRate > maxHr) {
						maxHr = heartRate;
					}
					if (heartRate < minHr) {
						minHr = heartRate;
					}
					
				}
				hr = hr / [activityDetail count];
				activity.heartRate = [NSNumber numberWithFloat: hr];
				activity.minHeartRate = [NSNumber numberWithFloat: minHr];
				activity.maxHeartRate = [NSNumber numberWithFloat: maxHr];
				
				// save the calculations
				activity.avgAltitude = [NSNumber numberWithFloat: 0];
				activity.maxAltitude = [NSNumber numberWithFloat: 0];
				activity.minAltitude = [NSNumber numberWithFloat: 0];
				activity.stdevAltitude = [NSNumber numberWithFloat: 0];
				activity.averageGrade = [NSNumber numberWithFloat: 0];
				
				// save details for activity
				for(int j = 0; j < [activityDetail count]; j++) {
					currentItem ++;
					NSDictionary * detailDict = [activityDetail objectAtIndex: j];
					
					ActivityDetail * det = [NSEntityDescription 
						insertNewObjectForEntityForName: @"ActivityDetail" 
						inManagedObjectContext: _context];
					det.activityId = activity.id;
					[det fromDict: detailDict];
				}
	
				// delete segments
				NSArray * toDelete = [self fetchSegments: activity.id withContext : _context];
				for(int i = 0; i < [toDelete count]; i++) {
					ActivitySegment * seg = [toDelete objectAtIndex: i];
					[_context deleteObject: seg];
				}	
					
				FT_SAVE_MOC(_context) // need that to fetch details for segments		
								
				// calculate segments
				//NSArray * details = [self fetchActivityDetail: activity.id];
				NSArray * details = [self fetchActivityDetail: activity.id withContext: _context];
				[self saveSegmentsForActivity: activity fromDetails: details withContext : _context];
				
				FT_SAVE_MOC(_context)
				
			}
			else {
				//NSLog(@"found existing run - not adding");
			}
		}
	}
	
	// update colors
	[Me refreshUIColor];

	return retval;
}


// inside a thread!
-(int) saveRunkeeperActivitiesOld:(NSArray *)activities partial:(BOOL)isPartial ofType:(NSString *)type fromSource:(NSString *)source {
	BOOL useRemoveList = NO;
	
	NSManagedObjectContext * _context = [[NSManagedObjectContext alloc] init];
	[_context setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
	
	NSMutableArray * removeList = [[NSMutableArray alloc] init];
	if (!isPartial) {
		[self removeAllActivities: type : NO];
	}
	else {
		for(int i= 0; i < [activities count]; i++) {
			NSDictionary * dict = [activities objectAtIndex: i];
			NSString *id = [[dict objectForKey: @"uri"] stringByReplacingOccurrencesOfString: @"/fitnessActivities/" withString: @""];
			
			Activity * a = [self fetchActivity: id withContext : _context];
			if (a) {
				[self removeActivity: id withContext : _context];
				[removeList addObject: id];
			}
		}
		useRemoveList = YES;
	}
	
	int newRunCount = 0;
	
	UIViewController * activeController = [Utilities getActiveViewController];
	MBProgressHUD * HUD = [MBProgressHUD HUDForView: activeController.view];
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	HUD.labelText = @"Saving Activities...";
	
	NSMutableArray * saveList = [[NSMutableArray alloc] init];
		
	totalItems = [activities count];
	int numberOfItemsToSave = 0;
	
	for(int i = 0; i < [activities count]; i++) {
		NSDictionary * dict = [activities objectAtIndex:i];
		NSString * activityType = [dict objectForKey: @"type"];
		
		currentItem = i;
		float progress = (1.0 * currentItem + 1) / (totalItems + 1);
		NSNumber * pct = [NSNumber numberWithFloat: progress * 100.0];
		NSString * strProgress = [NSString  stringWithFormat : @"Saving Activities...\n%.1f%@", [pct floatValue], @"%"];
		HUD.labelText = strProgress;
		HUD.progress = progress;
		
		if ([type isEqualToString: @""] || [activityType isEqualToString: type]) {
			NSString * uri = [dict objectForKey: @"uri"];
			NSString * activityId  = [uri stringByReplacingOccurrencesOfString: @"/fitnessActivities/" withString: @""];
		
			Activity * existingRun = [self fetchActivity: activityId];
			if (existingRun == nil) {
				newRunCount++;
				
				NSMutableArray * detail = [[self getActivityDetail: uri] mutableCopy];
				// first object is climb
				NSNumber * climb = [NSNumber numberWithInt: 0];
				if ([detail count] > 0) {
					climb = (NSNumber *) [detail objectAtIndex: 0];
					[detail removeObjectAtIndex: 0];
				}
				// second object is calories
				NSNumber * total_calories = [NSNumber numberWithInt: 0];
				if ([detail count] > 0) {
					total_calories = [detail objectAtIndex: 0];
					[detail removeObjectAtIndex: 0];
				}
				
				NSMutableDictionary * saveItem = [[NSMutableDictionary alloc] initWithCapacity:2];
				[saveItem setObject: dict forKey: @"activityDict"];
				numberOfItemsToSave++;
				if (!detail) detail = [[NSMutableArray alloc] init];
				[saveItem setObject: detail forKey : @"activityDetail"];
				numberOfItemsToSave += [detail count];
				[saveList addObject: saveItem];
				
				// save
				NSDictionary * activityDict = [saveItem objectForKey: @"activityDict"];
				NSArray * activityDetail = [saveItem objectForKey: @"activityDetail"];
							
				// add activity
				Activity * activity = [NSEntityDescription 
						insertNewObjectForEntityForName: @"Activity" 
						inManagedObjectContext: _context];
				[activity fromDict: activityDict];
				activity.detailCount = [NSNumber numberWithInt: [activityDetail count]];
				activity.climb =[NSNumber numberWithFloat : [climb floatValue]];
				activity.total_calories = [NSNumber numberWithFloat: [total_calories floatValue]];
				activity.source = source;
				
				float averageAltitude = 0;
				float minAltitude = 999999999;
				float maxAltitude = -999999999;
				float stdevAltitude = 0;
				float averageGrade = 0;
				//float stdevGrade = 0;
				//float totalClimb = 0;
				//float totalDescent = 0;
				/*
				if ([activityDetail count] > 0) {
					// compute average altitude
					float totalAltitude = 0;
					float totalGrade = 0;
					float prevAltitude = 0;
					float prevDistance = 0;
					float grade = 0;
					NSMutableArray * grades = [[NSMutableArray alloc] init];
					NSMutableArray * altitudes = [[NSMutableArray alloc] init];
					NSMutableArray * distances = [[NSMutableArray alloc] init];
				
					for(int j = 0; j < [activityDetail count]; j++) {
						NSDictionary * detailDict = [activityDetail objectAtIndex: j];
						float altitude = [[detailDict objectForKey: @"altitude"] floatValue];
						float distance = [[detailDict objectForKey: @"distance"] floatValue];
						[altitudes addObject: [NSNumber numberWithFloat: altitude]];
						[distances addObject: [NSNumber numberWithFloat: distance]];
						totalAltitude += altitude;
						if (altitude < minAltitude) {
							minAltitude = altitude;
						}
						if (altitude > maxAltitude) {
							maxAltitude = altitude;
						}
						
						// grade
						if (j > 0) {
							NSDictionary * prevDetail = [activityDetail objectAtIndex: j - 1];
							prevAltitude = [[prevDetail objectForKey: @"altitude"] floatValue];
							prevDistance = [[prevDetail objectForKey: @"distance"] floatValue];
							
							// subtract lowest altitude from highest altitude
							float deltaAltitude = altitude - prevAltitude; //(altitude > prevAltitude) ? altitude - prevAltitude : prevAltitude - altitude;
							if (deltaAltitude > 0) {
								totalClimb += deltaAltitude;
							}
							else {
								totalDescent += deltaAltitude;
							}
							
							float deltaDistance = distance - prevDistance;
							if (deltaDistance != 0) {
								grade = deltaAltitude / deltaDistance; // rise over run
								totalGrade = totalGrade + grade;
								[grades addObject: [NSNumber numberWithFloat: grade]];
							}
							else grade = 0; 
						}
					}
					
					averageAltitude = totalAltitude / [activityDetail count];
					averageGrade = totalGrade / [activityDetail count];
					
					// compute standard deviation of altitude
					float squares = 0;
					for(int j = 0; j < [activityDetail count]; j++) {
						NSDictionary * detailDict = [activityDetail objectAtIndex: j];
						float altitude = [[detailDict objectForKey: @"altitude"] floatValue];
						float diff = altitude - averageAltitude;
						float square = diff * diff;
						squares += square;
					}
					stdevAltitude = sqrtf(squares / [activityDetail count]);
					
					// compute standard deviation of grade
					squares = 0;
					for(int j = 0; j < [grades count]; j++) {	
						NSNumber * grade = [grades objectAtIndex: j];
						float diff = [grade floatValue] - averageGrade;
						float square = diff * diff;
						squares += square;
					}
					stdevGrade = sqrtf(squares / [grades count]);
					
				//	double cvGrade = stdevGrade / averageGrade;
					NSLog(@"%@ - %@ - up %f - down %f - avg alt %f", 
						[activity getWhenFormatted], [activity getDistanceFormatted], 
						totalClimb, totalDescent, averageAltitude);
				}
				*/
				// save the calculations
				activity.avgAltitude = [NSNumber numberWithFloat: averageAltitude];
				activity.maxAltitude = [NSNumber numberWithFloat: maxAltitude];
				activity.minAltitude = [NSNumber numberWithFloat: minAltitude];
				activity.stdevAltitude = [NSNumber numberWithFloat: stdevAltitude];
				activity.averageGrade = [NSNumber numberWithFloat: averageGrade];
				
				// save details for activity
				for(int j = 0; j < [activityDetail count]; j++) {
					currentItem ++;
					NSDictionary * detailDict = [activityDetail objectAtIndex: j];
					
					ActivityDetail * det = [NSEntityDescription 
						insertNewObjectForEntityForName: @"ActivityDetail" 
						inManagedObjectContext: _context];
					det.activityId = activity.id;
					[det fromDict: detailDict];
				}
	
				// delete segments
				NSArray * toDelete = [self fetchSegments: activity.id withContext : _context];
				for(int i = 0; i < [toDelete count]; i++) {
					ActivitySegment * seg = [toDelete objectAtIndex: i];
					[_context deleteObject: seg];
				}	
					
				FT_SAVE_MOC(_context) // need that to fetch details for segments		
								
				// calculate segments
				NSArray * details = [self fetchActivityDetail: activity.id];
				[self saveSegmentsForActivity: activity fromDetails: details withContext : _context];
				
				FT_SAVE_MOC(_context)
				
			}
			else {
				//NSLog(@"found existing run - not adding");
			}
		}
	}
	
	// update colors
	[Me refreshUIColor];
	
	if (useRemoveList) {
		return newRunCount - [removeList count];
	}
	else {
		return newRunCount;
	}
}

-(void) removeActivity:(NSString *) activityId withContext:(NSManagedObjectContext *)ctx {
	Activity * activity = [self fetchActivity: activityId withContext: ctx];
	if (activity) {
		[self doRemoveActivity : activity withContext : ctx];
	}
}

-(void) doRemoveActivity : (Activity *) activity withContext : ctx {	
	NSString * activityId = activity.id;
	
	if (!ctx) {
		ctx = [self managedObjectContext];
	}
	
	[ctx deleteObject: activity];

	// remove segments
	NSArray * segments = [self fetchSegments: activityId withContext : ctx];
	for(int i = 0; i < [segments count]; i++) {
		ActivitySegment * segment = [segments objectAtIndex: i];
		[ctx deleteObject: segment];
	}
	
	// remove details
	NSArray * details = [self fetchActivityDetail: activityId withContext : ctx];
	for(int i = 0; i < [details count]; i++) {
		ActivityDetail * detail = [details objectAtIndex: i];
		[ctx deleteObject: detail];
		
	}
	
	FT_SAVE_MOC(ctx)
}

/*

-(void) doRemoveActivity : (Activity *) activity {	
	NSString * activityId = activity.id;
	NSManagedObjectContext *context = [self managedObjectContext];
	
	[context deleteObject: activity];
	[self saveContext];

	// remove segments
	NSArray * segments = [self fetchSegments: activityId];
	for(int i = 0; i < [segments count]; i++) {
		ActivitySegment * segment = [segments objectAtIndex: i];
		[context deleteObject: segment];
	}
	[self saveContext];
	
	// remove details
	NSArray * details = [self fetchActivityDetail: activityId];
	for(int i = 0; i < [details count]; i++) {
		ActivityDetail * detail = [details objectAtIndex: i];
		[context deleteObject: detail];
		
	}
	[self saveContext];
}
*/

-(void) removeActivitiesAfter:(NSDate *)date withContext : (NSManagedObjectContext *) ctx {
	NSArray * list = [self fetchActivitiesAfterDate: date ofType: @""];
	if ([list count] > 0) {
		for(int i = 0; i < [list count]; i++) {
			Activity * act = [list objectAtIndex: i];
			[self doRemoveActivity: act withContext: ctx];
		}
	}
}

// returns array of NSString of activity ids of those removed
-(NSArray *) removeActivitiesAfter:(NSDate *)date ofType:(NSString *)type withContext:(NSManagedObjectContext *)ctx {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	
	if (!ctx) {
		ctx = [self managedObjectContext];
	}
	NSArray * activities = [self fetchActivitiesAfterDate: date ofType: type];
	NSMutableArray * activityDetails = [[NSMutableArray alloc] init];
	NSMutableArray * activitySegments = [[NSMutableArray alloc] init];
	if ([activities count] > 0) {
		for(int i = 0; i < [activities count]; i++) {
			Activity * activity = [activities objectAtIndex: i];
			if ([type isEqualToString: @""] || [activity.type isEqualToString: type]) {
				NSArray * details = [self fetchActivityDetail: activity.id];
				[activityDetails addObjectsFromArray: details];
				
				NSArray * segments = [self fetchSegments: activity.id];
				[activitySegments addObjectsFromArray: segments];
			}
		}
		
		for(int i = 0; i < [activitySegments count]; i++) {
			[ctx deleteObject: [activitySegments objectAtIndex: i]];
		}
		
		for(int i = 0; i < [activityDetails count]; i++) {
			[ctx deleteObject: [activityDetails objectAtIndex: i]];
		}
		
		for(int i = 0; i < [activities count]; i++) {
			Activity * activity = [activities objectAtIndex: i];
			[retval addObject: activity.id];
			[ctx deleteObject: activity];
		}
		
		FT_SAVE_MOC(ctx)
	}
	return [retval copy];
}

-(void) removeActivityDetail :(NSString *)activityId  withContext:(NSManagedObjectContext *)ctx {
	NSArray * detail = [self fetchActivityDetail : activityId];
	if ([detail count] > 0) {
		if (!ctx) {
			ctx = [self managedObjectContext];
		}
		for(int i = 0; i < [detail count]; i++) {
			ActivityDetail * dist = [detail objectAtIndex: i];
			[ctx deleteObject: dist];
		}
		FT_SAVE_MOC(ctx)
	}
}

-(void) removeActivitySegments : (NSString *) activityId withContext : (NSManagedObjectContext *) ctx {
	NSArray * segments = [self fetchSegments : activityId];
	if ([segments count] > 0) {
		if (!ctx) {
			ctx = [self managedObjectContext];
		}
		for(int i = 0; i < [segments count]; i++) {
			ActivitySegment * seg = [segments objectAtIndex: i];
			[ctx deleteObject: seg];
		}
		FT_SAVE_MOC(ctx)
	}
}

-(int) getDetailCount:(NSString *)activityId {
	NSArray * details = [self fetchActivityDetail: activityId];
	return [details count];
}

-(Activity *) fetchActivity:(NSString *) activityId  {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"start_time" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id = %@", activityId];
	[fetchRequest setPredicate: predicate];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	Activity * retval = nil;
	if ([fetchedObjects count] > 0) {
		retval = [fetchedObjects objectAtIndex: 0];
	}
	return retval;
}

-(Activity *) fetchActivity:(NSString *) activityId withContext:(NSManagedObjectContext *)ctx {
	NSError * error = nil;
	
	if (!ctx) {
		ctx = [self managedObjectContext];
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" 
		inManagedObjectContext:ctx];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"start_time" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id = %@", activityId];
	[fetchRequest setPredicate: predicate];
		
    NSArray * fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
	Activity * retval = nil;
	if ([fetchedObjects count] > 0) {
		retval = [fetchedObjects objectAtIndex: 0];
	}
	return retval;
}

// **********************
// dashboard items
-(NSUInteger) getNumberOfDashboardItems {
	NSError * error;
	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DashboardItem" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	NSUInteger count = [context countForFetchRequest: fetchRequest error: &error];
	if(count == NSNotFound) {
	   return -1;
	}
	else return count;
}

-(void) removeAllDashboardItems : (NSManagedObjectContext *) ctx {
	NSError * error = nil;
	if (!ctx) {
		ctx = [self managedObjectContext];
	}
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DashboardItem" inManagedObjectContext: ctx];
	[fetchRequest setEntity:entity];
	NSArray *fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
	for(int i = 0; i < [fetchedObjects count]; i++) {
		DashboardItem * di = [fetchedObjects objectAtIndex: i];
		[ctx deleteObject: di];
	}
	FT_SAVE_MOC(ctx)
}

-(DashboardItem *) fetchDashboardItem : (NSString *) itemCode forActivity : (NSString *) activityType {
	NSError * error;

	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DashboardItem" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"activityType = %@ AND itemCode = %@", activityType, itemCode];
	[fetchRequest setPredicate: predicate];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
	if ([fetchedObjects count] > 0) {
		return [fetchedObjects objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(NSArray *) fetchAllDashboardItems : (NSManagedObjectContext *) ctx {
	//NSManagedObjectModel * model = [self managedObjectModel];
	//NSLog(@"%@", [model entities]);

	NSError * error;
	if (!ctx) {
		ctx = [self managedObjectContext];
		
	}
	
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DashboardItem" 
		inManagedObjectContext: ctx];
	[fetchRequest setEntity: entity];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"displayName" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSArray *fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
	return [fetchedObjects copy];
}

-(NSArray *) fetchDashboardItemsWithCode:(NSString *)itemCode {
	NSError * error;

	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DashboardItem" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"itemCode = %@", itemCode];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"defaultOrder" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return [fetchedObjects copy];

}

-(NSArray *) fetchDashboardItemsForActivity:(NSString *)activityType {
	NSError * error;

	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DashboardItem" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"activityType = %@", activityType];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"defaultOrder" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return [fetchedObjects copy];
}

-(NSArray *) fetchSelectedDashboardItemsForActivity:(NSString *)activityType {
	NSError * error;
	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DashboardItem" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	
	NSPredicate * predicate = [NSPredicate 
		predicateWithFormat:@"activityType = %@ AND userSelected = %@", activityType, [NSNumber numberWithBool: YES]];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"defaultOrder" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return [fetchedObjects copy];
}

-(NSArray *) fetchUnselectedDashboardItemsForActivity:(NSString *)activityType {
	NSError * error;
	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DashboardItem" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	
	NSPredicate * predicate = [NSPredicate 
		predicateWithFormat:@"activityType = %@ AND userSelected = %@", activityType, [NSNumber numberWithBool: NO]];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"defaultOrder" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return [fetchedObjects copy];
}

-(void) updateDashboardItems {
	NSArray * farthest = [self fetchDashboardItemsWithCode: @"d_farthest"];
	NSArray * longest = [self fetchDashboardItemsWithCode: @"t_longest"];
	NSManagedObjectContext * ctx = [self managedObjectContext];
	for (int i = 0; i < [farthest count]; i++) {
		DashboardItem * item = [farthest objectAtIndex: i];
		//NSLog(@"before %@", item.itemOrder);
		item.defaultOrder = [NSNumber numberWithInt: 100000000];
		//NSLog(@"after %@", item.itemOrder);
	}
	for(int i = 0; i < [longest count]; i++) {
		DashboardItem * item = [longest objectAtIndex: i];
		item.defaultOrder = [NSNumber numberWithInt: 100000001];
	}
	FT_SAVE_MOC(ctx)
}

-(void) createDashboardItems {
	NSManagedObjectContext * _context = [[NSManagedObjectContext alloc] init];
	[_context setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
	

	[self removeAllDashboardItems: _context];
	
	NSArray * items = [DashboardItemFormatter createItems];
	if ([items count] > 0) {
		for(int i = 0; i < [items count]; i++) {
			DashboardItemFormatter * fmt = [items objectAtIndex: i];
			DashboardItem * item = [NSEntityDescription insertNewObjectForEntityForName: @"DashboardItem" 
				inManagedObjectContext: _context];
			item.activityType = fmt.activityType;
			item.displayName = fmt.displayName;
			item.itemCategory = fmt.itemCategory;
			item.itemCode = fmt.itemCode;
			item.itemOrder = fmt.itemOrder;
			item.userSelected = fmt.userSelected;
			item.defaultOrder = fmt.defaultOrder;
		}
		FT_SAVE_MOC(_context)
	}
	
}

-(void) selectDashboardItems:(NSArray *)itemCodes forActivity:(NSString *)activityType {	
	NSArray * items = [self fetchDashboardItemsForActivity: activityType];
	for(int i = 0; i < [items count]; i++) {
		DashboardItem * item = [items objectAtIndex: i];
		int index = [itemCodes indexOfObject: item.itemCode];
		if (index == NSNotFound) {
			if (![item.userSelected boolValue]) {
				item.userSelected = [NSNumber numberWithBool: NO];
				item.itemOrder = [NSNumber numberWithInt: -1];
			}
		}
		else {
			item.userSelected = [NSNumber numberWithBool: YES];
		}
	}
	[self saveContext];
}

-(void) deselectDashboardItem:(NSString *)itemCode forActivity:(NSString *)activityType {
	DashboardItem * item = [self fetchDashboardItem: itemCode forActivity: activityType];
	if (item) {
		item.userSelected = [NSNumber numberWithBool : NO];
		[self saveContext];
	}
}

-(void) updateItemOrders:(NSArray *)formatters forActivity:(NSString *)activityType {
	for(int i = 0; i < [formatters count]; i++) {
		DashboardItemFormatter * fmt = [formatters objectAtIndex: i];
		DashboardItem * item = [self fetchDashboardItem: fmt.itemCode forActivity: activityType];
		item.itemOrder = [NSNumber numberWithInt: [fmt.itemOrder intValue]];
	}
	[self saveContext];
}

// ****** Goals *****
// 
-(void) removeAllGoals : (NSManagedObjectContext *) ctx {
	NSError * error = nil;
	if (!ctx) {
		ctx = [self managedObjectContext];
	}
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Goal" inManagedObjectContext: ctx];
	[fetchRequest setEntity:entity];
	NSArray *fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
	for(int i = 0; i < [fetchedObjects count]; i++) {
		Goal * g = [fetchedObjects objectAtIndex: i];
		[ctx deleteObject: g];
	}
	FT_SAVE_MOC(ctx)
}

-(NSArray *) fetchGoalsForActivity:(NSString *)activityType ofKind:(NSString *)kind {
	NSError * error;
	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"Goal" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"activityType = %@ AND kind = %@", activityType, kind];
	[fetchRequest setPredicate: predicate];
	
	// most recent first
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"created" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return [fetchedObjects copy];
}

-(Goal *) fetchCurrentGoalForActivity:(NSString *)activityType ofKind:(NSString *)kind {
	NSArray * goals = [self fetchGoalsForActivity: activityType ofKind: kind];
	Goal * retval = nil;
	if ((goals != nil) && ([goals count] > 0)){
		retval = [goals objectAtIndex: 0];
	}
	return retval;
}

// DistanceGoal
-(DistanceGoal *) findDistanceGoalForActivity:(NSString *)activity andFrequency:(NSString *)frequency {
	NSError * error;
	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DistanceGoal" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	
	NSPredicate * predicate = [NSPredicate 
		predicateWithFormat:@"activityType = %@ AND frequency = %@", activity, frequency];
	[fetchRequest setPredicate: predicate];
	
	// most recent first
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"created" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if ([fetchedObjects count] > 0) {
		return [fetchedObjects objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(DistanceGoal *) findDistanceGoalForActivity:(NSString *)activity andFrequency:(NSString *)frequency noLaterThan:(NSDate *)date {
	NSError * error;
	NSManagedObjectContext * context = [self managedObjectContext];
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName: @"DistanceGoal" inManagedObjectContext: context];
	[fetchRequest setEntity: entity];
	
	NSPredicate * predicate = [NSPredicate 
		predicateWithFormat:@"activityType = %@ AND frequency = %@ AND created <= %@", activity, frequency, date];
	[fetchRequest setPredicate: predicate];
	
	// most recent first
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"created" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if ([fetchedObjects count] > 0) {
		return [fetchedObjects objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(void) setDistanceGoalForActivity:(NSString *)activity andFrequency:(NSString *)frequency atDistance:(NSNumber *)distance andUnits:(NSString *)units {
	NSManagedObjectContext * ctx = [self managedObjectContext];
	DistanceGoal * dg = [self findDistanceGoalForActivity: activity andFrequency: frequency];
	NSDate * today = [Utilities currentLocalDate];
	if (dg != nil) {
		// if there is a same goal with the same date, update it
		if ([dg.created compare: today] == NSOrderedSame) {
			dg.distance = distance;
			dg.units = units;
		}
		else { // if it's on a different date, create a new one
			dg = [NSEntityDescription insertNewObjectForEntityForName: @"DistanceGoal" 
				inManagedObjectContext:ctx];
			dg.created = today;
			dg.frequency = frequency;
			dg.activityType = activity;
			dg.distance = distance;
			dg.units = units;
		}
	}
	else { // if it's not there at all, create a new one
		dg = [NSEntityDescription insertNewObjectForEntityForName: @"DistanceGoal" 
			inManagedObjectContext:ctx];
		dg.created = today;
		dg.frequency = frequency;
		dg.activityType = activity;
		dg.distance =distance;
		dg.units = units;
	}
	
	FT_SAVE_MOC(ctx)
}
	
//**** Activities ****
-(void) userRemoveAllActivities {
	UIViewController * activeController = [Utilities getActiveViewController];
	MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo: activeController.view animated:YES];
	HUD.labelText = @"Deleting Activities...";
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	HUD.progress = 0.5;
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSManagedObjectContext * ctx = [[NSManagedObjectContext alloc] init];
		[ctx setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
		
		NSArray * activities = [self fetchAllActivitiesWithContext: ctx];
		NSArray * details = [self fetchAllDetailsWithContext: ctx];
		NSArray * segments = [self fetchAllSegmentsWithContext: ctx];
		
		int  processed = 0;
		int  total = [activities count] + [details count] + [segments count];

		for(int i = 0; i < [activities count]; i++) {
			[ctx deleteObject: [activities objectAtIndex: i]];
			processed++;
			HUD.progress = (1.0 * processed) / total;
		}
		
		for(int i = 0; i < [details count]; i++) {
			[ctx deleteObject: [details objectAtIndex: i]];
			processed++;
			HUD.progress = (1.0 * processed) / total;
		}
		
		for(int i = 0; i < [segments count]; i++) {
			[ctx deleteObject: [segments objectAtIndex: i]];
			processed ++;
			HUD.progress = (1.0 * processed) / total;
		}

		FT_SAVE_MOC(ctx);
		
		//[[NSNotificationCenter defaultCenter] postNotificationName: @"runsLoaded" object: nil];
	
		dispatch_async(dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
			[MBProgressHUD hideHUDForView: activeController.view animated:YES];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"runsLoaded" object:nil];
		});
	
	});
}

-(void) removeAllActivities:(NSString *)ofType :(BOOL)showProgress {
	[self removeAllActivities: ofType : showProgress withContext: [self managedObjectContext]];
}

-(void) removeAllActivities:(NSString *)ofType : (BOOL) showProgress withContext:(NSManagedObjectContext *)ctx {
	MBProgressHUD * HUD = nil;
	UIViewController * activeController = [Utilities getActiveViewController];
	
	if (showProgress) {
		HUD = [MBProgressHUD showHUDAddedTo: activeController.view animated:YES];
		HUD.labelText = @"Deleting Activities...";
		HUD.mode = MBProgressHUDModeAnnularDeterminate;
	}
	
	if (!ctx) {
		ctx = [self managedObjectContext];
	}
	
	NSError * error = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" 
		inManagedObjectContext: ctx];
	[fetchRequest setEntity:entity];
	NSArray *fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
	NSMutableArray * activityDetails = [[NSMutableArray alloc] init];
	for (Activity * activity in fetchedObjects) {
		if ([ofType isEqualToString: @""] || [activity.type isEqualToString: ofType]) {
			[activityDetails addObjectsFromArray: [self fetchActivityDetail: activity.id withContext: ctx]];
		}
	}
	
	NSArray * allSegments = [self fetchAllSegmentsWithContext: ctx];
	int  processed = 0;
	int  total = [activityDetails count] + [fetchedObjects count] + [allSegments count];

	for(int i = 0; i < [activityDetails count]; i++) {
		[ctx deleteObject: [activityDetails objectAtIndex: i]];
		processed++;
		if (showProgress) {
			HUD.progress = (1.0 * processed) / total;
		}
	}
	
	for(int i = 0; i < [fetchedObjects count]; i++) {
		[ctx deleteObject: [fetchedObjects objectAtIndex: i]];
		processed++;
		if (showProgress) {
			HUD.progress = (1.0 * processed) / total;
		}
	}
	
	for(int i = 0; i < [allSegments count]; i++) {
		[ctx deleteObject: [allSegments objectAtIndex: i]];
		processed ++;
		if (showProgress ) {
			HUD.progress = (1.0 * processed) / total;
		}
	}
	
	/*
	NSArray * dashboard = [self fetchAllDashboardItems :ctx ];
	for(int i = 0; i < [dashboard count]; i++) {
		[ctx deleteObject: [dashboard objectAtIndex: i]];
	}*/
	
	HUD.labelText = @"Almost done...";
	FT_SAVE_MOC(ctx);
	
	[[NSNotificationCenter defaultCenter] 
		postNotificationName: @"runsLoaded" object: nil];
		
	if (showProgress) {
		[MBProgressHUD hideHUDForView: activeController.view animated:YES];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
			
}

-(NSNumber *) getAverageSecondsFor : (float) meters between : (ActivityDetail *) distance1 and : (ActivityDetail *) distance2 {
	float dist1 = [distance1.distance floatValue];
	float dist2 = [distance2.distance floatValue];
	float time1 = [distance1.timestamp floatValue];
	float time2 = [distance2.timestamp floatValue];
	
	float dist = dist2 - dist1;
	float time = time2 - time1;
	float speed = dist / time;
	float dist3 = meters - dist1;
	float time3 = time1 + dist3 / speed;
	
	NSNumber * retval = [NSNumber numberWithFloat: time3];
	
	/*
	
	float dist3 = meters;
	float time1_1 = (dist3 * time1) / dist1;
	float time1_2 = (dist3 * time2) / dist2;
	NSNumber * retval = [NSNumber numberWithFloat: (time1_1 + time1_2) / 2];
	*/
	return retval;
}

-(NSArray *) saveSegmentsForActivity : (Activity *) activity  fromDetails :(NSArray *)fromDetail withContext : (NSManagedObjectContext *) context {
	NSMutableArray * retval = [[NSMutableArray alloc] init];
	NSMutableArray * kilometers = [[NSMutableArray alloc] init];
	NSMutableArray * miles = [[NSMutableArray alloc] init];
	
	ActivityDetail * thisDetail = nil;
	ActivityDetail * prevDetail = nil;
	
	ActivityDetail * last = [fromDetail lastObject];
	int maxKM = ceil([last.distance floatValue]/1000);
	
	NSMutableArray * points = [[NSMutableArray alloc] init];
	for (int i = 1; i <= maxKM; i++) {
		[points addObject: [NSNumber numberWithInt: i]];
	}
	
	NSMutableArray * segmentDetails = [[NSMutableArray alloc] init];
	
	for(int i = 0; i < [fromDetail count]; i++) {
		if ([points count] == 0) break;
	
		thisDetail = [fromDetail objectAtIndex: i];
		[segmentDetails addObject: thisDetail]; // save this detail to array for segment
		
		if (i > 0) prevDetail = [fromDetail objectAtIndex: i - 1];
		if (prevDetail != nil) {
			float thisDistance = [thisDetail.distance floatValue];
			float prevDistance = [prevDetail.distance floatValue];
			
			float thisAltitude = [thisDetail.altitude floatValue];
			float prevAltitude = [prevDetail.altitude floatValue];
			float avgAltitude = (thisAltitude + prevAltitude) / 2;
			
			NSNumber * nextPoint = [points objectAtIndex: 0];
	
			// half marathon 21097.494
			if ((thisDistance >  21097 ) && (prevDistance < 21097 )) {
				//NSLog(@"half!");
				ActivitySegment * segment = [NSEntityDescription 
					insertNewObjectForEntityForName: @"ActivitySegment" 
					inManagedObjectContext: context];
				segment.activityId = activity.id;
				segment.activityTime = activity.start_time;
				segment.activityType = activity.type;
				segment.meters = [NSNumber numberWithFloat: 21097.494];
				segment.seconds = [self getAverageSecondsFor: 21097.494 between:prevDetail and:thisDetail];
				segment.title = @"half";//[NSString stringWithFormat: @"%d", [nextPoint intValue]];
				segment.units = @"half";
				segment.altitude = [NSNumber numberWithFloat: avgAltitude];
				
				ActivitySegment * prevSegment = nil;
				if ([kilometers count] > 0) {
					prevSegment = [kilometers objectAtIndex: [kilometers count] - 1];
				}
				if (prevSegment) {
					segment.segmentSeconds = [NSNumber numberWithFloat: [segment.seconds floatValue] - [prevSegment.seconds floatValue]];
					segment.delta = [NSNumber numberWithFloat: [segment.segmentSeconds floatValue] - [prevSegment.segmentSeconds floatValue]];
				}
				else {
					segment.segmentSeconds = [NSNumber numberWithFloat: [segment.seconds floatValue]];
					segment.delta = nil;
				}
				segment.order = [NSNumber numberWithInt: [nextPoint intValue]];
				[kilometers addObject: segment];
			}

			// full marathon- 42194.988
			if ((thisDistance > 42195 ) && (prevDistance < 42195 )) {
				ActivitySegment * segment = [NSEntityDescription 
					insertNewObjectForEntityForName: @"ActivitySegment" 
					inManagedObjectContext: context];
				segment.activityId = activity.id;
				segment.activityTime = activity.start_time;
				segment.activityType = activity.type;
				segment.meters = [NSNumber numberWithFloat: 42194.988];
				segment.seconds = [self getAverageSecondsFor: 42194.988 between:prevDetail and:thisDetail];
				segment.title = @"full"; //[NSString stringWithFormat: @"%d", [nextPoint intValue]];
				segment.units = @"full";
				segment.altitude = [NSNumber numberWithFloat: avgAltitude];
				
				ActivitySegment * prevSegment = nil;
				if ([kilometers count] > 0) {
					prevSegment = [kilometers objectAtIndex: [kilometers count] - 1];
				}
				if (prevSegment) {
					segment.segmentSeconds = [NSNumber numberWithFloat: [segment.seconds floatValue] - [prevSegment.seconds floatValue]];
					segment.delta = [NSNumber numberWithFloat: [segment.segmentSeconds floatValue] - [prevSegment.segmentSeconds floatValue]];
				}
				else {
					segment.segmentSeconds = [NSNumber numberWithFloat: [segment.seconds floatValue]];
					segment.delta = nil;
				}
				segment.order = [NSNumber numberWithInt: [nextPoint intValue]];
				[kilometers addObject: segment];
			}

		
			// k's
			if ((thisDistance > [nextPoint floatValue] * 1000 ) && (prevDistance < [nextPoint floatValue] * 1000 )) {
				ActivitySegment * segment = [NSEntityDescription 
					insertNewObjectForEntityForName: @"ActivitySegment" 
					inManagedObjectContext: context];
				segment.activityId = activity.id;
				segment.activityTime = activity.start_time;
				segment.activityType = activity.type;
				segment.meters = [NSNumber numberWithFloat: [nextPoint floatValue] * 1000];
				segment.seconds = [self getAverageSecondsFor: [nextPoint floatValue] * 1000 between:prevDetail and:thisDetail];
				segment.title = [NSString stringWithFormat: @"%d", [nextPoint intValue]];
				segment.units = @"k";
				segment.altitude = [NSNumber numberWithFloat: avgAltitude];
				
				// calculate heart rate from segmentDetails
				float avgHR = 0;
				float minHR = 999;
				float maxHR = 0;
				for(int h = 0; h < [segmentDetails count]; h++) {
					ActivityDetail * ad = [segmentDetails objectAtIndex: h];
					avgHR += [ad.heartRate floatValue];
					float thisHR = [ad.heartRate floatValue];
					if (thisHR > maxHR) maxHR = thisHR;
					if (thisHR < minHR) minHR = thisHR;
				}
				avgHR = avgHR / [segmentDetails count]; // average
				segment.heartRate = [NSNumber numberWithFloat: avgHR];
				segment.minHeartRate = [NSNumber numberWithFloat: minHR];
				segment.maxHeartRate = [NSNumber numberWithFloat: maxHR];
				
				// store startDistance and endDistance for this segment
				if ([segmentDetails count] > 0) {
					ActivityDetail * startDetail = [segmentDetails objectAtIndex: 0];
					ActivityDetail * endDetail = [segmentDetails lastObject];
					segment.startDistance	= [NSNumber numberWithFloat: [startDetail.distance floatValue]];
					segment.endDistance		= [NSNumber numberWithFloat: [endDetail.distance floatValue]];
				}
				else {
					segment.startDistance = [NSNumber numberWithInt:0];
					segment.endDistance = [NSNumber numberWithInt: 0];
				}
				segmentDetails = [[NSMutableArray alloc] init];
				
				ActivitySegment * prevSegment = nil;
				if ([kilometers count] > 0) {
					prevSegment = [kilometers objectAtIndex: [kilometers count] - 1];
				}
				
				if (prevSegment) {	
					segment.segmentSeconds = [NSNumber numberWithFloat: [segment.seconds floatValue] - [prevSegment.seconds floatValue]];
					segment.delta = [NSNumber numberWithFloat: [segment.segmentSeconds floatValue] - [prevSegment.segmentSeconds floatValue]];
				}
				else {
					segment.segmentSeconds = [NSNumber numberWithFloat: [segment.seconds floatValue]];
					segment.delta = nil;
				}
				segment.order = [NSNumber numberWithInt: [nextPoint intValue]];
				
				[kilometers addObject: segment];
				
				[points removeObjectAtIndex: 0]; // pop
			}
		}
	}
	
	// miles
	int maxMI = floor([last.distance floatValue]/1609.344);
	[points removeAllObjects];
	for (int i = 1; i <= maxMI; i++) {
		[points addObject: [NSNumber numberWithInt: i]];
	}
	
	for(int i = 0; i < [fromDetail count]; i++) {
		if ([points count] == 0) break;
	
		thisDetail = [fromDetail objectAtIndex: i];
		[segmentDetails addObject: thisDetail]; // save this detail to array for segment
		
		if (i > 0) prevDetail = [fromDetail objectAtIndex: i - 1];
		if (prevDetail != nil) {
		
			float thisDistance = [thisDetail.distance floatValue];
			float prevDistance = [prevDetail.distance floatValue];
			
			float thisAltitude = [thisDetail.altitude floatValue];
			float prevAltitude = [prevDetail.altitude floatValue];
			float avgAltitude = (thisAltitude + prevAltitude) / 2;
			
			NSNumber * nextPoint = [points objectAtIndex: 0];
		
			if ((thisDistance > [nextPoint floatValue] * 1609.344 ) && (prevDistance < [nextPoint floatValue] * 1609.344 )) {
				ActivitySegment * segment = [NSEntityDescription 
					insertNewObjectForEntityForName: @"ActivitySegment" 
					inManagedObjectContext: context];
				segment.activityId = activity.id;
				segment.activityTime = activity.start_time;
				segment.activityType = activity.type;
				segment.meters = [NSNumber numberWithFloat: [nextPoint floatValue] * 1609.344];
				segment.seconds = [self getAverageSecondsFor: [nextPoint floatValue] * 1609.344 between:prevDetail and:thisDetail];
				segment.title = [NSString stringWithFormat: @"%d", [nextPoint intValue]];
				segment.units = @"m";
				segment.altitude = [NSNumber numberWithFloat: avgAltitude];
				
				// calculate heart rate from segmentDetails
				float avgHR = 0;
				float minHR = 999;
				float maxHR = 0;
				for(int h = 0; h < [segmentDetails count]; h++) {
					ActivityDetail * ad = [segmentDetails objectAtIndex: h];
					avgHR += [ad.heartRate floatValue];
					float thisHR = [ad.heartRate floatValue];
					if (thisHR > maxHR) maxHR = thisHR;
					if (thisHR < minHR) minHR = thisHR;
				}
				avgHR = avgHR / [segmentDetails count];
				segment.heartRate = [NSNumber numberWithFloat: avgHR];
				segment.minHeartRate = [NSNumber numberWithFloat: minHR];
				segment.maxHeartRate = [NSNumber numberWithFloat: maxHR];
				
				// store startDistance and endDistance for this segment
				if ([segmentDetails count] > 0) {
					ActivityDetail * startDetail = [segmentDetails objectAtIndex: 0];
					ActivityDetail * endDetail = [segmentDetails lastObject];
					segment.startDistance	= [NSNumber numberWithFloat: [startDetail.distance floatValue]];
					segment.endDistance		= [NSNumber numberWithFloat: [endDetail.distance floatValue]];
				}
				else {
					segment.startDistance = [NSNumber numberWithInt:0];
					segment.endDistance = [NSNumber numberWithInt: 0];
				}
				segmentDetails = [[NSMutableArray alloc] init];
				
				ActivitySegment * prevSegment = nil;
				if ([miles count] > 0) {
					prevSegment = [miles objectAtIndex: [miles count] - 1];
				}
				if (prevSegment) {
					segment.segmentSeconds = [NSNumber numberWithFloat: [segment.seconds floatValue] - [prevSegment.seconds floatValue]];
					segment.delta = [NSNumber numberWithFloat: [segment.segmentSeconds floatValue] - [prevSegment.segmentSeconds floatValue]];
				}
				else {
					segment.segmentSeconds = [NSNumber numberWithFloat: [segment.seconds floatValue]];
					segment.delta = nil;
				}
				segment.order = [NSNumber numberWithInt: [nextPoint intValue]];
				[miles addObject: segment];
				
				[points removeObjectAtIndex: 0]; // pop
			}
		}
	}
	
	// compute altutide changes for each segment
	ActivityDetail * firstDetail = nil;
	if ([fromDetail count] > 0) {
		firstDetail = [fromDetail objectAtIndex: 0];
	}
	
	if (firstDetail) {
		for(int i = 0; i < [kilometers count]; i++) {
			ActivitySegment * seg = [kilometers objectAtIndex: i];
			if ([seg.units isEqualToString: @"k"]) {
				float altitudeChange = 0; // in meters
				float elevationChange = 0; // in percent, 
				float prevAltitude = 0;
				float thisAltitude = [seg.altitude floatValue];
				if (i == 0) {
					 prevAltitude = [firstDetail.altitude floatValue];
				}
				else {
					ActivitySegment * prevSegment = [kilometers objectAtIndex: i - 1];
					prevAltitude = [prevSegment.altitude floatValue];
				}
				
				altitudeChange = thisAltitude - prevAltitude; // nominal, meter terms
				if (prevAltitude != 0) {
					elevationChange = thisAltitude / prevAltitude - 1; // percentage terms
				}
				
				seg.altitudeChange = [NSNumber numberWithFloat: altitudeChange];
				seg.elevationChange = [NSNumber numberWithFloat: elevationChange];
			}
		}
	}

	[retval addObjectsFromArray: kilometers];
	
	if (firstDetail) {
		for(int i = 0; i < [miles count]; i++) {
			ActivitySegment * seg = [miles objectAtIndex: i];
			if ([seg.units isEqualToString: @"m"]) {
				float altitudeChange = 0; // in meters
				float elevationChange = 0; // in percent, 
				float prevAltitude = 0;
				float thisAltitude = [seg.altitude floatValue];
				if (i == 0) {
					 prevAltitude = [firstDetail.altitude floatValue];
				}
				else {
					ActivitySegment * prevSegment = [miles objectAtIndex: i - 1];
					prevAltitude = [prevSegment.altitude floatValue];
				}
				
				altitudeChange = thisAltitude - prevAltitude; // nominal, meter terms
				if (prevAltitude != 0) {
					elevationChange = thisAltitude / prevAltitude - 1; // percentage terms
				}
				
				seg.altitudeChange = [NSNumber numberWithFloat: altitudeChange];
				seg.elevationChange = [NSNumber numberWithFloat: elevationChange];
			}
		}
	}
	
	[retval addObjectsFromArray: miles];
	
	//NSLog(@"%d segments", [retval count]);
	
	return [retval copy];
}

-(NSArray *) fetchAllSegments {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivitySegment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"order" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchAllSegmentsWithContext : (NSManagedObjectContext *) context {
	NSError * error = nil;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivitySegment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchSegments : (NSString *) activityId {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivitySegment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat: @"activityId = %@", activityId];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"order" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchSegments : (NSString *) activityId withContext :(NSManagedObjectContext *) ctx {
	NSError * error = nil;
	
	if (!ctx) {
		ctx = [self managedObjectContext];
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivitySegment" 
		inManagedObjectContext: ctx];
    [fetchRequest setEntity:entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat: @"activityId = %@", activityId];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"order" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchSegmentsOfType:(NSString *)type withTitle : (NSString *) title andUnit:(NSString *)unit {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivitySegment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSPredicate * predicate = nil; 
	if (title == nil) {
		predicate = [NSPredicate predicateWithFormat: @"activityType = %@ AND units = %@", type, unit];
	}
	else {
		predicate = [NSPredicate predicateWithFormat: @"activityType = %@ AND title = %@ AND units = %@", type, title, unit];
	}
	
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"order" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchSegmentsBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate ofType:(NSString *)type withTitle:(NSString *)title andUnits:(NSString *)units {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivitySegment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSPredicate * predicate = nil;
	if (title == nil) {
		predicate = [NSPredicate predicateWithFormat: @"activityType = %@ AND units = %@ AND activityTime >= %@ AND activityTime <= %@", type, units, startDate, endDate];
	}
	else {
		predicate = [NSPredicate predicateWithFormat: @"activityType = %@ AND title = %@ AND units = %@ AND activityTime >= %@ AND activityTime <= %@", type, title, units, startDate, endDate];

	}
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"order" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(ActivitySegment *) fetchSegmentFromActivity:(NSString *)activityId withTitle:(NSString *)title andUnits:(NSString *)units {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivitySegment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat: @"activityId = %@ AND title = %@ AND units = %@", activityId, title, units];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"order" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects) {
		if ([fetchedObjects count] > 0) {
			ActivitySegment * retval = [fetchedObjects objectAtIndex: 0];
			return retval;
		}
		else {
			return nil;
		}
	}
	else {
		return nil;
	}	
}

-(NSArray *) fetchSegments : (NSString *) activityId ofUnit : (NSString *) unit {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivitySegment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat: @"activityId = %@ AND units = %@", activityId, unit];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"order" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchAllActivities {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"start_time" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *)fetchAllActivitiesWithContext : (NSManagedObjectContext *) context {
	NSError * error = nil;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"start_time" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchActivities:(NSString *)type {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	if (![type isEqualToString: @""]) {
		NSPredicate * predicate = [NSPredicate predicateWithFormat: @"type = %@", type];
		[fetchRequest setPredicate: predicate];
	}
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"start_time" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (error) {
		UIAlertView * alert = [[UIAlertView alloc] 
			initWithTitle: @"Internal Error" 
			message: [NSString stringWithFormat: @"%@", error] 
			delegate:nil 
			cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[alert show];
		NSLog(@"Fetch Error : %@", error);
		return nil;
	}
	else {
		return fetchedObjects;
	}
}

-(NSArray *) fetchAllDetailsWithContext : (NSManagedObjectContext *) context {
	NSError * error = nil;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivityDetail" inManagedObjectContext: context];
    [fetchRequest setEntity:entity];
	
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchActivityDetail:(NSString *)activityId {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivityDetail" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat: @"activityId = %@", activityId];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"distance" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *) fetchActivityDetail:(NSString *)activityId withContext:(NSManagedObjectContext *)ctx{
	NSError * error = nil;
	
	if (!ctx) {
		ctx = [self managedObjectContext];
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ActivityDetail" 
		inManagedObjectContext:ctx];
    [fetchRequest setEntity:entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat: @"activityId = %@", activityId];
	[fetchRequest setPredicate: predicate];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"distance" ascending:YES];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		
    NSArray * fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}



-(NSArray *) fetchActivitiesAfterDate:(NSDate *)date ofType:(NSString *)type {
	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"start_time" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	if (![type isEqualToString: @""]) {
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"type = %@ AND start_time >= %@", type, date];
		[fetchRequest setPredicate: predicate];
	}
	else {
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"start_time >= %@", date];
		[fetchRequest setPredicate: predicate];
	}
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(NSArray *)fetchActivitiesBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate ofType:(NSString *)type {
	//NSLog(@"bettween %@ and %@", startDate, endDate);

	NSError * error = nil;
	NSManagedObjectContext *context = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"start_time" ascending:NO];
	[fetchRequest setSortDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	
	if (![type isEqualToString: @""]) {
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"type = %@ AND start_time >= %@ AND start_time <= %@", type, startDate, endDate];
		[fetchRequest setPredicate: predicate];
	}
	else {
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"start_time >= %@ AND start_time <= %@", startDate, endDate];
		[fetchRequest setPredicate: predicate];

	}
		
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	return fetchedObjects;
}

-(ActivitySegment *) getFastestSegmentOfType:(NSString *)type withTitle : (NSString *) title andUnits:(NSString *)units {
	NSMutableArray * data = nil;
	// for 1M or 1K, look at all segments
	NSString * sortBy = @"seconds";
	if ([title isEqualToString: @"1"]) {
		data = [[self fetchSegmentsOfType: type withTitle : nil andUnit: units] mutableCopy];
		sortBy = @"segmentSeconds";
	}
	else {
		data = [[self fetchSegmentsOfType: type withTitle : title andUnit: units] mutableCopy];
		sortBy = @"seconds";
	}
	
	NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey: sortBy ascending:YES];
	NSSortDescriptor * sort2 = [NSSortDescriptor sortDescriptorWithKey: @"activityTime" ascending: NO];
	[data sortUsingDescriptors: [NSArray arrayWithObjects: sort, sort2, nil]];
	if ([data count] > 0) {
		return [data objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(NSArray *)getSegmentsBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate 
	ofType:(NSString *)type 
	withTitle:(NSString *)title 
	andUnits:(NSString *)units {
	
	NSMutableArray * data = nil;
	NSString * sortBy = @"seconds";
	// for 1M or 1K look at all segments
	if ([title isEqualToString: @"1"]) {
		data = [[self fetchSegmentsBetweenStartDate:startDate andEndDate:endDate ofType: type withTitle: nil andUnits: units] mutableCopy];
		sortBy = @"segmentSeconds";
	}
	else {
	    data = [[self fetchSegmentsBetweenStartDate:startDate andEndDate:endDate ofType: type withTitle: title andUnits: units] mutableCopy];
		sortBy = @"seconds";
	}
	NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey: sortBy ascending:YES];
	NSSortDescriptor * sort2 = [NSSortDescriptor sortDescriptorWithKey: @"activityTime" ascending: NO];
	[data sortUsingDescriptors: [NSArray arrayWithObjects: sort, sort2, nil]];
	
	return [data copy];
}

-(ActivitySegment *) getFastestSegmentBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate ofType:(NSString *)type withTitle:(NSString *)title andUnits:(NSString *)units {
	NSMutableArray * data = nil;
	NSString * sortBy = @"seconds";
	// for 1M or 1K look at all segments
	if ([title isEqualToString: @"1"]) {
		data = [[self fetchSegmentsBetweenStartDate:startDate andEndDate:endDate ofType: type withTitle: nil andUnits: units] mutableCopy];
		sortBy = @"segmentSeconds";
	}
	else {
	    data = [[self fetchSegmentsBetweenStartDate:startDate andEndDate:endDate ofType: type withTitle: title andUnits: units] mutableCopy];
		sortBy = @"seconds";
	}
	NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey: sortBy ascending:YES];
	NSSortDescriptor * sort2 = [NSSortDescriptor sortDescriptorWithKey: @"activityTime" ascending: NO];
	[data sortUsingDescriptors: [NSArray arrayWithObjects: sort, sort2, nil]];
	if ([data count] > 0) {
		return [data objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(Activity *) getFarthestActivityOfType:(NSString *)type {
	NSMutableArray * data = [[self fetchActivities: type] mutableCopy];
	//NSMutableArray * runs = [[self fetchActivitiesAfterDate: date ofType: type] mutableCopy];
	NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"total_distance" ascending:NO];
	[data sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	if ([data count] > 0)  {
		return [data objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(Activity *) getLongestActivityOfType:(NSString *)type {
	NSMutableArray * data = [[self fetchActivities: type] mutableCopy];
	//NSMutableArray * runs = [[self fetchActivitiesAfterDate: date ofType: type] mutableCopy];
	NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO];
	[data sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	if ([data count] > 0)  {
		return [data objectAtIndex: 0];
	}
	else {
		return nil;
	}
}


-(ActivityFormatter *) getFarthestWeekOfType:(NSString *)type {
	ActivityFormatter * retval = [[ActivityFormatter alloc] init];
	NSArray * weeks = [ActivityWeek getWeeks];
	for(int i = 0; i < [weeks count]; i++) {
		ActivityWeek * week = [weeks objectAtIndex: i];
		week.value = [NSNumber numberWithFloat: 0];
		NSArray * activities = [self fetchActivitiesBetweenStartDate: week.weekStart andEndDate: week.weekEnd ofType: type];
		for(int j = 0; j < [activities count]; j++) {
			Activity * activity = [activities objectAtIndex: j];
			float val = [week.value floatValue];
			float add = [activity.total_distance floatValue];
			week.value = [NSNumber numberWithFloat: val + add];
		}
	}
	
	NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey: @"value" ascending: NO];
	NSArray * sorted = [weeks sortedArrayUsingDescriptors: [NSArray arrayWithObject: sort]];
	
	if ([sorted count] > 0) {
		ActivityWeek * farthest = [sorted objectAtIndex: 0];
		retval.start_time = farthest.weekStart;
		retval.distance = [NSNumber numberWithFloat: [farthest.value floatValue]];
		if ([retval.distance floatValue] > 0) {
			return retval;
		}
		else {
			return nil;
		}
	}
	else {
		return nil;
	}
}


-(ActivityFormatter *) getFarthestWeekBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate ofType:(NSString *)type {
	ActivityFormatter * retval = [[ActivityFormatter alloc] init];
	NSArray * weeks = [ActivityWeek getWeeksBetween: startDate and: endDate];
	for(int i = 0; i < [weeks count]; i++) {
		ActivityWeek * week = [weeks objectAtIndex: i];
		week.value = [NSNumber numberWithFloat: 0];
		NSArray * activities = [self fetchActivitiesBetweenStartDate: week.weekStart andEndDate: week.weekEnd ofType: type];
		for(int j = 0; j < [activities count]; j++) {
			Activity * activity = [activities objectAtIndex: j];
			float val = [week.value floatValue];
			float add = [activity.total_distance floatValue];
			week.value = [NSNumber numberWithFloat: val + add];
		}
	}
	
	NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey: @"value" ascending: NO];
	NSArray * sorted = [weeks sortedArrayUsingDescriptors: [NSArray arrayWithObject: sort]];
	
	if ([sorted count] > 0) {
		ActivityWeek * farthest = [sorted objectAtIndex: 0];
		retval.start_time = farthest.weekStart;
		retval.distance = [NSNumber numberWithFloat: [farthest.value floatValue]];
		if ([retval.distance floatValue] > 0) {
			return retval;
		}
		else {
			return nil;
		}
	}
	else {
		return nil;
	}

}

-(Activity *) getFarthestActivityAfterDate:(NSDate *)date ofType:(NSString *)type {
	NSMutableArray * data = [[self fetchActivitiesAfterDate: date ofType: type] mutableCopy];
	NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"total_distance" ascending:NO];
	[data sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	if ([data count] > 0)  {
		return [data objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(Activity *) getFarthestActivityBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate ofType:(NSString *)type {
	NSMutableArray * data = [[self fetchActivitiesBetweenStartDate:startDate andEndDate:endDate ofType:type] mutableCopy];
	NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"total_distance" ascending:NO];
	[data sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	if ([data count] > 0)  {
		return [data objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(Activity *) getLongestActivityBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate ofType:(NSString *)type {
	NSMutableArray * data = [[self fetchActivitiesBetweenStartDate:startDate andEndDate:endDate ofType:type] mutableCopy];
	NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO];
	[data sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	if ([data count] > 0)  {
		return [data objectAtIndex: 0];
	}
	else {
		return nil;
	}
}

-(Activity *) getLongestRunAfterDate:(NSDate *)date {
	NSMutableArray * runs = [[self fetchActivitiesAfterDate: date ofType: @"Running"] mutableCopy];
	NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"total_distance" ascending:NO];
	[runs sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	return [runs objectAtIndex: 0];
}

-(Activity *) getQuickestRunAfterDate:(NSDate *)date {
	NSMutableArray * runs = [[self fetchActivitiesAfterDate : date ofType : @"Running"] mutableCopy];
	NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO];
	[runs sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	return [runs objectAtIndex: 0];
}

-(Activity *) getFastestRunAfterDate:(NSDate *)date {
	NSMutableArray * runs = [[self fetchActivitiesAfterDate: date ofType: @"Running"] mutableCopy];
	NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"speed" ascending:NO];
	[runs sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	return [runs objectAtIndex: 0];
}

-(Activity *) getLastRun {
	return [self getLastActivityOfType: @"Running"];
}

-(Activity *) getFirstActivity {
	NSMutableArray * runs = [[self fetchActivities: @""] mutableCopy];
	Activity * retval = nil;
	if ([runs count] > 0) {
		NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"start_time" ascending:YES];
		[runs sortUsingDescriptors:[NSArray arrayWithObject:sort]];
		retval = [runs objectAtIndex:0];
	}
	return retval;
}

-(Activity *) getFirstActivityOfType : (NSString *) type {
	NSMutableArray * runs = [[self fetchActivities : type] mutableCopy];
	Activity * retval = nil;
	if ([runs count] > 0) {
		NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"start_time" ascending:YES];
		[runs sortUsingDescriptors:[NSArray arrayWithObject:sort]];
		retval = [runs objectAtIndex:0];
	}
	return retval;
}

-(Activity *) getLastActivity {
	NSMutableArray * runs = [[self fetchActivities: @""] mutableCopy];
	Activity * retval = nil;
	if ([runs count] > 0) {
		NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"start_time" ascending:NO];
		[runs sortUsingDescriptors:[NSArray arrayWithObject:sort]];
		retval = [runs objectAtIndex:0];
	}
	return retval;
}


-(Activity *) getLastActivityOfType : (NSString *) type {
	NSMutableArray * runs = [[self fetchActivities : type] mutableCopy];
	Activity * retval = nil;
	if ([runs count] > 0) {
		NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"start_time" ascending:NO];
		[runs sortUsingDescriptors:[NSArray arrayWithObject:sort]];
		retval = [runs objectAtIndex:0];
	}
	return retval;
}

#pragma mark - Core Data stack

- (void)saveContext
{
	FT_SAVE_MOC(self.managedObjectContext)
	/*
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[[[UIAlertView alloc ]
				initWithTitle: @"Internal Error" 
				message: [NSString stringWithFormat: @"%@", [error userInfo]]
				delegate:nil 
				cancelButtonTitle: @"OK" 
				otherButtonTitles: nil] show];
            //abort();
        } 
    }*/
}

-(void) postActivities {
	RunKeeper * rk = [RunKeeper sharedInstance];
	NSArray * list = [self fetchAllActivities];
	for(int i = 0; i < [list count]; i++) {
		Activity * a = [list objectAtIndex:i];
		[rk postNewActivity: a.id];
		NSLog(@"%d of %d", i + 1, [list count]);
	}

}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StativityModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
	
	//[self createEditableCopyOfDatabaseIfNeeded];
	//NSString *urlPath = [[NSBundle mainBundle] pathForResource:@"NikePlusData" ofType:@"sqlite"];
    //NSURL * storeURL = [NSURL URLWithString: urlPath];
	
	// used to be NikePlusData.sqlite - myruns.sqllite
	NSString * dbName = @"mrs_v1.0.sqlite";
	/*
	#if LITE
		dbName = @"mrslite_v1.0.sqlite";
	#endif*/
	
	NSURL *storeURL = [[self applicationDocumentsDirectory] 
		URLByAppendingPathComponent: dbName];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
		initWithManagedObjectModel: self.managedObjectModel];
		
	// request automatic migration
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
		[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![__persistentStoreCoordinator 
			addPersistentStoreWithType:NSSQLiteStoreType 
			configuration:nil URL:storeURL options: options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; 
		  consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[[UIAlertView alloc ]
				initWithTitle: @"Internal Error" 
				message: [NSString stringWithFormat: @"%@", [error userInfo]]
				delegate:nil 
				cancelButtonTitle: @"OK" 
				otherButtonTitles: nil] show];
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] 
		URLsForDirectory:NSDocumentDirectory 
		inDomains:NSUserDomainMask] 
		lastObject];
}


@end
