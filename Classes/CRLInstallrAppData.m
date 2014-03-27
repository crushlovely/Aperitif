//
//  CRLInstallrAppData.m
//  tgmathtest
//
//  Created by Tim Clem on 3/24/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRLInstallrAppData.h"

NSString * const CRLInstallrAppStatusUrlFormat = @"https://www.installrapp.com/apps/status/%@.json";


@interface CRLInstallrAppData ()

@property (nonatomic, readwrite, strong) NSString *bundleIdentifier;
@property (nonatomic, readwrite, strong) NSURL *installURL;
@property (nonatomic, readwrite, strong) NSString *title;
@property (nonatomic, readwrite, strong) NSString *releaseNotes;
@property (nonatomic, readwrite, strong) NSString *versionNumber;
@property (nonatomic, readwrite, strong) NSString *buildNumber;
@property (nonatomic, readwrite, strong) NSDate *dateCreated;

@end


@implementation CRLInstallrAppData

+(void)fetchDataForNewestBuildWithAppKey:(NSString *)key completion:(void (^)(CRLInstallrAppData *))completionHandler
{
    NSURL *statusUrl = [NSURL URLWithString:[NSString stringWithFormat:CRLInstallrAppStatusUrlFormat, key]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:statusUrl];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPShouldHandleCookies = NO;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!data) {
            NSLog(@"[CRLInstallrUpdateChecker] Error communicating with the Installr API: %@", connectionError);
            if(completionHandler) completionHandler(nil);
            return;
        }

        NSError *jsonError;
        NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if(!body) {
            NSLog(@"[CRLInstallrUpdateChecker] Installr API returned invalid JSON: %@", jsonError);
            if(completionHandler) completionHandler(nil);
            return;
        }

        if(![body isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[CRLInstallrUpdateChecker] Installr API returned unexpected JSON: root element is not a dictionary");
            if(completionHandler) completionHandler(nil);
            return;
        }

        NSDictionary *appDataDict = body[@"appData"];
        if(!appDataDict || ![appDataDict isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[CRLInstallrUpdateChecker] Installr API returned unexpected JSON: 'appDict' property is missing or not a dictionary");
            if(completionHandler) completionHandler(nil);
            return;
        }

        CRLInstallrAppData *appData = [[CRLInstallrAppData alloc] initWithDictionary:appDataDict];

        NSString *currentBundleId = [[NSBundle mainBundle] bundleIdentifier];
        if(![appData.bundleIdentifier isEqualToString:currentBundleId]) {
            NSLog(@"[CRLInstallrUpdateChecker] Warning! Installr API returned information for an app with bundle id '%@', but the current app is '%@'. Did you use the wrong app key?", appData.bundleIdentifier, currentBundleId);
        }

        if(completionHandler) completionHandler(appData);
    }];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(!self) return nil;

    _bundleIdentifier = dictionary[@"appId"];
    _installURL = [NSURL URLWithString:dictionary[@"installUrl"]];
    _title = dictionary[@"title"];
    _releaseNotes = dictionary[@"releaseNotes"];
    _versionNumber = dictionary[@"versionNumber"];
    _buildNumber = dictionary[@"buildNumber"];
    if(_buildNumber == (id)[NSNull null]) _buildNumber = @"";

    NSString *stringDate = dictionary[@"dateCreated"];
    if(stringDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";

        _dateCreated = [dateFormatter dateFromString:stringDate];
    }

    return self;
}

@end
