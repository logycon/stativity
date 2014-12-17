//
//  MeIDController.h
//  Stativity
//
//  Created by Igor Nakshin on 6/3/12.
//  Copyright (c) 2012 Logycon Corporation All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityTableViewController.h"

@interface MeIDController : StativityTableViewController

@property (strong, nonatomic) IBOutlet UITextField *textBoxID;
@property (strong, nonatomic) IBOutlet UINavigationBar *myNavigationBar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSave;

@property (weak, nonatomic) id sender;

-(void) configureView;
-(void) runsLoaded;

@end
