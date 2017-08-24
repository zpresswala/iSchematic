//
//  AlertViewBlocks.h
//  multipleAlertViews
//
//  Created by abdus on 2/14/13.
//  Copyright (c) 2013 abdus. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIAlertView (AddBlockCallBacks) <UIAlertViewDelegate>

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
