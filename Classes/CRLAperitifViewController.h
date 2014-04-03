//
//  CRLInstallrUpdateViewController.h
//  Aperitif
//
//  Created by Tim Clem on 3/26/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

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
