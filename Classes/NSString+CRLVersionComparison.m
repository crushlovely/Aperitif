// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import "NSString+CRLVersionComparison.h"

@implementation NSString (CRLVersionComparison)

-(NSComparisonResult)crl_dottedVersionCompare:(NSString *)string
{
    NSArray *componentsA = [self componentsSeparatedByString:@"."];
    NSArray *componentsB = [string componentsSeparatedByString:@"."];

    // If the two versions have a different number of components, pad the smaller one with
    // zeros until they're of equal length.
    if(componentsA.count != componentsB.count) {
        NSMutableArray *padding = [NSMutableArray array];
        NSUInteger diff = labs(componentsA.count - componentsB.count);
        for(NSUInteger i = 0; i < diff; i++) [padding addObject:@"0"];

        if(componentsA.count < componentsB.count) componentsA = [componentsA arrayByAddingObjectsFromArray:padding];
        else componentsB = [componentsB arrayByAddingObjectsFromArray:padding];
    }

    // Now, walk the components in pairs
    for(NSUInteger i = 0; i < componentsA.count; i++) {
        NSString *componentA = componentsA[i];
        NSString *componentB = componentsB[i];

        // If the strings are literally equal, move on to the next component.
        // No need for the number conversion.
        if([componentA isEqualToString:componentB]) continue;

        NSInteger numA = [componentA integerValue];
        NSInteger numB = [componentB integerValue];

        if(numA > numB) return NSOrderedDescending;
        else if(numA < numB) return NSOrderedAscending;
    }
    
    return NSOrderedSame;
}

@end
