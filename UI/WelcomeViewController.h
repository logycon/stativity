//
//  WelcomeViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 7/15/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "StativityViewController.h"

@interface WelcomeViewController : StativityViewController

@property (nonatomic, weak) AppDelegate * appDelegate;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end
