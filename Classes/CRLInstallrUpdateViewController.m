//
//  CRLInstallrUpdateViewController.m
//  CRLInstallrChecker
//
//  Created by Tim Clem on 3/26/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRLInstallrUpdateViewController.h"
#import "CRLInstallrAppData.h"


@interface CRLInstallrUpdateViewController ()

@property (nonatomic, weak) IBOutlet UITextView *releaseNotes;

@property (nonatomic, weak) IBOutlet UILabel *currentVersionLabel;
@property (nonatomic, weak) IBOutlet UILabel *updateVersionLabel;

@property (nonatomic, strong, readwrite) CRLInstallrAppData *appData;
@property (nonatomic, weak) id<CRLInstallerUpdateViewControllerDelegate> delegate;

@end


@implementation CRLInstallrUpdateViewController

-(id)initWithAppData:(CRLInstallrAppData *)appData delegate:(id<CRLInstallerUpdateViewControllerDelegate>)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _appData = appData;
        _delegate = delegate;
    }

    return self;
}

-(void)viewDidLoad
{
    self.releaseNotes.text = self.appData.releaseNotes;

    // There's an iOS 7 bug where custom fonts on UITextViews set from NIBs don't work unless you set
    // them again after setting the text. Blaaaah.
    CGFloat fontSize = 16.0;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) fontSize = 14.0;
    self.releaseNotes.font = [UIFont fontWithName:@"Avenir-Roman" size:fontSize];

    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.currentVersionLabel.text = [NSString stringWithFormat:self.currentVersionLabel.text, versionNumber, buildNumber];

    NSString *buildDescription = @"";
    if(self.appData.buildNumber && self.appData.buildNumber.length > 0)
        buildDescription = [NSString stringWithFormat:@" (build %@)", self.appData.buildNumber];

    self.updateVersionLabel.text = [NSString stringWithFormat:self.updateVersionLabel.text, self.appData.versionNumber, buildDescription,[self timeAgoFromDate:self.appData.dateCreated]];

    self.releaseNotes.textContainerInset = UIEdgeInsetsZero;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.releaseNotes flashScrollIndicators];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationPortrait;

    // This is the default:
    return [UIApplication sharedApplication].statusBarOrientation;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskPortrait;

    return UIInterfaceOrientationMaskAll;
}


#pragma mark Interaction

-(IBAction)backgroundButtonTapped:(id)sender
{
    [self.delegate cancelTappedInInstallrUpdateViewController:self];
}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate cancelTappedInInstallrUpdateViewController:self];
}

-(IBAction)updateButtonTapped:(id)sender
{
    [self.delegate updateTappedInInstallrUpdateViewController:self];
}


#pragma mark Utilities

-(NSString *)timeAgoFromDate:(NSDate *)date
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([date timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;

    int minutes;

    if(deltaSeconds < 120)
    {
        return @"just now";
    }
    else if (deltaMinutes < 60)
    {
        return [NSString stringWithFormat:@"%d minutes ago", (int)deltaMinutes];
    }
    else if (deltaMinutes < 120)
    {
        return @"an hour ago";
    }
    else if (deltaMinutes < (24 * 60))
    {
        minutes = (int)floor(deltaMinutes/60);
        return [NSString stringWithFormat:@"%d hours ago", minutes];
    }
    else if (deltaMinutes < (24 * 60 * 2))
    {
        return @"yesterday";
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24));
        return [NSString stringWithFormat:@"%d days ago", minutes];
    }
    else if (deltaMinutes < (24 * 60 * 14))
    {
        return @"last week";
    }
    else if (deltaMinutes < (24 * 60 * 31))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7));
        return [NSString stringWithFormat:@"%d weeks ago", minutes];
    }
    else if (deltaMinutes < (24 * 60 * 61))
    {
        return @"last month";
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 30));
        return [NSString stringWithFormat:@"%d months ago", minutes];
    }
    else if (deltaMinutes < (24 * 60 * 731))
    {
        return @"last year";
    }

    minutes = (int)floor(deltaMinutes/(60 * 24 * 365));
    return [NSString stringWithFormat:@"%d years ago", minutes];
}

@end
