//
//  CRLInstallrAppData.h
//  Aperitif
//
//  Created by Tim Clem on 3/24/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRLInstallrAppData : NSObject

+(void)fetchDataForNewestBuildWithAppToken:(NSString *)token completion:(void (^)(CRLInstallrAppData *appData))completionHandler;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, readonly, strong) NSString *bundleIdentifier;
@property (nonatomic, readonly, strong) NSURL *installURL;
@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, strong) NSString *releaseNotes;
@property (nonatomic, readonly, strong) NSString *versionNumber;
@property (nonatomic, readonly, strong) NSString *buildNumber;
@property (nonatomic, readonly, strong) NSDate *dateCreated;

@end
