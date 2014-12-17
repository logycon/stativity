//
//  UIColor+Tools.h
//  Stativity
//
//  Created by Igor Nakshin on 7/15/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Tools)
- (UIColor *) colorByAdjustingLuminocityByFactorOf:(float) factor;
- (UIColor *) colorByChangingAlphaTo : (CGFloat)newAlpha;
@end
