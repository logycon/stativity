//
//  UIColor+Tools.m
//  Stativity
//
//  Created by Igor Nakshin on 7/15/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "UIColor+Tools.h"

@implementation UIColor (Tools)

-(UIColor *) colorByAdjustingLuminocityByFactorOf : (float) factor {
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	CGFloat newComponents[4];
 
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
 
	switch (numComponents)
	{
		case 2:
		{
			//grayscale
			newComponents[0] = oldComponents[0]*factor;
			newComponents[1] = oldComponents[0]*factor;
			newComponents[2] = oldComponents[0]*factor;
			newComponents[3] = oldComponents[1];
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0]*factor;
			newComponents[1] = oldComponents[1]*factor;
			newComponents[2] = oldComponents[2]*factor;
			newComponents[3] = oldComponents[3];
			break;
		}
	}
 
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
 
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
 
	return retColor;
}

- (UIColor *)colorByChangingAlphaTo:(CGFloat)newAlpha {
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
	CGFloat newComponents[4];
 
	switch (numComponents)
	{
		case 2:
		{
			//grayscale
			newComponents[0] = oldComponents[0];
			newComponents[1] = oldComponents[0];
			newComponents[2] = oldComponents[0];
			newComponents[3] = newAlpha;
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0];
			newComponents[1] = oldComponents[1];
			newComponents[2] = oldComponents[2];
			newComponents[3] = newAlpha;
			break;
		}
	}
 
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
 
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
 
	return retColor;
}



 

@end
