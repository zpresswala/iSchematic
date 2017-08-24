//
//  TPCCellViewCell.m
//  iSchematic
//
//  Created by Navas on 04/07/13.
//  Copyright (c) 2013 Affluent. All rights reserved.
//

#import "TPCCellViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "TPCLabelView.h"

@class TPCCellViewCell;

@implementation TPCCellViewCell

@synthesize moduleImageLeft;
@synthesize lbl0Left;
@synthesize lbl1Left;
@synthesize pViewLeft;
@synthesize badgeViewLeft;
@synthesize imageLeft;
@synthesize singleTapLeft;
@synthesize singleTapLabel0Left;
@synthesize singleTapLabel1Left;
//@synthesize longPressLeft;

@synthesize moduleImageRight;
@synthesize lbl0Right;
@synthesize lbl1Right;
@synthesize pViewRight;
@synthesize badgeViewRight;
@synthesize imageRight;
@synthesize singleTapRight;
@synthesize singleTapLabel0Right;
@synthesize singleTapLabel1Right;
//@synthesize longPressRight;

//static float offsetX = 0;
//static float offsetY = 0;
//static float offsetProgressY = 60;
//static float lbl0Width = 300;
//static float lbl1Width = 200;
//static float btnWidth = 75;
//static float height = 75;

static float scale = 3;
static float lblOffsetX = 32;
static float lbl0OffsetY = 9;
static float lbl1OffsetY = 17;
static float lblWidth = 400;
static float lblHeight = 30;
static float imgWidth = 32;
static float imgHeight = 32;
static float offsetRight = 512;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        moduleImageLeft = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, imgWidth*scale, imgHeight*scale)];
        imageLeft = [[UIImageView alloc]initWithFrame:CGRectMake(-5, -5, (imgWidth*scale), (imgHeight*scale))];
        moduleImageLeft.layer.cornerRadius = 5.0*scale;
        moduleImageLeft.layer.masksToBounds = YES;
        moduleImageLeft.layer.borderColor = [UIColor lightGrayColor].CGColor;
        moduleImageLeft.layer.borderWidth = 1.0;
        lbl0Left = [[TPCLabelView alloc]init];
        lbl1Left = [[TPCLabelView alloc]init];
        pViewLeft = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        badgeViewLeft = [[MKNumberBadgeView alloc]initWithFrame:CGRectMake(((32*scale)-22), -1, 45, 25)];
        singleTapLeft = [[UITapGestureRecognizer alloc] init];
        singleTapLabel0Left = [[UITapGestureRecognizer alloc] init];
        singleTapLabel1Left = [[UITapGestureRecognizer alloc] init];

//        longPressLeft = [[UILongPressGestureRecognizer alloc]init];
        
        [self setLabel0Property:lbl0Left:@"L"];
        [self setLabel1Property:lbl1Left:@"L"];
        [self setProgressViewProperty:pViewLeft:@"L"];
        
        [singleTapLeft setNumberOfTapsRequired:1];
        [moduleImageLeft addGestureRecognizer:singleTapLeft];
        
        [singleTapLabel0Left setNumberOfTapsRequired:1];
        [lbl0Left addGestureRecognizer:singleTapLabel0Left];
        
        [singleTapLabel1Left setNumberOfTapsRequired:1];
        [lbl1Left addGestureRecognizer:singleTapLabel1Left];
        
//        [lbl1Left addGestureRecognizer:singleTapLeft];
//        [moduleImageLeft addGestureRecognizer:longPressLeft];
        
        [self.contentView addSubview:moduleImageLeft];
        [self.contentView addSubview:imageLeft];
        [self.contentView addSubview:lbl0Left];
        [self.contentView addSubview:lbl1Left];
        [self.contentView addSubview:pViewLeft];
        [self.contentView addSubview:badgeViewLeft];
        
        moduleImageRight = [[UIImageView alloc]initWithFrame:CGRectMake(0+offsetRight, 5, imgWidth*scale, imgHeight*scale)];
        imageRight = [[UIImageView alloc]initWithFrame:CGRectMake(0+offsetRight-5, -5, imgWidth*scale, imgHeight*scale)];
        moduleImageRight.layer.cornerRadius = 5.0*scale;
        moduleImageRight.layer.masksToBounds = YES;
        moduleImageRight.layer.borderColor = [UIColor lightGrayColor].CGColor;
        moduleImageRight.layer.borderWidth = 1.0;
        lbl0Right = [[TPCLabelView alloc]init];
        lbl1Right = [[TPCLabelView alloc]init];
        pViewRight = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        badgeViewRight = [[MKNumberBadgeView alloc]initWithFrame:CGRectMake((((32*scale)-22)+offsetRight), -1, 45, 25)];
        singleTapRight = [[UITapGestureRecognizer alloc] init];
        singleTapLabel0Right = [[UITapGestureRecognizer alloc] init];
        singleTapLabel1Right = [[UITapGestureRecognizer alloc] init];

//        longPressRight = [[UILongPressGestureRecognizer alloc]init];
        
        [self setLabel0Property:lbl0Right:@"R"];
        [self setLabel1Property:lbl1Right:@"R"];
        [self setProgressViewProperty:pViewRight:@"R"];
        
        [singleTapRight setNumberOfTapsRequired:1];
        [moduleImageRight addGestureRecognizer:singleTapRight];
        
        [singleTapLabel0Right setNumberOfTapsRequired:1];
        [lbl0Right addGestureRecognizer:singleTapLabel0Right];
        
        [singleTapLabel1Right setNumberOfTapsRequired:1];
        [lbl1Right addGestureRecognizer:singleTapLabel1Right];
        
        
//        [lbl0Right addGestureRecognizer:singleTapRight];
//        [lbl1Right addGestureRecognizer:singleTapRight];
//        [moduleImageRight addGestureRecognizer:longPressRight];
        
        [self.contentView addSubview:moduleImageRight];
        [self.contentView addSubview:imageRight];
        [self.contentView addSubview:lbl0Right];
        [self.contentView addSubview:lbl1Right];
        [self.contentView addSubview:pViewRight];
        [self.contentView addSubview:badgeViewRight];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void) setLabel0Property:(UILabel *)lbl :(NSString *) side
{
    if([side isEqualToString:@"L"])
        [lbl setFrame:CGRectMake((lblOffsetX*scale)+5, lbl0OffsetY*scale, lblWidth, lblHeight)];
    else
       [lbl setFrame:CGRectMake((lblOffsetX*scale)+5+offsetRight, lbl0OffsetY*scale, lblWidth, lblHeight)];
    [lbl setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
    [lbl setTextColor:[self colorWithHexString:@"264178"]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setUserInteractionEnabled:YES];
    [lbl setNumberOfLines:0];
}

- (void) setLabel1Property:(UILabel *)lbl :(NSString *) side
{
    if([side isEqualToString:@"L"])
        [lbl setFrame:CGRectMake((lblOffsetX*scale)+5, lbl1OffsetY*scale, lblWidth, lblHeight)];
    else
        [lbl setFrame:CGRectMake((lblOffsetX*scale)+5+offsetRight, lbl1OffsetY*scale, lblWidth, lblHeight)];
    [lbl setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    [lbl setTextColor:[self colorWithHexString:@"F26522"]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setUserInteractionEnabled:YES];
    [lbl setNumberOfLines:0];
}

- (void) setProgressViewProperty:(UIProgressView *)pView :(NSString *) side
{
    if([side isEqualToString:@"L"])
        [pView setFrame:CGRectMake(5, ((imgHeight*scale)-12), ((32*scale)-10), 10)];
    else
        [pView setFrame:CGRectMake(5+offsetRight, ((imgHeight*scale)-12), ((32*scale)-10), 10)];
    [pView setTag:99];
    [pView setHidden:NO];
    //[pView setProgress:floatValue];
}

- (UIColor *) colorWithHexString: (NSString *) hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6) return [UIColor grayColor];
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return  [UIColor grayColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
