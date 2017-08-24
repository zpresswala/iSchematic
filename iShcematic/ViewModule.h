//
//  ModuleViewer.h
//  iSch
//
//  Created by Navas on 09/06/13.
//  Copyright (c) 2013 Navas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPopupWindow.h"
//#import "MBProgressHUD.h"


@interface ViewModule : UIViewController<UIWebViewDelegate, UIGestureRecognizerDelegate, MTPopupWindowDelegate>
{
    NSString *filepath;
    NSString *mname;
    NSString *mode;
    //MBProgressHUD *HUD;
    NSString *User;
    NSString *userName;
    UIWebView *webView;
    UIView *uView;
    MTPopupWindow *winPop;
}
@property(nonatomic,retain)NSString *filepath;
@property(nonatomic,retain)NSString *mname;
@property(nonatomic,retain)NSString *mode;
@property(nonatomic,retain)NSString *User;
@property(nonatomic,retain)NSString *userName;
@property(nonatomic,retain)UIWebView *webView;
@property(nonatomic,retain)UIView *uView;
@property(nonatomic,retain)MTPopupWindow *winPop;
//+ (void)getURL;

@end
