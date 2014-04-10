// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import <Foundation/Foundation.h>

@interface CRLInstallrAppData : NSObject

/**
 Retrieves an instance for the most recent build uploaded to Installr.
 If there is an error, the callback will be called with a nil instance.
 The callback will be called on the main thread.
 */
+(void)fetchDataForNewestBuildWithAppToken:(NSString *)token completion:(void (^)(CRLInstallrAppData *appData))completionHandler;

/**
 Creates a new instance from the decoded JSON payload from the Installr API.
 Returns nil if there's a parse error or anything seems awry.
 */
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, readonly, strong) NSString *bundleIdentifier;
@property (nonatomic, readonly, strong) NSURL *installURL;
@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, strong) NSString *releaseNotes;
@property (nonatomic, readonly, strong) NSString *versionNumber;
@property (nonatomic, readonly, strong) NSString *buildNumber;
@property (nonatomic, readonly, strong) NSDate *dateCreated;

@end
