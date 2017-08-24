//
//  TPCCellViewCell.h
//  iSchematic
//
//  Created by Navas on 04/07/13.
//  Copyright (c) 2013 Affluent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNumberBadgeView.h"

@interface TPCCellViewCell : UITableViewCell
{
    UIImageView *moduleImageLeft;
    UIImageView *imageLeft;
    UILabel *lbl0Left;
    UILabel *lbl1Left;
    UIProgressView *pViewLeft;
    MKNumberBadgeView *badgeViewLeft;
    UITapGestureRecognizer *singleTapLeft;
    UITapGestureRecognizer *singleTapLable0Left;
    UITapGestureRecognizer *singleTapLable1Left;

    //UILongPressGestureRecognizer *longPressLeft;
    
    UIImageView *moduleImageRight;
    UIImageView *imageRight;
    UILabel *lbl0Right;
    UILabel *lbl1Right;
    UIProgressView *pViewRight;
    MKNumberBadgeView *badgeViewRight;
    UITapGestureRecognizer *singleTapRight;
    UITapGestureRecognizer *singleTapLable0Right;
    UITapGestureRecognizer *singleTapLable1Right;
    
    //UILongPressGestureRecognizer *longPressRight;
}

@property(nonatomic, retain) UIImageView *moduleImageLeft;
@property(nonatomic, retain) UIImageView *imageLeft;
@property(nonatomic, retain) UILabel *lbl0Left;
@property(nonatomic, retain) UILabel *lbl1Left;
@property(nonatomic, retain) UIProgressView *pViewLeft;
@property(nonatomic, retain) MKNumberBadgeView *badgeViewLeft;
@property(nonatomic, retain) UITapGestureRecognizer *singleTapLeft;
@property(nonatomic, retain) UITapGestureRecognizer *singleTapLabel0Left;
@property(nonatomic, retain) UITapGestureRecognizer *singleTapLabel1Left;

//@property(nonatomic, retain) UILongPressGestureRecognizer *longPressLeft;

@property(nonatomic, retain) UIImageView *moduleImageRight;
@property(nonatomic, retain) UIImageView *imageRight;
@property(nonatomic, retain) UILabel *lbl0Right;
@property(nonatomic, retain) UILabel *lbl1Right;
@property(nonatomic, retain) UIProgressView *pViewRight;
@property(nonatomic, retain) MKNumberBadgeView *badgeViewRight;
@property(nonatomic, retain) UITapGestureRecognizer *singleTapRight;
@property(nonatomic, retain) UITapGestureRecognizer *singleTapLabel0Right;
@property(nonatomic, retain) UITapGestureRecognizer *singleTapLabel1Right;

//@property(nonatomic, retain) UILongPressGestureRecognizer *longPressRight;

@end
