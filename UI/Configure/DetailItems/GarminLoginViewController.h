//
//  GarminLoginViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 9/3/12.
//  Copyright (c) 2012 Optimal Strategix Group, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityViewController.h"

@interface GarminLoginViewController : StativityViewController
	<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *tbEmail;
@property (strong, nonatomic) IBOutlet UITextField *tbPassword;

@end
