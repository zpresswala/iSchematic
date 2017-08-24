//
//  ViewController.h
//  iShcematic
//
//  Created by Navas on 09/06/13.
//  Copyright (c) 2013 Affluent. All rights reserved.//

#import <UIKit/UIKit.h>

@class ViewController;

@interface ViewController : UIViewController<NSXMLParserDelegate, NSURLConnectionDelegate, UITextFieldDelegate>
{
    NSXMLParser *xmlparser;
    NSMutableDictionary *module;
    NSMutableArray *modules;
    NSString *currentElement;
    NSMutableString *mname, *client, *group, *mdownload, *weblink, *pkg_date, *pkg_size, *response, *username;
    NSMutableData *image;
    BOOL hasInternet;
}

@property (nonatomic) BOOL hasInternet;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginToPortal:(id)sender;


@end
