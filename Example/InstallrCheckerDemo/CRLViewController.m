//
//  CRLViewController.m
//  InstallrCheckerDemo
//
//  Created by Tim Clem on 3/27/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRLViewController.h"
#import <Aperitif/CRLAperitif.h>

@interface CRLViewController ()

@end


@implementation CRLViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Insert your Installr app key below
    /*
    [CRLAperitif sharedInstance].appKey = @"...";
    [[CRLAperitif sharedInstance] checkNow];
     */
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
