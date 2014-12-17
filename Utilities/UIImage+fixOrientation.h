//
//  UIImage+fixOrientation.h
//  Stativity
//
//  Created by Igor Nakshin on 7/21/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;

@end
