//
//  ServerInterface.m
//  HelloWorld
//
//  Created by Robert Diamond on 4/28/12.
//  Copyright (c) 2012 Orbotix, Inc. All rights reserved.
//

#import "ServerInterface.h"
#import "XMLReader.h"

@interface ServerInterface ()
- (void)threadLoop;
- (void)notRunning;
@end

@implementation ServerInterface
@synthesize serverURL;
@synthesize shouldStop;
@synthesize lastResponseTime = _lastResponseTime;
@synthesize lastResponse = _lastResponse;
@synthesize delegate;

- (id)init {
    if ((self = [super init]) != nil) {
        self.shouldStop = NO;
        _lastResponse = nil;
    }
    return self;
}

- (void)dealloc {
    [serverURL release];
    [super dealloc];
}

- (void)setServerURL:(NSString *)serverURL_ {
    [serverURL release];
    serverURL = [serverURL_ copy];
    if (isRunning) {
        shouldStop = YES;
    } else {
        [self notRunning];
    }
}

- (NSDictionary *)lastResponse {
    return _lastResponse;
}

- (void)notRunning {
    [self performSelectorInBackground:@selector(threadLoop) withObject:nil];
}

- (void)threadLoop {
    if (serverURL.length == 0) return;
    
    isRunning = YES;
    NSURL *url = [NSURL URLWithString:self.serverURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url 
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                     timeoutInterval:15.0];
    NSURLResponse *resp = nil;
    NSError *error = nil;
    
    NSDictionary *currentResponse;
    
    while (!self.shouldStop) {
        resp = nil; error = nil;
        
        NSData *respData = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
        if (error) {
            NSLog(@"Failed to retrieve data: %@ (ignoring)", error);
        } else {
            currentResponse = [XMLReader dictionaryForXMLData:respData error:&error];
            
            if (error) {
                NSLog(@"Failed to parse XML data: %@", error);
            } else {
                @synchronized(self) {
                    _lastResponse = currentResponse;
                    _lastResponseTime = [NSDate date];
                }
                if (self.delegate) {
                    [self.delegate performSelector:@selector(didGetResponse)];
                }
            }
        }
        [NSThread sleepForTimeInterval:2.0f];
    }
    isRunning = NO;
    [self notRunning];
}
@end
