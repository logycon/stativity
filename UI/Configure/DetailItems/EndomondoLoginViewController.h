//
//  EndomondoLoginViewController.h
//  Stativity
//
//  Created by Igor Nakshin on 8/16/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityViewController.h"

@interface EndomondoLoginViewController : StativityViewController
	<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *tbEmail;
@property (strong, nonatomic) IBOutlet UITextField *tbPassword;

@end
