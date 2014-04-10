#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "../../Classes/NSString+CRLVersionComparison.h"

// It's important that these results are commutative. Hence each expectation
// expanding to two tests.
// Yes, I should write real checkers for these...

#define expectAscendingVersions(a, b) do { \
        expect([a crl_dottedVersionCompare:b]).to.equal(NSOrderedAscending);  \
        expect([b crl_dottedVersionCompare:a]).to.equal(NSOrderedDescending); \
    } while(0)

#define expectEqualVersions(a, b) do { \
        expect([a crl_dottedVersionCompare:b]).to.equal(NSOrderedSame); \
        expect([b crl_dottedVersionCompare:a]).to.equal(NSOrderedSame); \
    } while(0)

#define expectComparisonNotToThrow(a, b) do { \
        expect(^{ [a crl_dottedVersionCompare:b]; }).toNot.raiseAny(); \
        expect(^{ [b crl_dottedVersionCompare:a]; }).toNot.raiseAny(); \
    } while(0)


SpecBegin(CRLVersionComparison)

it(@"should handle straightforward version equalities", ^{
    expectEqualVersions(@"1", @"1");
    expectEqualVersions(@"1.1", @"1.1");
    expectEqualVersions(@"1.11", @"1.11");
    expectEqualVersions(@"1.0", @"1.00");
    expectEqualVersions(@"1.01", @"1.1");
    expectEqualVersions(@"1.0.10", @"1.0.10");
    expectEqualVersions(@".1", @".01");
});

it(@"should handle equal versions with differing numbers of components", ^{
    expectEqualVersions(@"1.0.0", @"1.0");
    expectEqualVersions(@"1.0.0", @"1");
    expectEqualVersions(@"1.2.0", @"1.2");
    expectEqualVersions(@"1.0.2", @"1.0.2.0.0");
    expectEqualVersions(@"0.1", @".1");
    expectEqualVersions(@"1", @"1.0.0");
});

it(@"should handle straightforward version inequalities", ^{
    expectAscendingVersions(@"1", @"2");
    expectAscendingVersions(@"1.1", @"1.2");
    expectAscendingVersions(@"1.11", @"1.12");
    expectAscendingVersions(@"1.0", @"1.01");
    expectAscendingVersions(@"1.01", @"1.2");
    expectAscendingVersions(@"1.0.10", @"1.0.11");
    expectAscendingVersions(@"1.0.9", @"1.0.10");
    expectAscendingVersions(@".1", @".02");
});

it(@"should handle version inequalities with differing numbers of components", ^{
    expectAscendingVersions(@"1.0", @"2");
    expectAscendingVersions(@"1.1", @"1.2.0");
    expectAscendingVersions(@"1.11.0", @"1.12");
    expectAscendingVersions(@"1.9", @"1.10.0");
    expectAscendingVersions(@"1", @"1.0.1");
});

it(@"shouldn't bomb on weird input", ^{
    // The behavior in these cases is defined to be undefined :)
    // But at the very least, we shouldn't crash.

    expectComparisonNotToThrow(@"1.0", @"1.0-pre4");
    expectComparisonNotToThrow(@"1.0", @"a");
    expectComparisonNotToThrow(@"1.0", @"");
    expectComparisonNotToThrow(@"1.0", (id)nil);
    expectComparisonNotToThrow(@"1.0", @"-0");
    expectComparisonNotToThrow(@"1.0", @"!!!!");
});

SpecEnd