//
//  CRLViewController.m
//  InstallrCheckerDemo
//
//  Created by Tim Clem on 3/27/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRLViewController.h"
#import <CRLInstallrChecker/CRLInstallrChecker.h>

@interface CRLViewController ()

@end


@implementation CRLViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Insert your Installr app key below
    /*
    [CRLInstallrChecker sharedInstance].appKey = @"...";
    [[CRLInstallrChecker sharedInstance] checkNow];
     */
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
