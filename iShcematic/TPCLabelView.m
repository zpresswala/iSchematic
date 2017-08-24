//
//  TPCLabelView.m
//  iSchematic
//
//  Created by Navas on 17/07/13.
//  Copyright (c) 2013 Affluent. All rights reserved.
//

#import "TPCLabelView.h"

@implementation TPCLabelView
static UIEdgeInsets insets = {0, 5, 0, 5};
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
