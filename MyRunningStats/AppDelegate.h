//
//  AppDelegate.h
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "iVersion.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, iVersionDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) UIViewController *leftController;
@property (nonatomic, strong) IIViewDeckController * deckController;

-(void) normalLoad;

@end
