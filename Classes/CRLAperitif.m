// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import "CRLAperitif.h"
#import "CRLInstallrAppData.h"
#import "CRLAperitifViewController.h"
#import "NSString+CRLVersionComparison.h"
#import <MZFormSheetController/MZFormSheetController.h>

static NSString * const CRLMostRecentHandledVersionDefaultsKey = @"_CRLAperitifMostRecentHandledVersion";
static NSString * const CRLLastCheckDateDefaultKey = @"_CRLAperitifLastCheckDate";
static const NSUInteger CRLMinimumMinutesBetweenChecks = 10;


@interface CRLAperitif () <CRLAperitifViewControllerDelegate>

@property (nonatomic, strong) MZFormSheetController *formController;
@property (nonatomic, assign, getter=isCheckingOrDisplayingModal) BOOL checkingOrDisplayingModal;
@property (nonatomic, assign) BOOL currentModalIsTesting;

@property (nonatomic, readonly) NSUInteger minutesSinceLastCheck;
@property (nonatomic, strong) NSDate *lastCheckDate;

@end


@implementation CRLAperitif

+(instancetype)sharedInstance
{
    static CRLAperitif *staticInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[CRLAperitif alloc] init];
    });

    return staticInstance;
}

-(void)checkNow
{
    // In case we're called from an app delegate method during some background processing...
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
        return;

    if(self.appToken.length == 0) {
        NSLog(@"[Aperitif] You must set your Installr app token before checking for updates");
        return;
    }

    if(self.isCheckingOrDisplayingModal) {
        NSLog(@"[Aperitif] Was asked to check for an update, but a check or update prompt is currently in progress. Ignoring.");
        return;
    }

    if(self.minutesSinceLastCheck < CRLMinimumMinutesBetweenChecks) {
        NSLog(@"[Aperitif] Was asked to check for an update, but it's only been %lu minutes since the last check (min. is %lu). Ignoring.", (unsigned long)self.minutesSinceLastCheck, (unsigned long)CRLMinimumMinutesBetweenChecks);
        return;
    }

    self.checkingOrDisplayingModal = YES;

    __weak CRLAperitif *weakSelf = self;
    [CRLInstallrAppData fetchDataForNewestBuildWithAppToken:self.appToken completion:^(CRLInstallrAppData *appData) {
        CRLAperitif *strongSelf = weakSelf;

        // Record the time of this check, even if it's not new, and even if it's an error;
        // we don't want to spam the Installr API
        strongSelf.lastCheckDate = [NSDate date];

        // nil appdata means an error must have occurred.
        if(!appData) {
            strongSelf.checkingOrDisplayingModal = NO;
            return;
        }

        if([strongSelf appDataIsForANewVersion:appData]) {
            NSLog(@"[Aperitif] Found a new version on the server! %@ (build %@), released %@.", appData.versionNumber, appData.buildNumber, appData.dateCreated);
            [strongSelf presentUpdateModalForAppData:appData];
        }
        else {
            self.checkingOrDisplayingModal = NO;
            [strongSelf markAppDataAsHandled:appData];
        }
    }];
}

#ifdef DEBUG
-(void)presentModalForTesting
{
    __weak CRLAperitif *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        CRLAperitif *strongSelf = weakSelf;

        CRLInstallrAppData *fakeData = [[CRLInstallrAppData alloc] initWithDictionary:@{
            @"installUrl": @"https://installrapp.com",
            @"title": @"Testing Aperitif",
            @"releaseNotes": @"Your release notes would live here:\n\n* Fixed some bugs\n* Danced in the moonlight\n* Updated the backend widget combobulator\n* M. R. Ducks\n\nEtc. etc. etc. You know the drill. Clients love prose.",
            @"versionNumber": @"9.2.5",
            @"buildNumber": @"23",
            @"dateCreated": @"2014-04-01T12:42:13Z"
        }];
        strongSelf.currentModalIsTesting = YES;
        [strongSelf presentUpdateModalForAppData:fakeData];
    }];
}
#endif

-(void)checkAfterDelay:(NSTimeInterval)delay
{
    dispatch_queue_t lowPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_time_t delta = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));

    __weak CRLAperitif *weakSelf = self;
    dispatch_after(delta, lowPriorityQueue, ^{
        CRLAperitif *strongSelf = weakSelf;
        [strongSelf checkNow];
    });
}


#pragma mark UI

-(void)presentUpdateModalForAppData:(CRLInstallrAppData *)appData
{
    CRLAperitifViewController *updateViewController = [[CRLAperitifViewController alloc] initWithAppData:appData delegate:self];
    MZFormSheetController *formController = [[MZFormSheetController alloc] initWithViewController:updateViewController];
    formController.transitionStyle = MZFormSheetTransitionStyleFade;
    formController.cornerRadius = 0.0;
    formController.shadowOpacity = 0.25;

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        formController.shouldCenterVertically = NO;

        CGSize formSize = [UIScreen mainScreen].bounds.size;  // Always in portrait
        if(formSize.height < 568.0) {
            // Do some jiggery-pokery for 3.5" screens. Should really just be using autolayout like the rest of the sane world...
            formSize.height += 40.0;
            formController.portraitTopInset = -40.0;
        }
        else {
            formController.portraitTopInset = 0.0;
        }
        formController.presentedFormSheetSize = formSize;
    }
    else {
        formController.presentedFormSheetSize = CGSizeMake(504.0, 700.0);
        formController.shouldCenterVertically = NO;
        formController.portraitTopInset = 0.0;
        formController.landscapeTopInset = -100.0;

        __weak typeof(self) weakSelf = self;
        __weak typeof(updateViewController) weakVC = updateViewController;
        formController.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
            [weakSelf cancelTappedInAperitifViewController:weakVC];
        };
    }

    [MZFormSheetController sharedBackgroundWindow].backgroundBlurEffect = YES;
    [MZFormSheetController sharedBackgroundWindow].blurSaturation = 0.75;
    [MZFormSheetController sharedBackgroundWindow].blurTintColor = [UIColor colorWithRed:0.616 green:0.804 blue:0.808 alpha:0.65];
    [MZFormSheetController sharedBackgroundWindow].backgroundColor = [UIColor clearColor];

    [formController presentAnimated:YES completionHandler:nil];

    self.formController = formController;
}


#pragma mark Version Comparison and bookkeeping

-(BOOL)appDataHasBeenHandled:(CRLInstallrAppData *)appData
{
    NSDictionary *mostRecentHandledVersion = [[NSUserDefaults standardUserDefaults] objectForKey:CRLMostRecentHandledVersionDefaultsKey];
    if(!mostRecentHandledVersion)
        return NO;

    if([mostRecentHandledVersion[@"versionNumber"] isEqualToString:appData.versionNumber] &&
       [mostRecentHandledVersion[@"buildNumber"] isEqualToString:appData.buildNumber] &&
       [mostRecentHandledVersion[@"dateCreated"] isEqual:appData.dateCreated])
    {
        return YES;
    }

    return NO;
}

-(void)markAppDataAsHandled:(CRLInstallrAppData *)appData
{
    if(!appData) return;

    if(self.currentModalIsTesting) return;  // Don't record anything when testing the modal

    [[NSUserDefaults standardUserDefaults] setObject:@{
       @"versionNumber": appData.versionNumber,
       @"buildNumber": appData.buildNumber,
       @"dateCreated": appData.dateCreated
    } forKey:CRLMostRecentHandledVersionDefaultsKey];
}

-(BOOL)appDataIsForANewVersion:(CRLInstallrAppData *)appData
{
    if([self appDataHasBeenHandled:appData]) return NO;

    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    // Compare version first
    NSComparisonResult comparison = [versionNumber crl_dottedVersionCompare:appData.versionNumber];
    if(comparison == NSOrderedAscending) return YES;
    if(comparison == NSOrderedDescending) return NO;

    // If the major versions are equal, check the build number
    if(appData.buildNumber && appData.buildNumber.length > 0)
        comparison = [buildNumber crl_dottedVersionCompare:appData.buildNumber];
    
    return comparison == NSOrderedAscending;
}

-(NSDate *)lastCheckDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:CRLLastCheckDateDefaultKey];
}

-(void)setLastCheckDate:(NSDate *)lastCheckDate
{
    [[NSUserDefaults standardUserDefaults] setObject:lastCheckDate forKey:CRLLastCheckDateDefaultKey];
}

-(NSUInteger)minutesSinceLastCheck
{
    NSDate *lastCheck = self.lastCheckDate;
    if(!lastCheck) return NSUIntegerMax;
    return (NSUInteger)ceil(fabs([lastCheck timeIntervalSinceNow]) / 60.0);
}

#pragma mark CRLInstallerUpdateViewControllerDelegate

-(void)cancelTappedInAperitifViewController:(CRLAperitifViewController *)viewController
{
    self.checkingOrDisplayingModal = NO;
    [viewController.formSheetController dismissAnimated:YES completionHandler:nil];
    [self markAppDataAsHandled:viewController.appData];
    self.currentModalIsTesting = NO;
}

-(void)updateTappedInAperitifViewController:(CRLAperitifViewController *)viewController
{
    self.checkingOrDisplayingModal = NO;

    NSURL *installURL = viewController.appData.installURL;

    [viewController.formSheetController dismissAnimated:YES completionHandler:nil];
    [self markAppDataAsHandled:viewController.appData];
    self.currentModalIsTesting = YES;

    [[UIApplication sharedApplication] openURL:installURL];
}

@end
