// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import <UIKit/UIKit.h>


@class CRLAperitifViewController;
@class CRLInstallrAppData;

@protocol CRLAperitifViewControllerDelegate <NSObject>

@required
-(void)updateTappedInAperitifViewController:(CRLAperitifViewController *)viewController;
-(void)cancelTappedInAperitifViewController:(CRLAperitifViewController *)viewController;

@end


@interface CRLAperitifViewController : UIViewController

@property (nonatomic, strong, readonly) CRLInstallrAppData *appData;

-(id)initWithAppData:(CRLInstallrAppData *)appData delegate:(id<CRLAperitifViewControllerDelegate>)delegate;

@end
