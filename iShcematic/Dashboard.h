//
//  Dashboard.h
//  iSch
//
//  Created by Navas on 09/06/13.
//  Copyright (c) 2013 Navas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Dashboard : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UISearchBarDelegate>
{
    NSMutableArray *data;
    BOOL hasInternet;
    NSString *User;
    NSString *userName;
}

@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITableView *moduleTable;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (weak, nonatomic) IBOutlet UIButton *btns;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic) BOOL hasInternet;
@property (nonatomic) BOOL didNotSwipe;

@property (nonatomic,retain)NSMutableArray *data;

@property (nonatomic,retain)NSString *User;
@property (nonatomic,retain)NSString *userName;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end
