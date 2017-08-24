//
//  Utils.m
//  iShcematic
//
//  Created by Navas on 10/06/13.
//  Copyright (c) 2013 Affluent. All rights reserved.
//

#import "Utils.h"
#import "Reachability.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "AlertViewBlocks.h"
#import "Base64.h"

@implementation Utils
{
    NSString *localFile;
    NSString *localPath;
    NSString *zipFolder;
    NSString *databasePath;
    NSString *databaseName;
    NSString *dbPath;
    NSMutableArray *data1;

    FMDatabase *db;
    FMResultSet *result;
    NSArray *paths;
    NSString *documentsDirectory;
    
    NSFileManager *fileManager;
}

@synthesize isAskingForPIN;

-(void) createAndCheckDatabase
{
    NSError *error;
    BOOL success;
    NSString *dbFullPath = [NSString stringWithFormat:@"%@/%@", databasePath, databaseName];
    dbPath = dbFullPath;
    //NSLog(@"PATH: %@", dbPath);
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:dbFullPath];
    if(success) return;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:databaseName ofType:nil];
    if(![fileManager copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/%@", databasePath, databaseName] error:&error]) {
        // handle the error
        //NSLog(@"Error creating the database: %@", [error description]);
    }
}

- (BOOL) initModuleDB
{
    fileManager = [NSFileManager defaultManager];
    paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingFormat:@"/Caches"];
    //NSLog(@"DOCS DIR: %@", documentsDirectory);
    [data1 removeAllObjects];
    data1 = [[NSMutableArray alloc]init];
    databasePath = [self getDocumentPath];
    databaseName = @"modules.db";
    //NSLog(@"%@", databasePath);
    [self createAndCheckDatabase];
    [self createThumbnailsDirectory];
    return YES;
}

- (void) createThumbnailsDirectory
{
    NSString *iPath = [documentsDirectory stringByAppendingFormat:@"/thumbnails"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:iPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:iPath withIntermediateDirectories:NO attributes:nil error:&error];
}

- (BOOL) getInternetReachability
{
    BOOL status;
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == 0)
    {
        status = NO;
    }
    else status = YES;
    //NSLog(@"Net Status: %u", remoteHostStatus);
    return status;
}

- (NSString *) checkModuleStatus:(NSString *) mdownload
{
    NSString *status = @"";
    //NSArray *parts = [mdownload componentsSeparatedByString:@"/"];
    NSString *filename = [[mdownload componentsSeparatedByString:@"/"] objectAtIndex:[[mdownload componentsSeparatedByString:@"/"] count]-1];
    
    //localPath = [paths objectAtIndex:0];
    localFile = [documentsDirectory stringByAppendingPathComponent:filename];
    zipFolder = [localFile stringByAppendingString:@"_dir/start.html"];
    //NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isZipDirExists = [fileManager fileExistsAtPath:zipFolder];
    if(isZipDirExists)
    {
        NSString *uptodate = [[NSUserDefaults standardUserDefaults] objectForKey:mdownload];
        if([uptodate length] > 0)
        {
            status = @"update";
        }
        else
        {
            status = @"view";
        }
    }
    else
    {
        BOOL isZipFileExists = [fileManager fileExistsAtPath:localFile];
        if(isZipFileExists)
        {
            status = @"downloading";
        }
        else
        {
            status = @"download";
        }
    }
    return status;
}

- (void) checkForInCompleteDownloads
{
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"Docs Dir: %@", documentsDirectory);
    NSError *error;
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
    for (id object in directoryContents) {
        NSString *cont = object;
        BOOL isDir;
        BOOL exists = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, cont] isDirectory:&isDir];
        if(exists && !isDir)
        {
            NSRange range = [cont rangeOfString:@".zip" options:(NSBackwardsSearch)];
            if(range.location != NSNotFound)
            {
                //NSLog(@"File: %@", cont);
                NSString *contFile = [NSString stringWithFormat:@"%@/%@", documentsDirectory, cont];
                NSString *contDir = [NSString stringWithFormat:@"%@/%@_dir/start.html", documentsDirectory, cont];
                BOOL exists1 = [fileManager fileExistsAtPath:contDir];
                if(!exists1)
                {
                    //NSLog(@"Del File: %@", cont);
                    [fileManager removeItemAtPath:contFile error:&error];
                    NSString *contDir1 = [NSString stringWithFormat:@"%@/%@_dir/", documentsDirectory, cont];
                    BOOL exists2 = [fileManager fileExistsAtPath:contDir1];
                    if(exists2)
                    {
                        [fileManager removeItemAtPath:contDir1 error:&error];
                    }
                }
            }
        }
    }
}

- (NSString *) getLocalPath: (NSString *) mdownload
{
    NSString *path = @"";
    NSArray *parts = [mdownload componentsSeparatedByString:@"/"];
    NSString *filename = [parts objectAtIndex:[parts count]-1];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    localPath = documentsDirectory;
    localFile = [documentsDirectory stringByAppendingPathComponent:filename];
    path = localFile;
    //NSLog(@"PATH: %@", path);
    return path;
}

- (long long) getLocalFileSize: (NSString *) mdownload
{
    long long fsize;
    NSArray *parts = [mdownload componentsSeparatedByString:@"/"];
    NSString *filename = [parts objectAtIndex:[parts count]-1];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    localPath = documentsDirectory;
    localFile = [documentsDirectory stringByAppendingPathComponent:filename];
    //NSFileManager *man = [[NSFileManager alloc] init];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:localFile error:nil];
    fsize = [[attrs objectForKey: NSFileSize] longLongValue];
    return  fsize;
}

- (NSString *) getDocumentPath
{
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory1 = [paths1 objectAtIndex:0];
    return  documentsDirectory1;
}

-(BOOL) isUserExists:(NSString *) user
{
    BOOL success = NO;
    db = [FMDatabase databaseWithPath: dbPath];
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    result = [db executeQuery: [NSString stringWithFormat:@"select count(*) as NUMBER from user"]];
    if([result next])
    { 
        //NSInteger ids = [result intForColumn:@"userid"];
        //NSString *email = [result stringForColumn:@"email"];
        //NSLog(@"User Name: %@ = %i", email, ids);
        int ids1 = [result intForColumn:@"NUMBER"];
        //NSLog(@"User Count: %i", ids1);
        if(ids1 == 0)
            success = YES;
        else
        {
            result = [db executeQuery: [NSString stringWithFormat:@"select * from user where email='%@'", user]];
            if([result next])
            {
                success = YES;
            }
            else success = NO;
        }
    }
    [db close];

    return success;
}

- (NSString *) getUserStatus: (NSString *) user : (NSString *)pass
{
    NSString *status =@"";
    //NSLog(@"DB PATH: %@", dbPath);
    db = [FMDatabase databaseWithPath: dbPath];
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    result = [db executeQuery: [NSString stringWithFormat:@"select * from user where email='%@' and pass='%@'", user, pass]];
    if([result next])
    {
        //NSInteger ids = [result intForColumn:@"userid"];
        //NSString *email = [result stringForColumn:@"email"];
        //NSLog(@"User Name: %@ = %i", email, ids);
        status = @"existing";
    }
    else
    {
        status = @"new";
    }
    [db close];
    return status;
}

- (BOOL) registerUser: (NSString *)user :(NSString *)pass :(NSString *)username :(NSString *)deviceid
{
    BOOL success;
    db = [FMDatabase databaseWithPath: dbPath];
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    NSString *insert = [NSString stringWithFormat:@"insert into user (email, pass, username, deviceid) values ('%@', '%@', '%@', '%@')", user, pass, username, deviceid];
    //NSLog(@"INsert: %@", insert );
    success = [db executeUpdate:insert];
    [db close];
    return success;
}

- (BOOL) registerModules: (NSString *)user :(NSMutableArray *)module
{
    BOOL success=NO;
    db = [FMDatabase databaseWithPath: dbPath];
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    for (id obj in module)
    {
        NSString *downloadable = [obj objectForKey:@"mdownload"];
        NSString *sql = [NSString stringWithFormat:@"select * from module where user='%@' and mdownload='%@' ", user, downloadable];
        result = [db executeQuery: sql];
        if([result next])
        {
            NSString *current_pkg_date = [result stringForColumn:@"pkg_date"];
            NSString *old_pkg_date = [obj objectForKey:@"pkg_date"];
            
            if([old_pkg_date isEqualToString:current_pkg_date])
            {
                NSString *update  = [NSString stringWithFormat:@"UPDATE module SET mname= '%@',  weblink= '%@',  client= '%@',  pkg_date= '%@',  groups= '%@' WHERE mdownload= '%@' and user= '%@'", [obj objectForKey:@"mname"],[obj objectForKey:@"weblink"],[obj objectForKey:@"client"],[obj objectForKey:@"pkg_date"],[obj objectForKey:@"group"], downloadable, user];
                success = [db executeUpdate:update];
                //NSLog(@"Update Query: %@", update);
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:current_pkg_date forKey:downloadable];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        else
        {

            UIImage *mImage = [UIImage imageWithData:[obj objectForKey:@"image"]];
            NSString *iPath = [self getThumbnailsPath];
            NSString *iName = [obj objectForKey:@"mdownload"];
            NSArray *parts = [iName componentsSeparatedByString:@"/"];
            iName = [parts objectAtIndex:[parts count]-1];
            iName = [iName stringByReplacingOccurrencesOfString:@".zip" withString:@".png"];
            iPath = [iPath stringByAppendingFormat:@"/%@",iName];
            
            NSLog(@"IMAGE: %@", iPath);
            [UIImagePNGRepresentation(mImage) writeToFile:iPath atomically:YES];

            NSString *insert = [NSString stringWithFormat:@"insert into module (mname, mdownload, weblink, client, pkg_date, user, groups, image, viewed) values ( '%@', '%@','%@','%@','%@','%@','%@', '%@', '%@' )", [obj objectForKey:@"mname"], [obj objectForKey:@"mdownload"],[obj objectForKey:@"weblink"],[obj objectForKey:@"client"],[obj objectForKey:@"pkg_date"],user,[obj objectForKey:@"group"], iName, @"N"];
            success = [db executeUpdate:insert];
            //NSLog(@"Insert String: %@", insert);
            //[[obj objectForKey:@"image"] base64EncodedString]
        }
    }
    [db close];
    return success;
}

- (BOOL) updateSpecificModule: (NSMutableArray *)module :(NSString *) mdownload :(NSString *)user
{
    BOOL success=NO;
    db = [FMDatabase databaseWithPath: dbPath];
    //NSLog(@"DB PATH: %@", dbPath);
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    for (id obj in module)
    {
        NSString *downloadable = [obj objectForKey:@"mdownload"];
        if([downloadable isEqualToString:mdownload])
        {
            NSString *update  = [NSString stringWithFormat:@"UPDATE module SET mname= '%@',  weblink= '%@',  client= '%@',  pkg_date= '%@',  groups= '%@', image='%@' WHERE mdownload= '%@' and user= '%@'", [obj objectForKey:@"mname"],[obj objectForKey:@"weblink"],[obj objectForKey:@"client"],[obj objectForKey:@"pkg_date"],[obj objectForKey:@"group"], [[obj objectForKey:@"image"] base64EncodedString], downloadable, user];
            success = [db executeUpdate:update];
            if(!success)
            {
                //NSLog(@"create test, %d:%@", [db lastErrorCode], [db lastErrorMessage]);
                //NSLog(@"Query update failed...%@", update);
            }
            //NSLog(@"Update Query Success: %@, %c", update, success);
        }
    }
    [db close];
    return success;
}

- (BOOL) checkLocalDBLogin: (NSString *)user : (NSString *)pass
{
    BOOL success;
    db = [FMDatabase databaseWithPath: dbPath];
    //NSLog(@"DB PATH: %@", dbPath);
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    result = [db executeQuery: [NSString stringWithFormat:@"select * from user where email='%@' and pass='%@'", user, pass]];
    //NSLog(@"SQL: %@", [NSString stringWithFormat:@"select * from user where email='%@' and pass='%@'", user, pass]);
    if([result next])
    {
        success = YES;
    }
    else
    {
        success = NO;
    }
    [db close];
    return success;
}

- (NSMutableArray *) getModuleFromDB:(NSString *)user :(NSString *)search
{
    [data1 removeAllObjects];
    db = [FMDatabase databaseWithPath: dbPath];
    //NSLog(@"DB PATH: %@", dbPath);
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    NSString *query = [NSString stringWithFormat:@"select * from module where user='%@'", user];
    if(search)
    {
        search = [search lowercaseString];
        query = [NSString stringWithFormat:@"select * from module where user='%@' and mname like lower('%@%@%@')", user, @"%", search, @"%"];
        //NSLog(@"QUERY IS: %@", query);
    }
    result = [db executeQuery:query];
    while([result next])
    {
        //NSString *mdwownload = [result stringForColumn:@"mdownload"];
        if([self getInternetReachability])
        {
            NSDictionary *dic = [[NSDictionary alloc]init];
            NSMutableDictionary *mdic = [dic mutableCopy];
            [mdic setObject:[result stringForColumn:@"mname"] forKey:@"mname"];
            [mdic setObject:[result stringForColumn:@"mdownload"] forKey:@"mdownload"];
            [mdic setObject:[result stringForColumn:@"weblink"] forKey:@"weblink"];
            [mdic setObject:[result stringForColumn:@"client"] forKey:@"client"];
            [mdic setObject:[result stringForColumn:@"groups"] forKey:@"group"];
            [mdic setObject:[result stringForColumn:@"pkg_date"] forKey:@"pkg_date"];
            [mdic setObject:[result stringForColumn:@"image"] forKey:@"image"];
            [data1 addObject:[mdic copy]];
            //NSLog(@"Pushing Records...");
        }
        else
        {
            //if([self isModuleAvailableLocally:mdwownload])
            //{
                NSDictionary *dic = [[NSDictionary alloc]init];
                NSMutableDictionary *mdic = [dic mutableCopy];
                [mdic setObject:[result stringForColumn:@"mname"] forKey:@"mname"];
                [mdic setObject:[result stringForColumn:@"mdownload"] forKey:@"mdownload"];
                [mdic setObject:[result stringForColumn:@"weblink"] forKey:@"weblink"];
                [mdic setObject:[result stringForColumn:@"client"] forKey:@"client"];
                [mdic setObject:[result stringForColumn:@"groups"] forKey:@"group"];
                [mdic setObject:[result stringForColumn:@"pkg_date"] forKey:@"pkg_date"];
                [mdic setObject:[result stringForColumn:@"image"] forKey:@"image"];
                [data1 addObject:[mdic copy]];
                //NSLog(@"Pushing Records...");
            //}
        }
    }
    [db close];
    //NSLog(@"Returning DATA");
    return data1;
    
}

- (BOOL) removeLocalFileForURL: (NSString *) mdownload
{
    BOOL success = '\0';
    NSError *error;
    NSString *fileToDelete = [self getLocalPath:mdownload];
    //NSLog(@"Delete file at %@:", fileToDelete);
    if ([fileManager isDeletableFileAtPath:fileToDelete]) {
        BOOL success = [fileManager removeItemAtPath:fileToDelete error:&error];
        if (!success) {
            //NSLog(@"Error removing DIR at path: %@", error.localizedDescription);
        }
    }
    return success;
}

- (BOOL) checkIfUserHasPIN: (NSString *) user
{
    BOOL success = '\0';
    db = [FMDatabase databaseWithPath: dbPath];
    //NSLog(@"DB PATH: %@", dbPath);
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }

    result = [db executeQuery: [NSString stringWithFormat:@"select PIN from user where email='%@'", user]];
    if([result next])
    {
        NSString *pin = [result stringForColumn:@"PIN"];
        if([pin length] == 4)
            success = YES;
        else
            success = NO;
    }
    else
        success = NO;
    [db close];
    return success;
}

- (BOOL) setPINForUser: (NSString *)pin :(NSString *)user
{
    BOOL success = '\0';
    db = [FMDatabase databaseWithPath: dbPath];
    //NSLog(@"DB PATH: %@", dbPath);
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    
    success = [db executeUpdate:[NSString stringWithFormat:@"update user set PIN = '%@' where email='%@'", pin, user]];
    [db close];
    return success;
}

- (NSString *) getPINForUser: (NSString *) user
{
    NSString *pin;
    db = [FMDatabase databaseWithPath: dbPath];
    //NSLog(@"DB PATH: %@", dbPath);
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    
    result = [db executeQuery:[NSString stringWithFormat:@"select PIN from user where email='%@'", user]];
    if([result next])
    {
        pin = [result stringForColumn:@"PIN"];
    }
    [db close];
    return pin;
}

- (NSString *) getUsernameForUser: (NSString *) user
{
    NSString *username;
    db = [FMDatabase databaseWithPath: dbPath];
    //NSLog(@"DB PATH: %@", dbPath);
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    
    result = [db executeQuery:[NSString stringWithFormat:@"select username from user where email='%@'", user]];
    if([result next])
    {
        username = [result stringForColumn:@"username"];
    }
    [db close];
    return username;
}

- (void) changePIN:(BOOL)validate :(NSString *)User
{
    //NSLog(@"USer: %@", User);
    UIAlertView *askpin = [[UIAlertView alloc]initWithTitle:@"Validation" message:@"Please enter your 4 digit secure PIN" delegate:nil cancelButtonTitle:nil  otherButtonTitles:@"Verify", nil];
    [askpin setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [[askpin textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[askpin textFieldAtIndex:0] setPlaceholder:@"Enter 4 digit PIN"];
    [[askpin textFieldAtIndex:0] setDelegate:self];
    isAskingForPIN = YES;
    //[askpin showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
    [askpin showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //NSLog(@"Button Pressed: %i", buttonIndex);
        if(buttonIndex == 0)
        {
            NSString *PIN = [self getPINForUser:User];
            if([PIN isEqualToString:[[askpin textFieldAtIndex:0] text]])
            {
                if(validate)
                    [self setUpPIN:User];
            }
            else
            {
                UIAlertView *loginFailed = [[UIAlertView alloc]initWithTitle:@"Validation" message:@"PIN incorrect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                //[loginFailed showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
                [loginFailed showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if(!validate)
                    {
                        [self changePIN:NO:User];
                    }
                    else
                    {
                        [self changePIN:YES:User];
                    }
                }];
            }
        }
        else
        {
            if(!validate)
                [self changePIN:NO:User];
            else
                [self changePIN:YES:User];
        }
        isAskingForPIN = NO;
    }];
}

-(BOOL) isModuleAvailableLocally:(NSString *) module
{
    //NSString *path = [self getLocalPath: module];
    //NSLog(@"PATH ::: %@", path);
    //NSString *contDir = [NSString stringWithFormat:@"%@_dir/start.html", path];
    //BOOL exists = [fileManager fileExistsAtPath:contDir];
    return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@_dir/start.html", [self getLocalPath: module]]];
}

- (void) setUpPIN:(NSString *)User
{
    UIAlertView *pin = [[UIAlertView alloc]initWithTitle:@"Setup your PIN" message:@"Please enter your 4 digit secure PIN" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [pin setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[pin textFieldAtIndex:0] setSecureTextEntry:YES];
    [[pin textFieldAtIndex:1] setSecureTextEntry:YES];
    [[pin textFieldAtIndex:0] setPlaceholder:@"Enter 4 digit PIN"];
    [[pin textFieldAtIndex:1] setPlaceholder:@"Re-Enter 4 digit PIN"];
    [[pin textFieldAtIndex:0] setDelegate:self];
    [[pin textFieldAtIndex:1] setDelegate:self];
    [[pin textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[pin textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeNumberPad];
    //[pin showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
    [pin showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 1)
        {
            UIAlertView *alt0;
            NSString *pin0 = [[pin textFieldAtIndex:0] text];
            NSString *pin1 = [[pin textFieldAtIndex:1] text];
            if([pin0 isEqualToString:pin1] && [pin0 length] == 4 && [pin1 length] == 4)
            {
                //NSLog(@"Password Matches: %@", pin0);
                if([self setPINForUser:pin0:User])
                {
                    //NSLog(@"User PIN has successfully registered");
                }
                else
                {
                    //NSLog(@"There was problem registering PIN");
                }
            }
            else if([pin0 length] == 0 || [pin1 length] == 0)
            {
                alt0 = [[UIAlertView alloc]initWithTitle:@"Error" message:@"PIN cannot be empty." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alt0 showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self setUpPIN:User];
                }];                
            }
            else if([pin0 length] != 4 || [pin1 length] != 4)
            {
                alt0 = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter 4 digit PIN." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alt0 showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self setUpPIN:User];
                }];
            }            
            else
            {
                alt0 = [[UIAlertView alloc]initWithTitle:@"Error" message:@"PIN numbers doesn't match. Please Re-Enter." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alt0 showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self setUpPIN:User];
                }];
            }
        }
        else
        {
            if(![self checkIfUserHasPIN:User])
            {
                //NSLog(@"User has NO PIN");
                [self setUpPIN:User];
            }
        }
    }];
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength == 4) NSLog(@"Keys Typed");
    
    return (newLength > 4) ? NO : YES;
}
*/

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0 && newLength < 5 ) || ([string isEqualToString:@""]);
}


- (UIColor *) colorWithHexString: (NSString *) hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


- (NSMutableArray *) getOnlineModule: (NSMutableArray *)dta
{
    if([data1 count] > 0)[data1 removeAllObjects];
    for(int index=0; index<[dta count];index++){
        id obj = [dta objectAtIndex:index];
        for (NSString *key in obj) {
            if([key isEqualToString:@"mdownload"]){
                if(![self isModuleAvailableLocally:[obj objectForKey:key]]) [data1 addObject:obj];
            }
        }
    }
    return data1;
}

- (NSMutableArray *) getAvailableModule: (NSMutableArray *)dta
{
    if([data1 count] > 0)[data1 removeAllObjects];
    for(int index=0; index<[dta count];index++){
        id obj = [dta objectAtIndex:index];
        for (NSString *key in obj) {
            if([key isEqualToString:@"mdownload"]){
                if([self isModuleAvailableLocally:[obj objectForKey:key]]) [data1 addObject:obj];
            }
        }
    }
    return data1;
}

- (NSMutableArray *) getDownloadingModule: (NSMutableArray *)dta
{
    if([data1 count] > 0)[data1 removeAllObjects];
    for(int index=0; index<[dta count];index++){
        id obj = [dta objectAtIndex:index];
        for (NSString *key in obj) {
            if([key isEqualToString:@"mdownload"]){
                if([[self checkModuleStatus:[obj objectForKey:key]] isEqualToString:@"downloading"]) [data1 addObject:obj];
            }
        }
    }
    return data1;
}

- (NSMutableArray *) getNewModule: (NSMutableArray *)dta :(NSString *)User
{
    if([data1 count] > 0)[data1 removeAllObjects];
    for(int index=0; index<[dta count];index++){
        id obj = [dta objectAtIndex:index];
        for (NSString *key in obj) {
            if([key isEqualToString:@"mdownload"]){
                if([self getModuleViewStatus:[obj objectForKey:key]:User]) [data1 addObject:obj];
            }
        }
    }
    return data1;
}


- (NSMutableArray *) searchModule: (NSMutableArray *)dta :(NSString *)search
{
    if([data1 count] > 0)[data1 removeAllObjects];
    search = [search lowercaseString];
    //NSLog(@"SEARCH COUNT: %i", [dta count]);
    for(int index=0; index<[dta count];index++){
        id obj = [dta objectAtIndex:index];
        for (NSString *key in obj) {
            if([key isEqualToString:@"mname"] || [key isEqualToString:@"client"]){
                //if([[[obj objectForKey:key] lowercaseString]rangeOfString:search].location != NSNotFound) [data1 addObject:obj];
                if([[obj objectForKey:key] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound) [data1 addObject:obj];
            }
        }
    }
    //NSLog(@"SEARCH MODULE COUNT: %i", [data1 count]);
    return [[[NSSet setWithArray: data1] allObjects] copy];
}

- (BOOL) getModuleViewStatus:(NSString *)mdownload :(NSString *)user
{
    BOOL stat = NO;
    
    db = [FMDatabase databaseWithPath: dbPath];
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    
    result = [db executeQuery:[NSString stringWithFormat:@"select viewed from module where mdownload='%@' and user= '%@'", mdownload, user]];
    if([result next])
    {
        if( [[result stringForColumn:@"viewed"] isEqualToString:@"Y" ]) { stat = YES; } else { stat = NO; }
    }
    [db close];
    //NSLog(@"is Viewable = %i, %@", stat, [NSString stringWithFormat:@"select viewed from modules where mdownload='%@'", mdownload]);
    return stat;
}

- (void) setModuleViewStatus:(NSString *)mdownload :(NSString *)user :(NSString *)stat
{
    db = [FMDatabase databaseWithPath: dbPath];
    if (![db open]) {
        //NSLog(@"Cannot open Database.");
    }
    
    NSString *update = [NSString stringWithFormat:@"UPDATE module SET viewed= '%@' WHERE mdownload= '%@' and user= '%@'", stat, mdownload, user];
    [db executeUpdate:update];
    //NSLog(@"UPDATE: %@", update);
    [db close];
}

- (NSString *) getThumbnailsPath
{
    return [documentsDirectory stringByAppendingFormat:@"/thumbnails"];
}

- (UIImage *) getThumbnailsForModule: (NSString *) mURL
{
    UIImage *mImage;
    
    return mImage;
}

@end