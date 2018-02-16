//
//  Dashboard.m
//  iSch
//
//  Created by Navas on 09/06/13.
//  Copyright (c) 2013 Navas. All rights reserved.
//

#import "Dashboard.h"
#import "ViewModule.h"
#import "Utils.h"
#import "ViewController.h"
#import "RequestQueue.h"
#import "SSZipArchive.h"
#import "AlertViewBlocks.h"
#import "AboutController.h"
#import "TPCCellViewCell.h"
#import "MBProgressHUD.h"
//#import "mach/mach.h"


@class Dashboard;

@interface Dashboard ()

@property (nonatomic, strong) NSMutableDictionary *downloadStatuses;
@property (nonatomic, strong) NSMutableDictionary *progressStatuses;
@property (nonatomic, strong) NSMutableDictionary *fileSizeDict;
@property (nonatomic, strong) NSMutableDictionary *resumeFileSizeDict;
@property (nonatomic, retain) NSTimer *myTimer;

@end

@implementation Dashboard

@synthesize data;
@synthesize hasInternet;
@synthesize downloadStatuses;
@synthesize progressStatuses;
@synthesize fileSizeDict;
@synthesize resumeFileSizeDict;
@synthesize User;
@synthesize userName;
@synthesize myTimer;
@synthesize userLabel;
@synthesize groupLabel;
@synthesize footerLabel;
@synthesize btns;
@synthesize pageControl;
@synthesize searchBar;


NSString *localPath;
NSString *localFile;
NSString *zipFolder;
NSString *filePath;
NSString *groupName;

UIImage *newImage;

NSString *row_mdownloadLeft;
NSString *row_statusLeft;
NSString *row_lbl1TextLeft;

NSString *row_mdownloadRight;
NSString *row_statusRight;
NSString *row_lbl1TextRight;

NSMutableArray *dataOriginal;

BOOL isDownloadingLeft;
BOOL isDownloadingRight;
BOOL isViewableLeft;
BOOL isViewableRight;

int objRow;
int badgeLevelLeft;
int badgeLevelRight;

ViewModule *view;
AboutController *ab;
TPCCellViewCell *tpc;

MBProgressHUD *hud;

NSFileManager *fm;

int pageCount;
int moduleCount;
int currentPage;
int mC = 5;

BOOL idleTimeFired;

Utils *util;

static float scale1 = 3;

UIAlertView *menuOptions;

SEL rightSelector;
SEL leftSelector;

NSString *imagePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //NSLog(@"Custom Settings");
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
        [self.navigationItem setTitle:@"iSchematic - Home"];
        
        UIBarButtonItem *setup = [[UIBarButtonItem alloc] initWithTitle:@"Change PIN" style:UIBarButtonItemStylePlain target:self action:@selector(changePIN)];
        

        
        UIBarButtonItem *help = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logMeOut)];
//        help.tintColor = [[UIColor alloc] initWithRed:215/255.0 green:28/255.0 blue:56/255.0 alpha:1.0];
        [buttons addObject:help];
        
        // [self.navigationItem setLeftBarButtonItem:setup];
        UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)]];
        [buttons addObject:space];
        
        [buttons addObject:setup];
        //[self.navigationItem setRightBarButtonItem:help];
        [self.navigationItem setLeftBarButtonItems:buttons];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.moduleTable setDelegate:self];
    [self.moduleTable setDataSource:self];
    
    util = [[Utils alloc]init];
    BOOL success = [util initModuleDB];
    if(!success)
        NSLog(@"Database operation failed");
    
    self.downloadStatuses = [[NSMutableDictionary alloc]init];
    self.progressStatuses = [NSMutableDictionary dictionary];
    self.fileSizeDict = [[NSMutableDictionary alloc]init];
    self.resumeFileSizeDict = [[NSMutableDictionary alloc]init];
    
    NSArray *dirArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,    NSUserDomainMask, YES);
    filePath = [dirArray objectAtIndex:0];
    filePath = [filePath stringByAppendingFormat:@"/Caches"];
    if(![util checkIfUserHasPIN:User])
        [self setUpPIN];
    
    util.isAskingForPIN = NO;
    
    [self initPageSetup];
    [self initUI];
    
    [data sortWithOptions:0 usingComparator: ^(id inObj1, id inObj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
        NSDate *date1 = [formatter dateFromString:[inObj1 objectForKey: @"pkg_date"]];
        NSDate *date2 = [formatter dateFromString:[inObj2 objectForKey: @"pkg_date"]];
        return [date2 compare: date1];
    }];
    
    dataOriginal = [data copy];
    
    //NSLog(@"ORIGL : %i", [dataOriginal count]);
    [self.moduleTable setScrollEnabled:NO];
    [self.moduleTable reloadData];

    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromLeft:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRight:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGestureRecognizer];
    
    if(hasInternet) {
    //    NSLog(@"Internet is available");
    }
    else
    {
    }
    
    imagePath = [util getThumbnailsPath];
    
    // Do any additional setup after loading the view from its nib.
}


-(void)handleSwipeFromRight:(UISwipeGestureRecognizer *)recognizer {
    
    if([data count] > 0)
    {
        int swipePage = currentPage + 1;
        pageCount = (int) ceil((float)[data count]/(float)(mC*2));
        //NSLog(@"Swipe Right: %i, %i, %i", currentPage, swipePage, pageCount);
    
        if(swipePage > pageCount) {
            currentPage = pageCount;
        }
        else {
            currentPage = swipePage;
            
            
            float aniWidth = self.moduleTable.frame.size.width;
            CGRect newFrame = self.moduleTable.frame;
            newFrame.origin.x += aniWidth;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            self.moduleTable.frame = newFrame;
            [UIView commitAnimations];
            
            newFrame.origin.x -= aniWidth;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            self.moduleTable.frame = newFrame;
            [UIView commitAnimations];


        }
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:currentPage-1];
        //NSLog(@"Current: %i", currentPage);
        [self.moduleTable reloadData];
    }
    /*
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [UIView commitAnimations];
    */
}

-(void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)recognizer {
    
    if([data count] > 0)
    {
        int swipePage = currentPage - 1;
        pageCount = (int) ceil((float)[data count]/(float)(mC*2));
        //NSLog(@"Swipe Left: %i, %i, %i", currentPage, swipePage, pageCount);
        if(swipePage < 1) {
            currentPage = 1;
        }
        else {
            currentPage = swipePage;
            
            float aniWidth = self.moduleTable.frame.size.width;
            CGRect newFrame = self.moduleTable.frame;
            newFrame.origin.x -= aniWidth;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            self.moduleTable.frame = newFrame;
            [UIView commitAnimations];
            
            newFrame.origin.x += aniWidth;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            self.moduleTable.frame = newFrame;
            [UIView commitAnimations];
        }
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:currentPage-1];
        //NSLog(@"Current: %i", currentPage);
        [self.moduleTable reloadData];
    }
}

- (void)initUI
{
    //[self setLabelParameter:userLabel :[NSString stringWithFormat:@" %@", userName] :@"264178" :NSTextAlignmentLeft :22];
    
    [btns addTarget:self action:@selector(openHelp) forControlEvents:UIControlEventTouchUpInside];

    //[self setLabelParameter:footerLabel :@" ©2013 iSchematic. U.S. Patent No. 8,401,675 B2. Product of TPC Training Systems. All rights reserved." :@"264178" :NSTextAlignmentLeft :16];
    
    [searchBar setBackgroundImage:[UIImage imageNamed:@"blue_bg.png"]];
    [searchBar setScopeBarBackgroundImage:[UIImage imageNamed:@"blue_bg.png"]];
    [searchBar setDelegate:self];

    tpc = [[TPCCellViewCell alloc]init];
        
    newImage = [UIImage imageNamed:@"corner_ribbon.png"];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
	[hud setMode:MBProgressHUDModeIndeterminate];
    [hud hide:YES];
    [self.view addSubview:hud];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    fm = [NSFileManager defaultManager];
    
    if([data count] > 0)
        [self setLabelParameter:groupLabel :[NSString stringWithFormat:@" %@ - %@",[self getModuleProperties:0:@"group"], userName] :@"264178" :NSTextAlignmentLeft :18];
    else
        [self setLabelParameter:groupLabel :@"" :@"264178" :NSTextAlignmentLeft :22];
    
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];

}

-(void) changePage:(id)sender
{
    UIPageControl *pager=sender;
    int page = pager.currentPage;
    //NSLog(@"Prev Page %i", page);
    currentPage = page+1;
    pageCount = (int) ceil((float)[data count]/(float)(mC*2));
    //NSLog(@"Current Page %i, %i, %i", currentPage, page, pageCount);
    [self.moduleTable reloadData];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //NSLog(@"TOCUCHED ");
    [searchBar resignFirstResponder];
}

- (void)initPageSetup
{
    hasInternet = [util getInternetReachability];
    moduleCount = [data count];
    pageCount = (int) ceil((float)[data count]/(float)(mC*2));
    
    currentPage = 1;
    [pageControl setNumberOfPages:pageCount];
    [pageControl setCurrentPage:0];

}

- (void) openHelp
{
    [ab.view removeFromSuperview];
    ab = nil;
    ab = [[AboutController alloc]init];
    [self.navigationController pushViewController:ab animated:YES];
}

- (void)setPaging: (id) sender
{
    //NSLog(@"Setting Page: %i", [sender tag]);
    currentPage = [sender tag];
    [self.moduleTable reloadData];
    pageCount = (int) ceil((float)[data count]/(float)(mC*2));
    [pageControl setCurrentPage:pageCount-1];
}

- (void) setLabelParameter:(UILabel *)lbl :(NSString *)string :(NSString *)color :(NSTextAlignment)alignment :(NSInteger) fontSize
{
    [lbl setText:[NSString stringWithFormat:@"%@",string]];
    [lbl setFont:[UIFont fontWithName:@"Arial-BoldMT" size:fontSize]];
//    [lbl setBackgroundColor:[util colorWithHexString:color]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:alignment];
}

- (void) setUpPIN
{
    [util setUpPIN:User];
}

- (void) changePIN
{
    [util changePIN:YES:User];
}

- (void) logMeOut
{
    UIAlertView *alertConfirm = [[UIAlertView alloc]initWithTitle:@"Logout" message:@"Are you sure you want to logout?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    //[alertLogOut showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
    [alertConfirm showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        //NSLog(@"Button from AlertView 1 Clicked");
        if(buttonIndex == 1)
        {
            if(myTimer)
            {
                [myTimer invalidate];
                myTimer = nil;
            }
            if([[RequestQueue mainQueue] requestCount])
            {
                UIAlertView *alertLogOut = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Logging out will abort all the downloads. Are you sure?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                
                //[alertLogOut showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
                [alertLogOut showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    //NSLog(@"Button from AlertView 1 Clicked");
                    if(buttonIndex == 1)
                    {
                        if([[RequestQueue mainQueue] requestCount])
                        {
                            [[RequestQueue mainQueue] cancelAllRequests];
                            //NSLog(@"Cancelling all requests...");
                        }
                        
                        [util checkForInCompleteDownloads];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    
                }];
                alertLogOut = nil;
                
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Button Pressed for Alert %i, %i", buttonIndex, alertView.tag);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //NSLog(@"MEMORY WARNING");
    view = nil;
    UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"Memory" message:@"Memory Warning" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alt show];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //[self logMemUsage];
    int modCount = [data count];
    int rowCounts =0;
    //int totalPage = (int) ceil((float)moduleCount/(float)(mC*2));
     if(modCount != 0)
    {
        
        if((currentPage*mC*2)<=modCount)
        {
            rowCounts = mC;
            //NSLog(@"IF Page: %i, %i, %i", currentPage, modCount, totalPage);
        }
        else
        {
            rowCounts = ceil((float)(modCount % (mC*2))/(float)2);
            //NSLog(@"ELSE Page: %i, %i, %i", currentPage, modCount, totalPage);
        }
    }
    
    /*
     if((currentPage*mC*2)<=modCount)
    {
        if(modCount == 0) rowCount = 0;
        else rowCount = mC;
    }
    else
    {
        if(modCount == 0) rowCount= 0;
        else rowCount = ceil((float)(modCount % (mC*2))/(float)2);
    }
    NSLog(@"RETURN PAGE %i = %i", currentPage, rowCount);
     */
    return rowCounts;
}

- (NSString *) getModuleProperties:(int)index :(NSString *)prop
{
    NSString *property=nil;
    //NSLog(@"INDEX %i", index);
    if([data count] > index)
    {
        id obj = [data objectAtIndex:index];
        
        for (NSString *key in obj) {
            
            if([key isEqualToString:prop])
            {
                id value = [obj objectForKey:key];
                property = value;
            }
        }

    }
    return property;
}

- (NSString *) getModuleImage:(int)index {
    NSString *mImage=nil;
    //NSLog(@"INDEX %i", index);
    if([data count]>0)
    {
        id obj = [data objectAtIndex:index];
        for (NSString *key in obj) {
            
            if([key isEqualToString:@"image"])
            {
                id value = [obj objectForKey:key];
                mImage = [imagePath stringByAppendingFormat:@"/%@", value];
                //NSLog(@"mImage, %@", mImage);
            }
        }

    }
    //NSLog(@"IMAGE DATA1: %@", mImage);
    return mImage;
}

- (void) viewMenu: (UITapGestureRecognizer *)sender
{
    //NSLog(@"view Menu");
    NSInteger tag = [(UIImageView *)sender.view tag]-30;
    NSString *mname = [self getModuleProperties:tag:@"mname"];
    NSString *mdownload = [self getModuleProperties:tag:@"mdownload"];
    NSString *weblink = [self getModuleProperties:tag:@"weblink"];
    NSString *status = [util checkModuleStatus:mdownload];
    
    //NSLog(@"Single Tap: %i", tag);
    //NSLog(@"Module Name: %@", mname);
    //NSLog(@"Module Name: %@", mdownload);
    
    if([status isEqualToString:@"view"])
    {
        [view.view removeFromSuperview];
        view=nil;
        view = [[ViewModule alloc]init];
        view.filepath = mdownload;
        view.mname = mname;
        view.User = User;
        view.mode = @"offline";
        [self.navigationController pushViewController:view animated:YES];
    }
    else if([status isEqualToString:@"download"] || [status isEqualToString:@"update"])
    {
        menuOptions = [[UIAlertView alloc] initWithTitle:@"Module Options" message:@"Please choose one of the following options" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"View Online", @"Download", nil];
        
        [menuOptions showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            //NSLog(@"Button Pressed %i", buttonIndex);
            if(buttonIndex == 1)
            {
                hasInternet = [util getInternetReachability];
                if(!hasInternet)
                {
                    UIAlertView *can = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Internet connection seems to be offiline. Please connect to the internet and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [can showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    }];
                    can = nil;
                }
                else
                {
                    [view.view removeFromSuperview];
                    view=nil;
                    view = [[ViewModule alloc]init];
                    view.filepath = weblink;
                    view.mname = mname;
                    view.User = User;
                    view.mode = @"online";
                    [self.navigationController pushViewController:view animated:YES];
                }
            }
            else if(buttonIndex == 2)
            {
                if ([status isEqualToString:@"download"])
                {
                    if(!hasInternet)
                    {
                        UIAlertView *alertOptions = [[UIAlertView alloc] initWithTitle:@"Information" message:@"There is no internet connection available. Please connect to the internet and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        
                        [alertOptions showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            
                        }];
                    }
                    else { [self loadURL:mdownload : mname: @"download"]; }
                }
                else if([status isEqualToString:@"update"])
                {
                    NSLog(@"updating...");
                    if(!hasInternet)
                    {
                        UIAlertView *alertOptions = [[UIAlertView alloc] initWithTitle:@"Information" message:@"There is no internet connection available. Please connect to the internet and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        
                        [alertOptions showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            
                        }];
                    }
                    else { [self loadURL:mdownload : mname: @"update"]; }
                }
                
            }
            else {}
        }];
    }
    
}

- (void) downloadMenu: (UITapGestureRecognizer *)sender
{
    //NSLog(@"download Menu");
    NSInteger tag = [(UIImageView *)sender.view tag]-30;
    NSString *mname = [self getModuleProperties:tag:@"mname"];
    NSString *mdownload = [self getModuleProperties:tag:@"mdownload"];
    NSString *status = [util checkModuleStatus:mdownload];
    NSString *weblink = [self getModuleProperties:tag:@"weblink"];

    //NSLog(@"Single Tap: %i", tag);
    //NSLog(@"Module Name: %@", mname);
    //NSLog(@"Module Name: %@", mdownload);
    
    if([status isEqualToString:@"downloading"])
    {
        menuOptions = nil;
        menuOptions = [[UIAlertView alloc] initWithTitle:@"Module Options" message:@"Please choose one of the following options" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Abort", @"Pause/Resume", @"View Online", nil];
    
        [menuOptions showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            //NSLog(@"Button Pressed %i", buttonIndex);
            if(buttonIndex == 1)
            {
                [self cancelDownload:mdownload:YES];
            }
            else if(buttonIndex == 2)
            {
                [self pauseResumeDownload:mdownload:mname];
            }
            else if(buttonIndex == 3)
            {
                hasInternet = [util getInternetReachability];
                if(!hasInternet)
                {
                    UIAlertView *can = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Internet connection seems to be offiline. Please connect to the internet and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [can showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    }];
                    can = nil;
                }
                else
                {
                    [view.view removeFromSuperview];
                    view=nil;
                    view = [[ViewModule alloc]init];
                    view.filepath = weblink;
                    view.mname = mname;
                    view.User = User;
                    view.mode = @"online";
                    [self.navigationController pushViewController:view animated:YES];
                }
                
            }
            else {}
        }];
    }
    else if([status isEqualToString:@"update"])
    {
        
    }
    else
    {
        
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
    //NSLog(@"Current Page:%i, NOW:%i, TOTAL:%i", currentPage, (pageCount-currentPage)+1, pageCount);
    
    int modCount = [data count];
    int rowCount =  0;
    if((currentPage*mC*2)<=modCount)
        rowCount = mC;
    else
        rowCount = ceil((float)(modCount % (mC*2))/(float)2);

    objRow = ((currentPage-1)*mC)+[indexPath row];
    
    //NSLog(@"OBJ ROW: %i", objRow);
    
    isDownloadingLeft = NO;
    row_mdownloadLeft = [self getModuleProperties:objRow:@"mdownload"];
    row_statusLeft = [util checkModuleStatus:row_mdownloadLeft];
    row_lbl1TextLeft = [self getModuleProperties:objRow:@"client"];
    isViewableLeft = [util getModuleViewStatus:row_mdownloadLeft:User];

    if([row_statusLeft isEqualToString:@"view"])
    {
        badgeLevelLeft = 0;
        leftSelector = @selector(viewMenu:);
    }
    else if([row_statusLeft isEqualToString:@"update"])
    {
        badgeLevelLeft = 1;
        leftSelector = @selector(viewMenu:);
    }
    else if([row_statusLeft isEqualToString:@"download"])
    {
        badgeLevelLeft = 1;
        leftSelector = @selector(viewMenu:);
    }
    else if([row_statusLeft isEqualToString:@"downloading"])
    {
        row_lbl1TextLeft = downloadStatuses[row_mdownloadLeft];
        isDownloadingLeft = YES;
        badgeLevelLeft = 0;
        leftSelector = @selector(downloadMenu:);
    }
    else {}

    if(((objRow+1)*2) <= modCount)
    {
        isDownloadingRight = NO;
        row_mdownloadRight = [self getModuleProperties:objRow+rowCount:@"mdownload"];
        row_statusRight = [util checkModuleStatus:row_mdownloadRight];
        row_lbl1TextRight = [self getModuleProperties:objRow+rowCount:@"client"];
        isViewableRight = [util getModuleViewStatus:row_mdownloadRight:User];
    
        if([row_statusRight isEqualToString:@"view"])
        {
            badgeLevelRight = 0;
            rightSelector = @selector(viewMenu:);
        }
        else if([row_statusRight isEqualToString:@"update"])
        {
            NSLog(@"Update %i", indexPath.row);
            badgeLevelRight = 1;
            rightSelector = @selector(viewMenu:);
        }
        else if([row_statusRight isEqualToString:@"download"])
        {
            badgeLevelRight = 1;
            rightSelector = @selector(viewMenu:);
        }
        else if([row_statusRight isEqualToString:@"downloading"])
        {
            row_lbl1TextRight = downloadStatuses[row_mdownloadRight];
            isDownloadingRight = YES;
            badgeLevelRight = 0;
            rightSelector = @selector(downloadMenu:);
        }
        else {}
    }
    
    static NSString *cellID = @"Cell";
    TPCCellViewCell *cell = (TPCCellViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];

    if(cell == nil)
    {
        cell = [[TPCCellViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [cell.moduleImageLeft setImage:[UIImage imageWithContentsOfFile:[self getModuleImage:objRow]]];
    if(isViewableLeft) { [cell.imageLeft setImage:newImage]; }
    else { [cell.imageLeft setImage:nil]; }
    [cell.lbl0Left setText:[self getModuleProperties:objRow:@"mname"]];
    [cell.lbl1Left setText:row_lbl1TextLeft];
    [cell.badgeViewLeft setValue:badgeLevelLeft];
    cell.moduleImageLeft.userInteractionEnabled = YES;
    [cell.moduleImageLeft setTag:(30+objRow)];
    [cell.lbl0Left setTag:(30+objRow)];
    [cell.lbl1Left setTag:(30+objRow)];
    //[cell.singleTapLeft addTarget:self action:@selector(singleTapAction:)];
    //[cell.longPressLeft addTarget:self action:@selector(longPressAction:)];
    [cell.singleTapLeft addTarget:self action:leftSelector];
    [cell.singleTapLabel0Left addTarget:self action:leftSelector];
    [cell.singleTapLabel1Left addTarget:self action:leftSelector];
    
    if(isDownloadingLeft)
    {
        [cell.pViewLeft setHidden:NO];
        [cell.pViewLeft setProgress:[progressStatuses[row_mdownloadLeft] floatValue]];
    }
    else { [cell.pViewLeft setHidden:YES]; }

    if(((objRow+1)*2) <= modCount)
    {

        [cell.moduleImageRight setHidden:NO];
        [cell.badgeViewRight setHidden:NO];
        [cell.lbl0Right setHidden:NO];
        [cell.lbl1Right setHidden:NO];
        [cell.imageRight setHidden:NO];
        [cell.moduleImageRight setImage:[UIImage imageWithContentsOfFile:[self getModuleImage:objRow+rowCount]]];
        if(isViewableRight) { [cell.imageRight setImage:newImage]; }
        else { [cell.imageRight setImage:nil]; }
        [cell.lbl0Right setText:[self getModuleProperties:objRow+rowCount:@"mname"]];
        [cell.lbl1Right setText:row_lbl1TextRight];
        [cell.badgeViewRight setValue:badgeLevelRight];
        cell.moduleImageRight.userInteractionEnabled = YES;
        [cell.moduleImageRight setTag:(30+objRow+rowCount)];
        [cell.lbl0Right setTag:(30+objRow+rowCount)];
        [cell.lbl1Right setTag:(30+objRow+rowCount)];
        
        //[cell.singleTapRight addTarget:self action:@selector(singleTapAction:)];
        //[cell.longPressRight addTarget:self action:@selector(longPressAction:)];
        [cell.singleTapRight addTarget:self action:rightSelector];
        [cell.singleTapLabel0Right addTarget:self action:rightSelector];
        [cell.singleTapLabel1Right addTarget:self action:rightSelector];
        

        if(isDownloadingRight)
        {
            [cell.pViewRight setHidden:NO];
            [cell.pViewRight setProgress:[progressStatuses[row_mdownloadRight] floatValue]];
        }
        else { [cell.pViewRight setHidden:YES]; }
    }
    else
    {
        //NSLog(@"NO CELL");
        //NSLog(@"PVIEW %f", [cell.pViewRight progress]);
        [cell.pViewRight setHidden:YES];
        [cell.moduleImageRight setHidden:YES];
        [cell.badgeViewRight setHidden:YES];
        [cell.lbl0Right setHidden:YES];
        [cell.lbl1Right setHidden:YES];
        [cell.imageRight setHidden:YES];
        
    }
    
    return cell;
}


- (void) cancelDownload: (NSString *)mdownload :(BOOL) del
{
    //NSLog(@"Aborting %@", mdownload);
    NSArray *req = [[RequestQueue mainQueue] requests];
    for (id object in req) {
        NSMutableURLRequest *can = (NSMutableURLRequest *) object;
        NSURL *canreq = [can URL];
        NSString *canreqstr = [NSString stringWithFormat:@"%@", canreq];
        if([canreqstr isEqualToString:mdownload ])
        {
            //NSLog(@"ARR: %@", canreqstr);
            [[RequestQueue mainQueue] cancelRequest:can];
//            if(del)
            [self.moduleTable reloadData];
        }
    }
    [util removeLocalFileForURL:mdownload];
    //NSLog(@"Reloading...%@", mdownload);
    [self.moduleTable reloadData];
}

- (void) pauseResumeDownload: (NSString *) mdownload :(NSString *)mname
{
    BOOL paused=NO;
    NSArray *req = [[RequestQueue mainQueue] requests];
    for (id object in req) {
        NSMutableURLRequest *can = (NSMutableURLRequest *) object;
        NSURL *canreq = [can URL];
        NSString *canreqstr = [NSString stringWithFormat:@"%@", canreq];
        if([canreqstr isEqualToString:mdownload ])
        {
            //NSLog(@"ARR: %@", canreqstr);
            [[RequestQueue mainQueue] cancelRequest:can];
            paused = YES;
            //NSLog(@"PAUSE");
            downloadStatuses[mdownload] = @"PAUSED...";
            [self.moduleTable reloadData];
        }
    }
    if(!paused)
    {
        //NSLog(@"RESUME");
        [self loadURL:mdownload : mname: @"resume"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.moduleTable reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((32*scale1)+10);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(askForPIN) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if(hasInternet)
    {
        [searchBar setText:nil];
        data = [dataOriginal copy];
        moduleCount = [data count];
        pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
        currentPage = 1;
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:0];
        [searchBar setSelectedScopeButtonIndex:0];
    }
    else
    {
        searchBar.text = nil;
        data = [util getAvailableModule:dataOriginal];
        moduleCount = [data count];
        pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
        currentPage = 1;
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:0];
        [searchBar setSelectedScopeButtonIndex:1];
    }
    
    [self.moduleTable reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    

}

- (void) loadURL: (NSString *) url :(NSString *) mname : (NSString *) mode
{
    //create operation
    //NSLog(@"URL: %@", url);
    hasInternet = [util getInternetReachability];
    
    if(hasInternet)
    {
        if([mode isEqualToString:@"update"])
        {
            NSError *error;
            NSString *fileToDelete = [util getLocalPath:url];
            NSString *pathToDelete = [fileToDelete stringByAppendingString:@"_dir/"];
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:pathToDelete]) {
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:pathToDelete error:&error];
                if (!success) {
                    //NSLog(@"Error removing DIR at path: %@", error.localizedDescription);
                }
            }
            
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:fileToDelete]) {
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:fileToDelete error:&error];
                if (!success) {
                    //NSLog(@"Error removing FILE at path: %@", error.localizedDescription);
                }
            }
        }
        
        [hud show:YES];
        [self performSelector:@selector(tableReload) withObject:nil afterDelay:0.5];
        //NSLog(@"Loading URL: %@", url);
        NSURL *URL = [NSURL URLWithString:url];
        NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
        //NSURLCacheStoragePolicy policy = NSURLRequestUseProtocolCachePolicy;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:15.0];
        if([mode isEqualToString:@"resume"])
        {
            [self resumeDownload:url :request];
        }
        RQOperation *operation = [RQOperation operationWithRequest:request];
        
        operation.completionHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if (!error)
            {
                NSString *fileName = response.suggestedFilename;
                NSString *fileToZip = [NSString stringWithFormat:@"%@/%@", filePath, fileName];
                NSString *pathToWrite = [NSString stringWithFormat:@"%@/%@_dir", filePath, fileName];
                NSLog(@"Path to Write: %@", pathToWrite);
                NSError *dirError;
                if(![[NSFileManager defaultManager] createDirectoryAtPath:pathToWrite withIntermediateDirectories:NO attributes:nil error:&dirError])
                {
                    //NSLog(@"Create directory error: %@", dirError);
                }
                [SSZipArchive unzipFileAtPath:fileToZip toDestination:pathToWrite];
                BOOL success =[[NSFileManager defaultManager] removeItemAtPath:fileToZip error:&error];
                if (!success) {
                    NSLog(@"Unable to Delete the file.");
                }
                //NSLog(@"File Unzipped");
                [util setModuleViewStatus:url :User :@"Y"];
                if([[UIApplication sharedApplication] applicationState]== UIApplicationStateBackground)
                {
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
                    localNotification.alertBody = [NSString stringWithFormat:@"iSchematic module %@ has been downloaded.", mname];
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                }
                if([mode isEqualToString:@"update"])
                {
                    [util updateSpecificModule:self.data :url :User];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:url];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            else
            {
                //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error Downloading" message:[error localizedDescription] delegate:self  cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                //[alert show];
            }
            
        };
        
        operation.receivingHandler = ^(NSURLResponse *response, NSData *nsdata) {
            
            if(!myTimer)
            {
                myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tableReload) userInfo:nil repeats:YES];
            }
            
            //NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            //NSLog(@"Receiving Data %@ - %i [%lli] , [%i]", response.suggestedFilename, nsdata.length, response.expectedContentLength, httpResponse.statusCode);
            NSString *fileName = response.suggestedFilename;
            NSString *fileToWrite = [NSString stringWithFormat:@"%@/%@", filePath, fileName];
            //NSLog(@"file: %@", fileToWrite);
            
            NSFileHandle *hFile = [NSFileHandle fileHandleForWritingAtPath:fileToWrite];
            if (!hFile)
            {
                [[NSFileManager defaultManager] createFileAtPath:fileToWrite contents:nil attributes:nil];
                hFile = [NSFileHandle fileHandleForWritingAtPath:fileToWrite];
            }
            if (!hFile)
            {
                //NSLog(@"could not write to file %@",fileToWrite);
            }
            @try
            {
                [hFile seekToEndOfFile];
                [hFile writeData:nsdata];
            }
            @catch (NSException * e)
            {
                //NSLog(@"exception when writing to file %@", fileToWrite);
            }
            [hFile closeFile];
            
        };
        
        operation.downloadProgressHandler = ^(float progress, NSInteger bytesTransferred, NSInteger totalBytes, NSURLResponse *response) {
            
            //update progress
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if([httpResponse statusCode] == 206)
            {
                NSInteger bT = [resumeFileSizeDict[url] integerValue] + bytesTransferred;
                float txMB = (float) ((float) (bT)/(1024*1024));
                NSInteger bTT = [fileSizeDict[url] integerValue];
                float ttMB = (float)((float) bTT/(1024*1024));
                progressStatuses[url] = @((float) bT / (float) bTT);
                downloadStatuses[url] = [NSString stringWithFormat:@" %.02f MB of %.02f MB...", txMB, ttMB];
            }
            else
            {
                progressStatuses[url] = @(progress);
                float txMB = (float) ((float) bytesTransferred/(1024*1024));
                float ttMB = (float)((float) totalBytes/(1024*1024));
                downloadStatuses[url] = [NSString stringWithFormat:@" %.02f MB of %.02f MB...", txMB, ttMB];
            }
            
        };
        
        operation.responseHandler = ^(NSURLResponse *response) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            [hud hide:YES];
            //NSLog(@"Response: %i - %lli", [httpResponse statusCode], response.expectedContentLength);
            [self performSelector:@selector(tableReload) withObject:nil afterDelay:0.5];
            if ([httpResponse statusCode] >= 400) {
                //NSLog(@"remote url returned error %d %@",[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
                [[RequestQueue mainQueue] cancelRequest:request];
                NSInteger errorCode = [httpResponse statusCode];
                NSString *errorMessage = [NSString stringWithFormat:@"%i ", errorCode];
                errorMessage = [errorMessage stringByAppendingString:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]];
                //NSLog(@"remote url returned error %@",errorMessage);
                NSString *errorTitle = [NSString stringWithFormat:@"Error - %@", mname];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:errorTitle message:errorMessage delegate:self  cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alert setTag:3];
                [alert show];
            } else if([httpResponse statusCode] ==200) {
                fileSizeDict[url] = [NSString stringWithFormat:@"%li", (unsigned long) response.expectedContentLength];
            } else if([httpResponse statusCode] ==206) {
                // start recieving data
                NSString *filename = [util getLocalPath:url];
                //NSLog(@"FileName: %@", filename);
                NSUInteger downloadedBytes = 0;
                NSFileManager *fm = [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:filename]) {
                    NSError *error = nil;
                    NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filename error:&error];
                    if (!error && fileDictionary)
                    {
                        downloadedBytes = [fileDictionary fileSize];
                        //NSLog(@"Downloaded Bytes: %li", (unsigned long)downloadedBytes);
                    }
                    else
                    {
                        //NSLog(@"No such file exists for resume download:");
                    }
                    
                    if(downloadedBytes == 0)
                    {
                        //NSLog(@"Invalid Response");
                    }
                }
                resumeFileSizeDict[url] = [NSString stringWithFormat:@"%li", (unsigned long)downloadedBytes];
            }
            else
            {
                //NSLog(@"Initiating File");
            }
        };
        
        
        operation.didFailWithErrorHandler = ^(NSURLConnection *connection1, NSMutableURLRequest *request1, NSError *error) {
            /*
             NSLog(@"Retrying 123....");
             NSString *filename = [util getLocalPath:url];
             NSLog(@"FileName: %@", filename);
             NSUInteger downloadedBytes = 0;
             if ([fm fileExistsAtPath:filename]) {
             NSError *error = nil;
             NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filename error:&error];
             if (!error && fileDictionary)
             {
             downloadedBytes = [fileDictionary fileSize];
             if (downloadedBytes > 0) {
             NSString *requestRange = [NSString stringWithFormat:@"bytes=%d-",(downloadedBytes)];
             NSLog(@"Request Range: %@", requestRange);
             [request setValue:@"keep-live" forHTTPHeaderField:@"Connection"];
             [request setValue:@"300" forHTTPHeaderField:@"Keep-Alive"];
             [request setValue:requestRange forHTTPHeaderField:@"Range"];
             }
             }
             }
             */
            [self resumeDownload:url :request1];
        };
        
        operation.autoRetry = YES;
        [[RequestQueue mainQueue] addOperation:operation];

    }
    else
    {
        UIAlertView *alt1 = [[UIAlertView alloc]initWithTitle:@"Information" message:@"You are not connected to the internet. Please connect to internet and try agian." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alt1 show];
    }
}

- (void) resumeDownload :(NSString *)url2 :(NSMutableURLRequest *)request2
{
    //NSLog(@"Retrying 123....");
    NSString *filename = [util getLocalPath:url2];
    //NSLog(@"FileName: %@", filename);
    NSUInteger downloadedBytes = 0;
    if ([fm fileExistsAtPath:filename]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filename error:&error];
        if (!error && fileDictionary)
        {
            downloadedBytes = [fileDictionary fileSize];
            if (downloadedBytes > 0) {
                NSString *requestRange = [NSString stringWithFormat:@"bytes=%d-",(downloadedBytes)];
                //NSLog(@"Request Range: %@", requestRange);
                [request2 setValue:@"keep-live" forHTTPHeaderField:@"Connection"];
                [request2 setValue:@"300" forHTTPHeaderField:@"Keep-Alive"];
                [request2 setValue:requestRange forHTTPHeaderField:@"Range"];
            }
        }
    }
}

- (void) tableReload
{
    //NSLog(@" Time Remaining %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
    if([[UIApplication sharedApplication] backgroundTimeRemaining] < 100)
    {
        [hud hide:YES];
        NSArray *req = [[RequestQueue mainQueue] requests];
        for (id object in req) {
            NSMutableURLRequest *can = (NSMutableURLRequest *) object;
            [[RequestQueue mainQueue] cancelRequest:can];
        }
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.alertBody = @"Some of iSchematic modules have been paused. Please resume the downloads.";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    [self.moduleTable reloadData];
    
    if(![[RequestQueue mainQueue] requestCount])
    {
        [myTimer invalidate];
        myTimer = nil;
    }
    else
    {
        if(!myTimer)
        {
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tableReload) userInfo:nil repeats:YES];
        }
    }
}


 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}




- (void) askForPIN
{
    //NSLog(@"APP enters background");
    if(!util.isAskingForPIN)
        [util changePIN:NO:User];
}

- (void) searchBar:(UISearchBar *)searchBar1 textDidChange:(NSString *)searchText
{
    //NSLog(@"search String: %@, %i", searchText, [searchText length]);
    [searchBar1 setSelectedScopeButtonIndex:0];
    
    if([searchText length] == 0)
    {
        data = [dataOriginal copy];
    }
    else
    {
        data = [util searchModule:dataOriginal :searchText];
    }
    moduleCount = [data count];
    pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
    
    currentPage = 1;
    [pageControl setNumberOfPages:pageCount];
    [pageControl setCurrentPage:0];
    
    //currentPage = 1;
    //[pageControl setNumberOfPages:pageCount];
    //[pageControl setCurrentPage:pageCount];
    
    [self.moduleTable reloadData];
    //NSLog(@"MOD COUNT: %i", moduleCount);
}

- (void)searchBar:(UISearchBar *)searchBar1 selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    //NSLog(@"Button Selected: %i", (int)selectedScope);
    [searchBar1 resignFirstResponder];
    int bt = (int) selectedScope;
    if(bt==0)
    {
        searchBar1.text = nil;
        if([data count] > 0)[data removeAllObjects];
        data = [dataOriginal copy];
        moduleCount = [data count];
        pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
        currentPage = 1;
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:0];
        [self.moduleTable reloadData];


        //NSLog(@"MOD COUNT: %i <> %i", moduleCount, pageCount);
    }
    else if(bt==1)
    {
        searchBar1.text = nil;
        data = [util getAvailableModule:dataOriginal];
        moduleCount = [data count];
        pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
        currentPage = 1;
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:0];
        [self.moduleTable reloadData];
        
        //NSLog(@"MOD COUNT: %i <> %i", moduleCount, pageCount);
    }
    else if(bt==2)
    {
        searchBar1.text = nil;
        data = [util getOnlineModule:dataOriginal];
        moduleCount = [data count];
        pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
        currentPage = 1;
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:0];
        [self.moduleTable reloadData];

        //NSLog(@"MOD COUNT: %i <> %i", moduleCount, pageCount);
    }
    else if(bt==3)
    {
        /*
         searchBar1.text = nil;
        data = [util getDownloadingModule:dataOriginal];
        moduleCount = [data count];
        pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
        currentPage = 1;
        [self.moduleTable reloadData];
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:pageCount];
        NSLog(@"MOD COUNT: %i <> %i", moduleCount, pageCount);
         */
        
        searchBar1.text = nil;
        data = [util getNewModule:dataOriginal:User];
        moduleCount = [data count];
        pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
        currentPage = 1;
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:0];
        [self.moduleTable reloadData];

        //NSLog(@"MOD COUNT: %i <> %i", moduleCount, pageCount);

    }
    else if(bt==4)
    {
        searchBar1.text = nil;
        data = [util getNewModule:dataOriginal:User];
        moduleCount = [data count];
        pageCount = (int) ceil((float)moduleCount/(float)(mC*2));
        currentPage = 1;
        [pageControl setNumberOfPages:pageCount];
        [pageControl setCurrentPage:0];
        [self.moduleTable reloadData];

        //NSLog(@"MOD COUNT: %i <> %i", moduleCount, pageCount);
    }
    else{}
}

/*
 
vm_size_t usedMemory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

vm_size_t freeMemory(void) {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

-(void) logMemUsage{
    // compute memory usage and log if different by >= 100k
    static long prevMemUsage = 0;
    long curMemUsage = usedMemory();
    long memUsageDiff = curMemUsage - prevMemUsage;
    
    if (memUsageDiff > 100000 || memUsageDiff < -100000) {
        prevMemUsage = curMemUsage;
        NSLog(@"Memory used %7.1f (%+5.0f), free %7.1f kb", curMemUsage/1000.0f, memUsageDiff/1000.0f, freeMemory()/1000.0f);
        [footerLabel setText:[NSString stringWithFormat:@"Memory used %7.1f (%+5.0f), free %7.1f kb", curMemUsage/1000.0f, memUsageDiff/1000.0f, freeMemory()/1000.0f]];
    }
}
*/

@end
