//
//  ViewController.h
//  HelloWorld
//
//  Created by Jon Carroll on 12/8/11.
//  Copyright (c) 2011 Orbotix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerInterface.h"

enum GameState {
    WAITING,
    PLAYING,
    FINISHED
};

@interface ViewController : UIViewController<ServerDelegate> {
    BOOL ledON;
    BOOL robotOnline;
    enum GameState _state;
    CGFloat _red, _green, _blue;
    NSString *macro;
}

@property (nonatomic, assign) IBOutlet UIWebView *introView;
@property (nonatomic, assign) enum GameState state;
-(void)setupRobotConnection;
-(void)handleRobotOnline;
-(void)toggleLED;

@end

