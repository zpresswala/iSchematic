//
//  ModuleViewer.m
//  iSch
//
//  Created by Navas on 09/06/13.
//  Copyright (c) 2013 Navas. All rights reserved.
//

#import "ViewModule.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewModule ()

@end

@implementation ViewModule

Utils *util;
@synthesize webView;
@synthesize filepath;
@synthesize mname;
@synthesize mode;
@synthesize User;
@synthesize userName;
@synthesize uView;
@synthesize winPop;


UIBarButtonItem *detailButton;
UIBarButtonItem *backButton;
UIBarButtonItem *popButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setTitle:mname];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    util = [[Utils alloc]init];
    BOOL success = [util initModuleDB];
    if(!success)
    {
        //NSLog(@"Database operation failed");
    }
    //NSLog(@"Viewing Module: %@", mname);
    [self.navigationItem setTitle:mname];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    webView.delegate = self;
    [webView setScalesPageToFit:YES];
    [self.view addSubview:webView];
    
    //HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	//[self.navigationController.view addSubview:HUD];
	//HUD.labelText = @"Connecting";
    
    [util setModuleViewStatus:filepath :User :@"N"];
    if([mode isEqualToString:@"online"])
    {
        [self loadOnlineModule];        
    }
    else if([mode isEqualToString:@"offline"])
    {
        [self loadOfflineModule];
    }
    else
    {

    }
    backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBackModule)];
    detailButton = [[UIBarButtonItem alloc]initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(viewSeqOfOp)];
    popButton = [[UIBarButtonItem alloc]initWithTitle:@"iSchematic - Home" style:UIBarButtonItemStylePlain target:self action:@selector(popView)];
    
    //UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc]initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(goForwardModule)];
    //UIBarButtonItem *zoomInButton = [[UIBarButtonItem alloc]initWithTitle:@"Zoom In" style:UIBarButtonItemStylePlain target:self action:@selector(moduleZoomIn)];
    //UIBarButtonItem *zoomOutButton = [[UIBarButtonItem alloc]initWithTitle:@"Zoom Out" style:UIBarButtonItemStylePlain target:self action:@selector(moduleZoomOut)];

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Scale to Fit" forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:14.0]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    CGRect buttonFrame = [button frame];
    buttonFrame.size.width = [@"Scale to Fit" sizeWithFont:[UIFont boldSystemFontOfSize:14.0]].width + 24.0;
    [button setFrame:buttonFrame];
    [detailButton setEnabled:NO];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:popButton,backButton, nil];
    
    winPop = [[MTPopupWindow alloc] init];
    [winPop setDelegate:self];
    
    uView = [[UIView alloc]init];
    [uView setFrame:CGRectMake(50, 50, 500, 600)];
    uView.center = self.view.center;
    uView.backgroundColor = [UIColor clearColor];
    uView.opaque = NO;
    uView.layer.cornerRadius = 25;
    uView.layer.masksToBounds = YES;
    
    util.isAskingForPIN = NO;
}

- (void) popView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewSeqOfOp
{

    //NSLog(@"Showing details;");
    NSString *currentURL = webView.request.URL.absoluteString;

    //NSLog(@"URL %@", currentURL);
    NSString *js1 = @"document.getElementById('HIDDEN_TABLET_TEMPLATE_CONTENT').innerHTML";
    NSString *res1 = [webView stringByEvaluatingJavaScriptFromString:js1];

    winPop.fileName = currentURL;
    winPop.htmlString = res1;
    winPop.webView1 = webView;
    [self.view addSubview:uView];
    [self.winPop showInView:uView];
    [backButton setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [detailButton setEnabled:NO];
    
}


-(void) switchTapped: (id) sender {
    UISwitch *switchControl = (UISwitch*) sender;
    BOOL value = switchControl.isOn;
    if(value)
        [webView setScalesPageToFit:YES];
    else
        [webView setScalesPageToFit:NO];
    
    [webView reload];
}

- (void) goBackModule
{
    [winPop closePopupWindow];
    [uView removeFromSuperview];
    
    if ([webView canGoBack]) {
        [webView goBack];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) goForwardModule
{
    if ([webView canGoForward]) {
        [webView goForward];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}



- (void) loadOnlineModule
{
    //NSLog(@"Online Module %@", filepath);
    NSURL *url1 = [NSURL URLWithString:filepath];
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url1];
    [webView loadRequest:requestObj];
}

- (void) loadOfflineModule
{
    filepath = [util getLocalPath:filepath];
    NSString *localURL = [filepath stringByAppendingString:@"_dir/start.html"];
    BOOL hasFile = [[NSFileManager defaultManager] fileExistsAtPath:localURL];
    if(hasFile)
    {
        //NSLog(@"Local File: %@", localURL);
        NSURL *url1 = [NSURL fileURLWithPath:localURL];
        [webView loadRequest:[NSURLRequest requestWithURL:url1]];
    }
    else
    {
        [webView loadHTMLString:@"<html><body bgcolor=\"#C0C0C0\"><br /><br /><center><h3><font face=\"Helvetica\">Some thing's not right. Please click on the [Re-Download] button to start downloading the module.</font></h3></center></body></html>" baseURL:[[NSBundle mainBundle] bundleURL]];
    }

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;	
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[HUD show:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //HUD hide:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *js1 = @"document.getElementById('HIDDEN_TABLET_TEMPLATE_CONTENT').innerHTML";
    NSString *res1 = [self.webView stringByEvaluatingJavaScriptFromString:js1];
    //NSLog(@"DIV len %i", res1.length);
    if(res1.length > 0)
    {
        [detailButton setTitle:@"View Details"];
        [detailButton setEnabled:YES];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: detailButton, nil];
    }
    else
    {
        //NSLog(@"Setting widht 0");
        [detailButton setTitle:@""];
        [detailButton setEnabled:NO];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: nil];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[HUD hide:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // This method is called whenever the view is going to appear onscreen.
        [super viewWillAppear:animated];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askForPIN) name:UIApplicationDidEnterBackgroundNotification object:nil];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    //webView.delegate = nil;
    //[webView removeFromSuperview];
    //webView = nil;
}

- (void) didCloseMTPopupWindow:(MTPopupWindow*)sender
{
    //NSLog(@"CLOSING");
    //NSLog(@"PATH: %@", sender.webView.request.URL.path);
    [detailButton setEnabled:YES];
    [backButton setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [uView removeFromSuperview];
}

- (void) askForPIN
{
    //NSLog(@"APP enters background");
    if(!util.isAskingForPIN)
        [util changePIN:NO:User];
}

@end
