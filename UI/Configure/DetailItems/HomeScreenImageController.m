//
//  HomeScreenImageController.m
//  Stativity
//
//  Created by Igor Nakshin on 7/19/12.
//  Copyright (c) 2012 Logycon Corporation, Inc. All rights reserved.
//

#import "HomeScreenImageController.h"
#import "Me.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreGraphics/CoreGraphics.h>
#import "UIImage+fixOrientation.h"

@interface HomeScreenImageController ()

@property (nonatomic, strong) NSString * pickedImage;
@property (nonatomic, strong) UIImagePickerController * imagePicker;

@end

@implementation HomeScreenImageController

@synthesize myNavigationBar;
@synthesize btnDone;
@synthesize btnCancel;
@synthesize myImageView;
@synthesize btnChange;
@synthesize btnUserDefault;
@synthesize sliderOpacity;
@synthesize pickedImage;
@synthesize imagePicker;

-(void) updateUI {
	UIColor * uiColor = [Me getUIColor];
	[myNavigationBar setTintColor: uiColor];
	/*
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
			[Me getTextColor],UITextAttributeTextColor, 
			[UIColor clearColor], UITextAttributeTextShadowColor, nil];
	[myNavigationBar setTitleTextAttributes: attributes];	*/
	
	[btnDone setTintColor: uiColor];
	//[btnDone setTitleTextAttributes: attributes forState: UIControlStateNormal];
	[btnCancel setTintColor: uiColor];
	//[btnCancel setTitleTextAttributes: attributes forState: UIControlStateNormal];
	[btnChange setTintColor: uiColor];
	//[btnCancel setTitleTextAttributes: attributes forState: UIControlStateNormal];
	[btnUserDefault setTintColor: uiColor];
	//[btnUserDefault setTitleTextAttributes: attributes forState: UIControlStateNormal];
}

static inline double radians (double degrees) {return degrees * M_PI/180;}

-(UIImage *) imageFromSource : (UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
{
	targetSize = CGSizeMake(330, 380);
   
	//targetSize = CGSizeMake(320, 480);
	CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }

        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		

        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
		
		// fitting into 320 x 480, calculate 320
		
    }     

    CGContextRef bitmap;
    CGImageRef imageRef = [sourceImage CGImage];
    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown)
    {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, 8, 4 * targetWidth, genericColorSpace, kCGImageAlphaPremultipliedFirst);

    }
    else
    {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, 8, 4 * targetWidth, genericColorSpace, kCGImageAlphaPremultipliedFirst);

    }   

    CGColorSpaceRelease(genericColorSpace);
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationDefault);

    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft)
    {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;

        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);

    }
    else if (sourceImage.imageOrientation == UIImageOrientationRight)
    {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;

        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);

    }
    else if (sourceImage.imageOrientation == UIImageOrientationUp)
    {
        // NOTHING
    }
    else if (sourceImage.imageOrientation == UIImageOrientationDown)
    {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }

    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];

    CGContextRelease(bitmap);
    CGImageRelease(ref);

    return newImage;  
}

-(void) displayPickedImage  {
	NSString * imagePath = pickedImage;
	UIImage * image = [UIImage imageNamed : imagePath];
	if (!image) {
		NSURL *url = [NSURL URLWithString: imagePath];
		UIImage * __block image = nil;
		
		ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
		{
			ALAssetRepresentation *rep = [myasset defaultRepresentation];
			CGImageRef iref = [rep fullScreenImage];
			if (iref) {
				image = [UIImage imageWithCGImage : iref];
				//image = [image fixOrientation];
				UIImage * newImage = [self imageFromSource: image scaledToSizeWithSameAspectRatio: self.myImageView.bounds.size];
				
				// save to userHome.png
				NSData* imageData = UIImagePNGRepresentation(newImage);
				NSString* imageName = @"userHome.png";

				// Now, we have to find the documents directory so we can save it
				// Note that you might want to save it elsewhere, like the cache directory,
				// or something similar.
				NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString* documentsDirectory = [paths objectAtIndex:0];

				// Now we get the full path to the file
				NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];

				// and then we write it out
				[imageData writeToFile:fullPathToFile atomically:NO];
				
				// display
				UIImage * userHome = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/userHome.png", documentsDirectory]];
				self.myImageView.image = userHome;
				self.myImageView.alpha = self.sliderOpacity.value;
				self.myImageView.contentMode = UIViewContentModeScaleAspectFit;
			}
        };
		
    	ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
		{
			NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
		};
		
		ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL: url 
                       resultBlock:resultblock
                      failureBlock:failureblock];
		
	}
	else {
		self.myImageView.image = image;
		self.myImageView.alpha = self.sliderOpacity.value;
	
	}
}

-(void) initUI {
	NSString * imageName = [Me getHomeScreenImageName];
	pickedImage = imageName;
	self.sliderOpacity.value = [[Me getHomeImageOpacity] floatValue];
	[self displayPickedImage];
}

- (IBAction)opacityChanged:(id)sender {
	self.myImageView.alpha = self.sliderOpacity.value;
}

- (IBAction)btnCancelClick:(id)sender {
	[self dismissModalViewControllerAnimated: YES];
}

- (IBAction)btnDoneClicked:(id)sender {
	[Me setHomeScreenImage: pickedImage];
	[Me setHomeImageOpacity: [NSNumber numberWithFloat: self.sliderOpacity.value]];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"HomeScreenImageChanged" object: nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnChangeClick:(id)sender {
	if (!imagePicker) {
		imagePicker=[[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	}
	[self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)btnUseDefaultClick:(id)sender {
	[Me setHomeScreenImage: @"road.png"];
	[self initUI];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}

/*
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
}*/

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
	[picker dismissModalViewControllerAnimated:YES];
	NSURL* localUrl = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
	pickedImage = localUrl.absoluteString;
	[self displayPickedImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateUI];
	[self initUI];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	[self setMyNavigationBar:nil];
	[self setBtnDone:nil];
	[self setBtnCancel:nil];
	[self setMyImageView:nil];
	[self setBtnChange:nil];
	[self setBtnUserDefault:nil];
	[self setSliderOpacity:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
