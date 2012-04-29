//
//  NSDictionary+Brattle.m
//  HelloWorld
//
//  Created by Robert Diamond on 4/29/12.
//  Copyright (c) 2012 Orbotix, Inc. All rights reserved.
//

#import "NSDictionary+Brattle.h"

@implementation NSDictionary (Brattle)
- (NSString *)stringOrNilForKey:(NSString *)key {
    NSDictionary *subDict = [self valueForKey:key];
    if (!subDict) return nil;
    NSString *val = [subDict valueForKey:@"text"];
    return val;
}
@end
