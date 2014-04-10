// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import "CRLAppDelegate.h"
#import <Aperitif/CRLAperitif.h>

@implementation CRLAppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     This is the recommended point to run the update check. This method is called both on
     fresh launch of the app, and after resuming from the background.
     
     Aperitif automatically checks if the application state is active (i.e., that we're
     not being woken up for background processing). It also limits checks to one every
     10 minutes.
     
     The 3 second delay is intended to make let the application get through its own
     initialization before running the update check. Adjust the delay as needed, or
     perhaps move the code elsewhere. -checkNow is the no-delay version of -checkAfterDelay.
     
     Make sure to only run this code in ad hoc builds. The easiest way to do that is
     probably to define a preprocessor variable in that configuration.
     
     See the guide here for one way to do that:
     https://github.com/CocoaLumberjack/CocoaLumberjack/wiki/XcodeTricks#details
     */

    #if CONFIGURATION_ADHOC
    [CRLAperitif sharedInstance].appToken = @"<Your App Token Here>";
    [[CRLAperitif sharedInstance] checkAfterDelay:3.0];
    #endif

    #ifdef DEBUG
    // To see what an end-user would see, you can call this method:
    [[CRLAperitif sharedInstance] presentModalForTesting];
    #endif
}

@end
