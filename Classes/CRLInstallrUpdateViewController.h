//
//  CRLInstallrUpdateViewController.h
//  CRLInstallrChecker
//
//  Created by Tim Clem on 3/26/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CRLInstallrUpdateViewController;
@class CRLInstallrAppData;

@protocol CRLInstallerUpdateViewControllerDelegate <NSObject>

@required
-(void)updateTappedInInstallrUpdateViewController:(CRLInstallrUpdateViewController *)viewController;
-(void)cancelTappedInInstallrUpdateViewController:(CRLInstallrUpdateViewController *)viewController;

@end


@interface CRLInstallrUpdateViewController : UIViewController

@property (nonatomic, strong, readonly) CRLInstallrAppData *appData;

-(id)initWithAppData:(CRLInstallrAppData *)appData delegate:(id<CRLInstallerUpdateViewControllerDelegate>)delegate;

@end
