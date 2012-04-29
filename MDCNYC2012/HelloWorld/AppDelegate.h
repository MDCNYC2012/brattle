//
//  AppDelegate.h
//  HelloWorld
//
//  Created by Jon Carroll on 12/8/11.
//  Copyright (c) 2011 Orbotix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class ServerInterface;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) ServerInterface *interface;
@property (strong, nonatomic) NSString *urlBase;

@end
