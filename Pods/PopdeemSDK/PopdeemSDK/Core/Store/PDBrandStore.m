//
//  PDBrandStore.m
//  PopdeemSDK
//
//  Created by Niall Quinn on 25/08/2015.
//  Copyright (c) 2015 Popdeem. All rights reserved.
//

#import "PDBrandStore.h"
#import "PDUser.h"

@implementation PDBrandStore

+ (NSMutableDictionary *) store {
    static dispatch_once_t pred;
    static NSMutableDictionary *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[NSMutableDictionary alloc] init];
    });
    return sharedInstance;
}

+ (void) add:(PDBrand*)b {
    [[PDBrandStore store] setObject:b forKey:@(b.identifier)];
}

+ (NSArray*) allBrands {
    return [[PDBrandStore store] allValues];
}

+ (nullable PDBrand*) findBrandByIdentifier:(NSInteger)identifier {
    return [[PDBrandStore store] objectForKey:@(identifier)];
}

+ (nullable PDBrand*) findBrandBySearchTerm:(NSString*)searchTerm {
    PDBrand *found = nil;
    for (PDBrand *b in [[PDBrandStore store] allValues]) {
        if ([b.vendorSearchTerm isEqualToString:searchTerm]) {
            found = b;
            break;
        }
    }
    return found;
}

+ (NSArray *) orderedByDistanceFromUser {
  if ([[PDUser sharedInstance] userToken] == nil) {
    return [[[PDBrandStore store] allValues] sortedArrayUsingSelector:@selector(compare:)];
  }
    return [[[PDBrandStore store] allValues] sortedArrayUsingSelector:@selector(compareDistance:)];
}

+ (NSArray *) orderedByName {
    return [[[PDBrandStore store] allValues] sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSInteger) count {
    return [[[PDBrandStore store] allValues] count];
}

@end
