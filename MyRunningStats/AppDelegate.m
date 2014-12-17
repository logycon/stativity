//
//  AppDelegate.m
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "LeftMenuViewController.h"
#import "Utilities.h"
#import "StativityData.h"
#import "Me.h"
#import "Flurry.h"
#import "RunKeeper.h"
#import "TargetConditionals.h"
#import "WelcomeViewController.h"
#import "iRate.h"
#import "iVersion.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize leftController;
@synthesize deckController;

int signalCount = 0;

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

// runkeeper oauth callback
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	[[RunKeeper sharedInstance] handleOpenURL: url];
	return true;
}

-(void) showMessage : (NSString *) msg {
	UIAlertView * alert = [[UIAlertView alloc]
		initWithTitle: @"Alert" 
		message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		
	[alert show];
}


void uncaughtExceptionHandler(NSException *exception)
{
	NSString * exceptionName = [exception name];
	
	[Flurry logError:@"Uncaught Exception"
			message: exceptionName
            exception:exception];
			
			/*
	UIAlertView * alert = [[UIAlertView alloc] 
		initWithTitle: @"Error" 
	message: [NSString stringWithFormat : @"Error has occurred and has been reported : %@", exception]
	delegate:nil 
	cancelButtonTitle: @"OK" 
	otherButtonTitles: nil];*/
}

void SignalHandler(int signal)
{
/*
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	*/
	
	/*
	NSMutableDictionary *userInfo =
		[NSMutableDictionary
			dictionaryWithObject:[NSNumber numberWithInt:signal]
			forKey:UncaughtExceptionHandlerSignalKey];

	*/
	
	signalCount++;
	if (signalCount > 2) {
		return;
	}
	
	NSException * ex = [NSException
				exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
				reason:
					[NSString stringWithFormat:
						NSLocalizedString(@"Signal %d was raised.", nil),
						signal]
				userInfo:
					[NSDictionary
						dictionaryWithObject:[NSNumber numberWithInt:signal]
						forKey: @"UncaughtExceptionHandlerSignalKey"]];
			
	
	
	uncaughtExceptionHandler(ex);
			
}

+(void) initialize {
	

	//[iRate sharedInstance].applicationBundleID = @"com.logycon.Stativity";
	iRate * i_rate = [iRate sharedInstance];
		i_rate.appStoreID = 548122166;
		//i_rate.applicationBundleID = @"com.logycon.Stativity";
	//i_rate.appStoreID = 548122166;
	i_rate.onlyPromptIfLatestVersion = NO;
	
	iVersion * i_version = [iVersion sharedInstance];
		//i_version.applicationBundleID = @"com.logycon.Stativity";
		i_version.appStoreID = 548122166;
	i_version.checkAtLaunch = NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	#if !(TARGET_IPHONE_SIMULATOR)
	[Flurry startSession:@"F4TCKMWQJ2TX86KPWRR3"]; //83YQWR69GKP3RGJ4JNVF
	
		/*
	[Parse setApplicationId:@"8OIIG0Uz4h6sfHLJDX7fyz7F3yjgvtZLHlf3rds3"
              clientKey:@"KCSf3zYlsnBcLtWw1aOIYWJMIfb0iPjDmPDop2bC"];
	*/
	#endif
	
	
	signal(SIGABRT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGPIPE, SignalHandler);
	
	//#endif
	
	// debug welcome screen
	//[[NSUserDefaults standardUserDefaults] setObject:nil forKey: @"hello"];
	//[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSString * hello = [[NSUserDefaults standardUserDefaults] objectForKey: @"hello"];
	if (!hello) {
	     [[RunKeeper sharedInstance] disconnect];
		 UIStoryboard * mainStoryBoard = [UIStoryboard storyboardWithName: @"MainStoryboard" bundle:nil];
		 WelcomeViewController * welcome = [mainStoryBoard instantiateViewControllerWithIdentifier: @"welcome"];
		 welcome.appDelegate = self;
		 self.window.rootViewController = welcome;
		 [self.window makeKeyAndVisible];
	}
	else {
		UILocalNotification * notification = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
		if (notification) {
			UIAlertView * alert = [[UIAlertView alloc]
				initWithTitle: notification.alertAction 
				message: notification.alertBody 
				delegate:nil 
				cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[alert show];
			[[UIApplication sharedApplication] cancelLocalNotification: notification];
		}
		[self normalLoad];
	}
    return YES;
}



-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	if (notification) {
		UIAlertView * alert = [[UIAlertView alloc]
			initWithTitle: notification.alertAction 
			message: notification.alertBody 
			delegate:nil 
			cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[alert show];
		[[UIApplication sharedApplication] cancelLocalNotification: notification];
	}
}

-(void) normalLoad {
	NSString * newUser = [[NSUserDefaults standardUserDefaults] objectForKey: @"newUser"];
	if (!newUser) {
		[[NSUserDefaults standardUserDefaults] setValue: @"no" forKey: @"newUser"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[Flurry logEvent: @"New User"];
	}

	[[NSUserDefaults standardUserDefaults] setObject: @"hello" forKey: @"hello"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	//if (![Me getElite]) {
		StativityData * rkd = [StativityData get];
		[rkd updateProfile];
	//}
	
	// setup left menu controller
	UIStoryboard * mainStoryBoard = [UIStoryboard storyboardWithName: @"MainStoryboard" bundle:nil];
	self.leftController = [mainStoryBoard instantiateViewControllerWithIdentifier: @"left_menu"];
	
	deckController =  [[IIViewDeckController alloc] 
		initWithCenterViewController: mainStoryBoard.instantiateInitialViewController 
		leftViewController : self.leftController
		rightViewController: nil];
	
	deckController.panningMode = IIViewDeckPanningViewPanning; // IIViewDeckNoPanning;
	deckController.rightLedge = 100;
	deckController.leftLedge = 100; //160;
	
	//deckController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
	
	BOOL ratePrompted = NO;
	iRate * i_rate = [iRate sharedInstance];
	if (i_rate.usesCount > 10) {
		if (!i_rate.declinedThisVersion || !i_rate.ratedThisVersion) {
			ratePrompted = YES;
			[i_rate promptForRating];
			i_rate.usesCount = 0;
		}
	}
	
	if (!ratePrompted) {
		iVersion * i_version = [iVersion sharedInstance];
		[i_version checkForNewVersion];
	}
	
	
}
		
-(BOOL) iVersionShouldCheckForNewVersion {
	return YES;
}

-(void) iVersionDidNotDetectNewVersion {
	//NSLog(@"No new version");
}

- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails; {
	UIAlertView * alert = [[UIAlertView alloc]
		initWithTitle: @"New Version" 
		message: [NSString stringWithFormat : @"Stativity v%@ is now available on the App Store.", version]
		delegate: self 
		cancelButtonTitle: @"Later" otherButtonTitles: @"Get it Now", nil];
		[alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[[iVersion sharedInstance] openAppPageInAppStore];
	}
}
																	
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
