//
//  HeaderView.m
//  HeaderWithArrowDemo
//
//  Created by Derek Yang on 05/04/12.
//  Copyright (c) 2012 Derek Yang. All rights reserved.
//

#import "HeaderView.h"
#import "Utilities.h"
#import "Me.h"
#import "UIColor+Tools.h"

#define ARROW_LEFT_X 13 //26

@interface HeaderView ()

@property(nonatomic, retain) UIImage *avatarImage;
@property(nonatomic, retain) UIImage *arrowImage;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UILabel * rightLabel;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * rightText;

- (void)initializeState;
- (void)setUpArrow:(CGRect)frame;

- (void)drawAvatar:(CGContextRef)context;
- (void)drawBackgroundIn:(CGRect)rect context:(CGContextRef)context;

@end

@implementation HeaderView

@synthesize avatarImage = _avatarImage;
@synthesize arrowImage = _arrowImage;
@synthesize label = _label;
@synthesize rightLabel = _rightLabel;
@synthesize text = _text;
@synthesize rightText = _rightText;


- (id)initWithFrame:(CGRect)frame andText : (NSString *) text  andRightText:(NSString *)rightText {
    self = [super initWithFrame:frame];
    if (self) {
		self.text = text;
		self.rightText = rightText;
        [self initializeState];
        [self setUpArrow:frame];
		[self setupLabel : frame];
		[self setupRightLabel : frame];
    }
    return self;
}

- (void)initializeState {
    self.alpha = 0.9;
    self.backgroundColor = [UIColor clearColor];
    self.avatarImage = [UIImage imageNamed:@"avatar.png"];
    self.arrowImage = [UIImage imageNamed:@"smallarrow.png"];
}

- (void)setUpArrow:(CGRect)frame {
    // Set up an imageView in order to display the arrow - The image view is placed right below the bottom so that
    // the arrow appears 'peeking out'
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:self.arrowImage];
    arrowImageView.frame = CGRectMake(ARROW_LEFT_X, frame.size.height, self.arrowImage.size.width, self.arrowImage.size.height);
    arrowImageView.alpha = 0.6;
    [self addSubview:arrowImageView];
}

-(void) setupLabel : (CGRect) frame {
	if (!_label) {
		CGRect labelFrame = frame;
		labelFrame.origin.x = 10;
		_label = [[UILabel alloc] initWithFrame: labelFrame];
		_label.backgroundColor = [UIColor clearColor];
		_label.textColor = [UIColor whiteColor];
		_label.font = [UIFont fontWithName: [Utilities fontFamily] size: 15];
		_label.text = [@" " stringByAppendingString : _text];
		_label.textAlignment = UITextAlignmentLeft;
		[self addSubview: _label];
	}
}

-(void) setupRightLabel : (CGRect) frame {
	if (!_rightLabel) {
		CGRect labelFrame = CGRectMake(10, frame.origin.y, frame.size.width - 20, frame.size.height);
	//	labelFrame.origin.x = 10;
	//	labelFrame.size.width -= 10;
		_rightLabel = [[UILabel alloc] initWithFrame: labelFrame];
		_rightLabel.backgroundColor = [UIColor clearColor];
		_rightLabel.textColor = [UIColor whiteColor];
		_rightLabel.font = [UIFont fontWithName: [Utilities fontFamily] size: 15];
		_rightLabel.text = [@" " stringByAppendingString : _rightText];
		_rightLabel.textAlignment = UITextAlignmentRight;
		[self addSubview: _rightLabel];
	}
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBackgroundIn:rect context:context];
    [self drawAvatar:context];
}

- (void)drawBackgroundIn:(CGRect)rect context:(CGContextRef)context {
    // Draws the dark area which serves as the background of the entire header view. Other views (such as avatar and slider)
    // will be all drawn on top of this.
	UIColor * bgColor = [UIColor colorWithRed:47.0 / 255.0 green:47.0 / 255.0 blue:47.0 / 255.0 alpha:0.6];
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextAddRect(context, rect);
    CGContextFillPath(context);
}

- (void)drawAvatar:(CGContextRef)context {
/*
    CGRect avatarRect = CGRectMake(10, 10, 46, 46);
    UIBezierPath *avatarPath = [UIBezierPath bezierPathWithRoundedRect:avatarRect cornerRadius:4];
    CGContextAddPath(context, avatarPath.CGPath);
    CGContextClip(context);
    [self.avatarImage drawInRect:avatarRect];
	*/
}

@end
