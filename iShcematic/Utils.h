//
//  Utils.h
//  iShcematic
//
//  Created by Navas on 10/06/13.
//  Copyright (c) 2013 Affluent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject<UITextFieldDelegate>
{
    BOOL isAskingForPIN;
}

@property (nonatomic) BOOL isAskingForPIN;

- (NSString *) checkModuleStatus:(NSString *) mdownload;
- (NSString *) getLocalPath: (NSString *) mdownload;
- (NSString *) getUserStatus: (NSString *) user :(NSString *) pass;
- (long long) getLocalFileSize: (NSString *) mdownload;
- (void) checkForInCompleteDownloads;

- (BOOL) getInternetReachability;
- (BOOL) initModuleDB;
- (BOOL) registerUser: (NSString *)user :(NSString *)pass :(NSString *)username :(NSString *)deviceid;
- (BOOL) registerModules: (NSString *)user :(NSMutableArray *)module;
- (BOOL) updateSpecificModule: (NSMutableArray *)module :(NSString *) mdownload :(NSString *)user;
- (BOOL) checkLocalDBLogin: (NSString *)user : (NSString *)pass;
- (BOOL) removeLocalFileForURL: (NSString *) mdownload;
- (BOOL) checkIfUserHasPIN: (NSString *) user;
- (BOOL) setPINForUser: (NSString *)pin :(NSString *)user;
- (BOOL) getModuleViewStatus:(NSString *)mdownload :(NSString *)user;
- (BOOL) isUserExists:(NSString *) user;

- (void) setModuleViewStatus:(NSString *)mdownload :(NSString *)user :(NSString *)stat;
- (NSString *) getPINForUser: (NSString *) user;
- (NSMutableArray *) getModuleFromDB:(NSString *)user :(NSString *)search;
- (void) changePIN:(BOOL)validate :(NSString *)User;
- (void) setUpPIN:(NSString *)User;
- (NSString *) getUsernameForUser: (NSString *) user;
- (UIColor *) colorWithHexString: (NSString *)hex;

- (NSMutableArray *) getOnlineModule: (NSMutableArray *)dta;
- (NSMutableArray *) getAvailableModule: (NSMutableArray *)dta;
- (NSMutableArray *) searchModule: (NSMutableArray *)dta :(NSString *)search;
- (NSMutableArray *) getDownloadingModule: (NSMutableArray *)dta;
- (NSMutableArray *) getNewModule: (NSMutableArray *)dta :(NSString *)User;

- (NSString *) getThumbnailsPath;

@end
