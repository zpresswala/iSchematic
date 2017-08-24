//
//  AboutController.m
//  iSchematic
//
//  Created by Navas on 21/06/13.
//  Copyright (c) 2013 Affluent. All rights reserved.
//

#import "AboutController.h"
#import "UIDevice+IdentifierAddition.h"


@interface AboutController ()

@end

@implementation AboutController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.aboutText setBackgroundColor:[UIColor clearColor]];
    NSString *deviceID = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    deviceID = [NSString stringWithFormat:@"Registration ID: %@", deviceID];
    [self.deviceIDLabel setText:deviceID];
    [self.deviceIDLabel  setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
    [self.deviceIDLabel  setTextColor:[UIColor whiteColor]];
    [self.deviceIDLabel  setTextAlignment:NSTextAlignmentCenter];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
