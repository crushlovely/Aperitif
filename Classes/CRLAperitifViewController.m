// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import "CRLAperitifViewController.h"
#import "CRLInstallrAppData.h"


@interface CRLAperitifViewController ()

@property (nonatomic, weak) IBOutlet UITextView *releaseNotes;

@property (nonatomic, weak) IBOutlet UILabel *currentVersionLabel;
@property (nonatomic, weak) IBOutlet UILabel *updateVersionLabel;

@property (nonatomic, strong, readwrite) CRLInstallrAppData *appData;
@property (nonatomic, weak) id<CRLAperitifViewControllerDelegate> delegate;

@end


@implementation CRLAperitifViewController

-(id)initWithAppData:(CRLInstallrAppData *)appData delegate:(id<CRLAperitifViewControllerDelegate>)delegate
{
    self = [super initWithNibName:nil bundle:[NSBundle bundleForClass:[CRLAperitifViewController class]]];
    if(self) {
        _appData = appData;
        _delegate = delegate;
    }

    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

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
    if(self.appData.buildNumber.length > 0)
        buildDescription = [NSString stringWithFormat:@" (build %@)", self.appData.buildNumber];

    self.updateVersionLabel.text = [NSString stringWithFormat:self.updateVersionLabel.text, self.appData.versionNumber, buildDescription, [self timeAgoFromDate:self.appData.dateCreated]];

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
    [self.delegate cancelTappedInAperitifViewController:self];
}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate cancelTappedInAperitifViewController:self];
}

-(IBAction)updateButtonTapped:(id)sender
{
    [self.delegate updateTappedInAperitifViewController:self];
}


#pragma mark Utilities

-(NSString *)timeAgoFromDate:(NSDate *)date
{
    NSDate *now = [NSDate date];
    double dsecs = fabs([date timeIntervalSinceDate:now]);
    double dmins = dsecs / 60.0;

    if(dsecs < (60 * 5)) return @"just now";

    if(dmins < 60) return @"less than an hour ago";

    if(dmins < 120) return @"about an hour ago";

    if(dmins < (24 * 60))
    {
        int hours = (int)floor(dmins / 60.0);
        return [NSString stringWithFormat:@"%d hours ago", hours];
    }

    if(dmins < (24 * 60 * 2)) return @"yesterday";

    if(dmins < (24 * 60 * 7))
    {
        int days = (int)floor(dmins / (60 * 24));
        return [NSString stringWithFormat:@"%d days ago", days];
    }

    if(dmins < (24 * 60 * 14)) return @"last week";

    if(dmins < (24 * 60 * 31))
    {
        int weeks = (int)floor(dmins / (60 * 24 * 7));
        return [NSString stringWithFormat:@"%d weeks ago", weeks];
    }

    if(dmins < (24 * 60 * 61)) return @"last month";

    if(dmins < (24 * 60 * 365))
    {
        int months = (int)floor(dmins / (60 * 24 * 30));
        return [NSString stringWithFormat:@"%d months ago", months];
    }
    
    return @"over a year ago";
}

@end
