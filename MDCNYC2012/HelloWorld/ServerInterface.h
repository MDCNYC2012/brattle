//
//  ServerInterface.h
//  HelloWorld
//
//  Created by Robert Diamond on 4/28/12.
//  Copyright (c) 2012 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerDelegate <NSObject>

- (void)didGetResponse;

@end

@interface ServerInterface : NSObject {
    NSDictionary *_lastResponse;
    BOOL isRunning;
    NSDate *_lastResponseTime;
}

@property (nonatomic,assign) id<ServerDelegate> delegate;
@property (nonatomic,copy) NSString *serverURL;
@property (nonatomic,assign) BOOL shouldStop;
@property (readonly) NSDate *lastResponseTime;
@property (readonly) NSDictionary *lastResponse;

- (id)init;

@end
