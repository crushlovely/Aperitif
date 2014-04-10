// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import <Foundation/Foundation.h>

/**
 A class used to check for new versions of the current application in the Installr
 distribution system - https://installrapp.com - and prompt the user to upgrade.

 You shouldn't have to create your own instances of this class; use the +sharedInstance
 singleton.
 */
@interface CRLAperitif : NSObject

/**
 The singleton instance of CRLAperitif.
 */
+(instancetype)sharedInstance;


/**
 Your unique Installr application token. This can be found on the Settings page for
 your app in the Installr Dashboard. This value must be set before any of the -check
 methods are called.
 */
@property (nonatomic, copy) NSString *appToken;


/**
 Immediately checks for a new version of the application.
 Errors are logged to the console but otherwise ignored.
 
 If a new version is found, a modal dialog prompting the user to update is presented.
 
 Note that if it's been less than 10 minutes since the previous check, this method will do nothing.
 */
-(void)checkNow;

/**
 Schedules a check for a new version of the application after the given delay.
 The check will run on the low-priority dispatch queue.
 Errors are logged to the console but otherwise ignored.

 If a new version is found, a modal dialog prompting the user to update is presented.

 Note that if it's been less than 10 minutes since the previous check, this method will do nothing.
 */
-(void)checkAfterDelay:(NSTimeInterval)delay;


#ifdef DEBUG
/**
 Presents a dummy update modal, so you can get a feel for how it will look in production.
 */
-(void)presentModalForTesting;
#endif

@end
