//
//  CRLInstallrUpdateChecker.m
//  Aperitif
//
//  Created by Tim Clem on 3/26/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRLAperitif.h"
#import "CRLInstallrAppData.h"
#import "CRLAperitifViewController.h"
#import <MZFormSheetController/MZFormSheetController.h>

static NSString * const CRLMostRecentHandledVersionDefaultsKey = @"_CRLInstallrMostRecentHandledVersion";


@interface CRLAperitif () <CRLAperitifViewControllerDelegate>

@property (nonatomic, strong) MZFormSheetController *formController;

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
/*    __weak CRLAperitif *weakSelf = self;
    [CRLInstallrAppData fetchDataForNewestBuildWithAppKey:self.appKey completion:^(CRLInstallrAppData *appData) {
        if(!appData) return;

        CRLAperitif *strongSelf = weakSelf;

        if([strongSelf appDataIsForANewVersion:appData]) {
            NSLog(@"[CRLInstallrUpdateChecker] Found a new version on the server! %@ (build %@), released %@.", appData.versionNumber, appData.buildNumber, appData.dateCreated);
            [strongSelf presentUpdateModalForAppData:appData];
        }
        else {
            [strongSelf markAppDataAsHandled:appData];
        }
    }];*/

    [self presentUpdateModalForAppData:nil];
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

    [[NSUserDefaults standardUserDefaults] setObject:@{
       @"versionNumber": appData.versionNumber,
       @"buildNumber": appData.buildNumber,
       @"dateCreated": appData.dateCreated
    } forKey:CRLMostRecentHandledVersionDefaultsKey];
}

-(NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB
{
    NSArray *componentsA = [versionA componentsSeparatedByString:@"."];
    NSArray *componentsB = [versionB componentsSeparatedByString:@"."];

    // If the two versions have a different number of components, pad the smaller one with
    // zeros until they're of equal length.
    if(componentsA.count != componentsB.count) {
        NSMutableArray *padding = [NSMutableArray array];
        NSUInteger diff = labs(componentsA.count - componentsB.count);
        for(NSUInteger i = 0; i < diff; i++) [padding addObject:@"0"];

        if(componentsA.count < componentsB.count) componentsA = [componentsA arrayByAddingObjectsFromArray:padding];
        else componentsB = [componentsB arrayByAddingObjectsFromArray:padding];
    }

    // Now, walk the components in pairs
    for(NSUInteger i = 0; i < componentsA.count; i++) {
        NSString *componentA = componentsA[i];
        NSString *componentB = componentsB[i];

        // If the strings are literally equal, move on to the next component.
        // No need for the number conversion.
        if([componentA isEqualToString:componentB]) continue;

        NSInteger numA = [componentA integerValue];
        NSInteger numB = [componentB integerValue];

        if(numA > numB) return NSOrderedDescending;
        else if(numA < numB) return NSOrderedAscending;
    }

    return NSOrderedSame;
}

-(BOOL)appDataIsForANewVersion:(CRLInstallrAppData *)appData
{
    if([self appDataHasBeenHandled:appData]) return NO;

    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    // Compare version first
    NSComparisonResult comparison = [self compareVersion:versionNumber toVersion:appData.versionNumber];
    if(comparison == NSOrderedAscending) return YES;
    if(comparison == NSOrderedDescending) return NO;

    // If the major versions are equal, check the build number
    if(appData.buildNumber && appData.buildNumber.length > 0)
        comparison = [self compareVersion:buildNumber toVersion:appData.buildNumber];
    
    return comparison == NSOrderedAscending;
}


#pragma mark CRLInstallerUpdateViewControllerDelegate

-(void)cancelTappedInAperitifViewController:(CRLAperitifViewController *)viewController
{
    [viewController.formSheetController dismissAnimated:YES completionHandler:nil];
    [self markAppDataAsHandled:viewController.appData];
}

-(void)updateTappedInAperitifViewController:(CRLAperitifViewController *)viewController
{
    NSURL *installURL = viewController.appData.installURL;

    [viewController.formSheetController dismissAnimated:YES completionHandler:nil];
    [self markAppDataAsHandled:viewController.appData];

    [[UIApplication sharedApplication] openURL:installURL];
}

@end
