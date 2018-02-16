   //
//  ViewController.m
//  iShcematic
//
//  Created by Navas on 09/06/13.
//  Copyright (c) 2013 Affluent. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "Dashboard.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "AboutController.h"
#import "UIDevice+IdentifierAddition.h"
#import "Base64.h"


@interface ViewController ()

@end

@implementation ViewController 
{
    UIAlertView *alert;
    //NSMutableDictionary *length;
    Utils *utils;
    NSString *User;
    BOOL hasUserError;
    NSString *userErrorString;
    NSMutableData *receivedData;
    MBProgressHUD *HUD;
    NSString *deviceID;
    BOOL isLoginOK;
    //BOOL parsing;
    AboutController *ab;
    Dashboard *dashboard;
    BOOL isFormUp;
    NSString *group1;
}

@synthesize hasInternet;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //length = [[NSMutableDictionary alloc]init];
    [self.passwordText setSecureTextEntry:YES];
    
    utils = [[Utils alloc]init];
    hasInternet = [utils getInternetReachability];
    BOOL success = [utils initModuleDB];
    if(!success)
    {
        //NSLog(@"Database operation failed");
    }
    [utils checkForInCompleteDownloads];
    
    if(!hasInternet)
        [self.navigationItem setTitle:@"iSchematic [Offline Mode]"];
    
    UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(aboutThisApp)];
    [self.navigationItem setLeftBarButtonItem:about];

    [self.emailText setDelegate:self];
    [self.passwordText setDelegate:self];
    
    deviceID = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    //NSLog(@"OPEN ID is: %@", deviceID);
    
    //[self.emailText becomeFirstResponder];
    dashboard = [[Dashboard alloc]init];
    
	// Do any additional setup after loading the view, typically from a nib.
    isFormUp = NO;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setFormBack:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    isFormUp = NO;
}

- (void) aboutThisApp
{
    ab = nil;
    ab = [[AboutController alloc]init];
    [self.navigationController pushViewController:ab animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)loginToPortal:(id)sender{
    [self.emailText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self initiateLogin];
}

- (void) initiateLogin
{
    NSString *email = [self.emailText text];
    if([utils isUserExists:email])
    {
        //NSLog(@"Initiating Connection");
        [xmlparser abortParsing];
        xmlparser = nil;
        userErrorString = nil;
        hasInternet = [utils getInternetReachability];
        
        NSString *password = [self.passwordText text];
        NSString *passwordMD5 = [self MD5:password];
        if([email isEqualToString:@""] ||  [password isEqualToString:@""])
        {
            //alert = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Please enter email & password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[alert show];
            [self showAlert:@"Please enter email & password" :@"Information"];
        }
        else if(![self isValidEmail:email])
        {
            [self showAlert:@"Please enter valid email address" :@"Information"];
        }
        else
        {
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.labelText = @"Loading...";
            User = email;
            if(hasInternet)
            {
                [HUD show:YES];
                //NSLog(@"User Name: %@", email);
                //NSLog(@"User Pass: %@", password);
                //deviceID = @"56hk654h6546h54u6y";
                deviceID = @"7b1da41c5efea1b5290239b8c59d8bc2";
                NSString *urlString = [NSString stringWithFormat:@"https://www.ischematic.com/service/webCall.do?u=%@&p=%@&f=iOS&i=%@", email, passwordMD5, deviceID];
                //NSLog(@"urlString %@", urlString);
                //urlString = [NSString stringWithFormat:@"http://secure.zenprofessional.com/tmp/webCall2.do.xml?u=%@&p=%@&f=iOS&i=%@", email, passwordMD5, deviceID];
                NSURL *url = [NSURL URLWithString:urlString];
                //NSLog(@"URL: %@", urlString);
                //parsing = true;
                receivedData = [[NSMutableData alloc] init];
                NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
                [urlConnection start];
            }
            else
            {
                //NSLog(@"OFFline mode");
                if([self checkLocalLogin:email:passwordMD5])
                {
                    //NSLog(@"getting module: ");
                    dashboard.data = [utils getModuleFromDB:email:nil];
                    dashboard.hasInternet = hasInternet;
                    dashboard.User = User;
                    dashboard.userName = [utils getUsernameForUser:email];
                    [self.navigationController pushViewController:dashboard animated:YES];
                }
                else
                {
                    //NSLog(@"Error Stage 3");
                    [self showAlert:@"Unable to verify user - please connect to the Internet.":@"Validation Error"];
                }
            }
        }
        
    }
    else
    {
            [self showAlert:@"This app has been registered under a different user name.":@"Registration Error"];
    }
    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //NSLog(@"Parse Error: %@", parseError.localizedDescription);
    [self showAlert:@"XML Parse Error" :@"Error"];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{

    //NSLog(@"startElement %@", elementName);
    currentElement = elementName;
    if([elementName isEqualToString:@"module"]) {
        module = [[NSMutableDictionary alloc]init];
        mname = [[NSMutableString alloc]init];
        client = [[NSMutableString alloc]init];
        group = [[NSMutableString alloc]init];
        mdownload = [[NSMutableString alloc]init];
        weblink = [[NSMutableString alloc]init];
        pkg_date = [[NSMutableString alloc]init];
        pkg_size = [[NSMutableString alloc]init];
        image = [[NSMutableData alloc]init];
        //pkg_dt = [[NSDate alloc]init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    //NSLog(@"endElement %@", elementName);
    if([elementName isEqualToString:@"response"]){
    }
    else if([elementName isEqualToString:@"username"]) {
    }
    else if([elementName isEqualToString:@"group"]) {
        
    }
    else if([elementName isEqualToString:@"module"]) {
        [module setObject:mname forKey:@"mname"];
        [module setObject:client forKey:@"client"];
        [module setObject:group1 forKey:@"group"];
        [module setObject:mdownload forKey:@"mdownload"];
        [module setObject:weblink forKey:@"weblink"];
        [module setObject:pkg_date forKey:@"pkg_date"];
        if(image != NULL)
            [module setObject:image forKey:@"image"];
        
        [modules addObject:[module copy]];
        //NSLog(@"adding module: %@", module);
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    string = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([currentElement isEqualToString:@"response"])
    {
        if([string length] > 0)
        {
            NSRange foundRange = [string rangeOfString:@"Success:" options:NSBackwardsSearch];
            //NSLog(@"found characters: %@ - %i", string, foundRange.length);
            if(!foundRange.length > 0){
                //NSLog(@"Login Error: %@", string);
                hasUserError = YES;
                userErrorString = string;
                isLoginOK = NO;
                //NSLog(@"Connection Error: Parser: %@", string);
            }
            else
            {
                isLoginOK = YES;
            }
        }
    }
    else if([currentElement isEqualToString:@"username"])
    {
        if(!username)
        {
            username = [string copy];
            //NSLog(@"User Name is %@", username);
        }
    }
    else if([currentElement isEqualToString:@"group"])
    {
        if(!group1)
        {
            group1 = [string copy];
            //NSLog(@"Group Name is %@", group1);
        }
    }
    else
    {
    
    }
    
    if([currentElement isEqualToString:@"mname"])
        [mname appendString:string];
    else if([currentElement isEqualToString:@"client"])
        [client appendString:string];
    else if([currentElement isEqualToString:@"group"])
        [group appendString:string];
    else if([currentElement isEqualToString:@"mdownload"])
        [mdownload appendString:string];
    else if([currentElement isEqualToString:@"weblink"])
        [weblink appendString:string];
    else if([currentElement isEqualToString:@"pkg_date"])
        [pkg_date appendString:string];
    else if([currentElement isEqualToString:@"image"])
    {
        NSArray *foo = [string componentsSeparatedByString: @","];
        if([foo count] == 2)
        {
            //NSLog(@"OBJECT");
            NSString *bar = [foo objectAtIndex: 1];
            NSData *image1 = [NSData dataWithBase64EncodedString:bar];
            image = [image1 copy];
        }
    }
    else {}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    //NSLog(@"all done!");
    //NSLog(@"total count: %i", [modules count]);
    
    if(isLoginOK)
    {
        //NSLog(@"#####: %@", username);
        
        //dashboard.data = modules;
        dashboard.hasInternet = hasInternet;
        dashboard.User = User;
        dashboard.userName = username;
        //NSLog(@"Setting up username: %@", username);
        NSString *status = [utils getUserStatus:[self.emailText text]:[self MD5:self.passwordText.text]];
        if([status isEqualToString:@"new"])
        {
            if([utils registerUser:self.emailText.text : [self MD5:self.passwordText.text]: username :deviceID])
            {
                //NSLog(@"User Registration Successfull");
                if([utils registerModules:self.emailText.text :modules])
                {
                    dashboard.data = [utils getModuleFromDB:User:nil];
                    [self.navigationController pushViewController:dashboard animated:YES];
                }
            }
        }
        else if([status isEqualToString:@"existing"])
        {
            //NSLog(@"User Exists");
            if([utils registerModules:self.emailText.text :modules])
            {
                dashboard.data = [utils getModuleFromDB:User:nil];
                [self.navigationController pushViewController:dashboard animated:YES];
            }
        }
        else
        {
            //NSLog(@"Error Stage 1");
            [self showAlert:@"Unable to Login":@"Connection Error"];
        }
    }
    else
    {
        //NSLog(@"Error Stage 2");
        [self showAlert:userErrorString:@"Connection Error"];
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
	//NSLog(@"started parsing");

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //Reset the data as this could be fired if a redirect or other response occurs

    //NSLog(@"Connection Response");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //Append the received data each time this is called
    [receivedData appendData:data];
    [HUD setLabelText:@"Receiving..."];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"Connection Done: %@", [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]);
    //Start the XML parser with the delegate pointing at the current object
    isLoginOK = NO;
    modules = [[NSMutableArray alloc] init];
    xmlparser = [[NSXMLParser alloc] initWithData:receivedData];
    [xmlparser setDelegate:self];
    [xmlparser setShouldProcessNamespaces:NO];
	[xmlparser setShouldReportNamespacePrefixes:NO];
	[xmlparser setShouldResolveExternalEntities:NO];
    [xmlparser parse];
    //arsing = NO;

    [HUD hide:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [HUD hide:YES];
    //NSLog(@"Connection Error: %@", [error localizedDescription]);
    NSString *eRR = [NSString stringWithFormat:@"Connection Error: %@", [error localizedDescription]];
    //alert = [[UIAlertView alloc]initWithTitle:@"Error" message:eRR delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //[alert show];
    [self showAlert:eRR :@"Connection Error"];
}

- (NSString*)MD5:(NSString *) input
{
    const char *ptr = [input UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.emailText setText:@""];
    [self.passwordText setText:@""];
    hasInternet = [utils getInternetReachability];
    //NSLog(@"%@", [[self navigationController] viewControllers]);
}

- (void) showAlert: (NSString *)message :(NSString *)title
{
    alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert = nil;
}

- (BOOL)checkLocalLogin: (NSString *)useremail : (NSString *)userpassword
{
    return [utils checkLocalDBLogin:useremail :userpassword];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self initiateLogin];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //if (textField.tag == 10)
        //return;
    if(isFormUp == NO)
    {
        isFormUp = YES;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.view.frame = CGRectMake(0,-95,self.view.frame.size.width,self.view.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //if(textField.tag == 10) return;
    // Additional Code
    //[self setFormBack];
}

- (void) setFormBack:(UITapGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    isFormUp = NO;
    [self.passwordText resignFirstResponder];
    [self.emailText resignFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    xmlparser = nil;
    receivedData = nil;
    alert = nil;
    ab = nil;
    [self.emailText setText:@""];
    [self.passwordText setText:@""];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.emailText setText:@""];
    [self.passwordText setText:@""];
    [self.emailText resignFirstResponder];
    [self.passwordText resignFirstResponder];
}


-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
