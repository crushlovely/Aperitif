// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import "CRLInstallrAppData.h"

static NSString * const CRLInstallrAppStatusUrlFormat = @"https://www.installrapp.com/apps/status/%@.json";

NS_INLINE id CRLNilIfNull(id obj) {
    if(obj == [NSNull null]) return nil;
    return obj;
}


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

+(void)fetchDataForNewestBuildWithAppToken:(NSString *)token completion:(void (^)(CRLInstallrAppData *))completionHandler
{
    NSURL *statusUrl = [NSURL URLWithString:[NSString stringWithFormat:CRLInstallrAppStatusUrlFormat, token]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:statusUrl];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPShouldHandleCookies = NO;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!data) {
            NSLog(@"[Aperitif] Error communicating with the Installr API: %@", connectionError);
            if(completionHandler) completionHandler(nil);
            return;
        }

        NSError *jsonError;
        NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if(!body) {
            NSLog(@"[Aperitif] Installr API returned invalid JSON: %@", jsonError);
            if(completionHandler) completionHandler(nil);
            return;
        }

        if(![body isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[Aperitif] Installr API returned unexpected JSON: root element is not a dictionary");
            if(completionHandler) completionHandler(nil);
            return;
        }

        NSDictionary *appDataDict = body[@"appData"];
        if(!appDataDict || ![appDataDict isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[Aperitif] Installr API returned unexpected JSON: 'appDict' property is missing or not a dictionary");
            if(completionHandler) completionHandler(nil);
            return;
        }

        CRLInstallrAppData *appData = [[CRLInstallrAppData alloc] initWithDictionary:appDataDict];

        if(appData) {
            NSString *currentBundleId = [NSBundle mainBundle].bundleIdentifier;
            if(![appData.bundleIdentifier isEqualToString:currentBundleId])
                NSLog(@"[Aperitif] Warning! Installr API returned information for an app with bundle id '%@', but the current app is '%@'. Did you use the wrong app key?", appData.bundleIdentifier, currentBundleId);
        }

        if(completionHandler) completionHandler(appData);
    }];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(!self) return nil;

    _bundleIdentifier = CRLNilIfNull(dictionary[@"appId"]);
    _installURL = [NSURL URLWithString:CRLNilIfNull(dictionary[@"installUrl"])];
    _title = CRLNilIfNull(dictionary[@"title"]);
    _releaseNotes = CRLNilIfNull(dictionary[@"releaseNotes"]);
    _versionNumber = CRLNilIfNull(dictionary[@"versionNumber"]);
    _buildNumber = CRLNilIfNull(dictionary[@"buildNumber"]);

    NSString *stringDate = CRLNilIfNull(dictionary[@"dateCreated"]);
    if(stringDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";

        _dateCreated = [dateFormatter dateFromString:stringDate];
    }

    return self;
}

@end
