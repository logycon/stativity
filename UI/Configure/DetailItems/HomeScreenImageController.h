//
//  HomeScreenImageController.h
//  Stativity
//
//  Created by Igor Nakshin on 7/19/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StativityViewController.h"

@interface HomeScreenImageController : StativityViewController
	<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet UIButton *btnChange;
@property (strong, nonatomic) IBOutlet UIButton *btnUserDefault;
@property (strong, nonatomic) IBOutlet UISlider *sliderOpacity;

@end
