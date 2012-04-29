//
//  ViewController.m
//  HelloWorld
//
//  Created by Jon Carroll on 12/8/11.
//  Copyright (c) 2011 Orbotix, Inc. All rights reserved.
//
#import "AppDelegate.h"
#import "ViewController.h"

#import "RobotKit/RobotKit.h"
#import "RobotKit/RKRunMacroCommand.h"
#import "RobotKit/RKSaveMacroCommand.h"
#import "NSDictionary+Brattle.h"

@interface ViewController()
- (void)updateState:(NSNumber *)newState;
@end
@implementation ViewController
@synthesize state = _state;
@synthesize introView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.state = WAITING;
    
    /*Register for application lifecycle notifications so we known when to connect and disconnect from the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    /*Only start the blinking loop when the view loads*/
    robotOnline = NO;
    
    [introView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)appWillResignActive:(NSNotification*)notification {
    /*When the application is entering the background we need to close the connection to the robot*/
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
}

-(void)appDidBecomeActive:(NSNotification*)notification {
    /*When the application becomes active after entering the background we try to connect to the robot*/
    [self setupRobotConnection];
    // Re-set us to the current state so the state change logic occurs
    self.state = _state;
}

- (void)handleRobotOnline {
    NSLog(@"robot online: %d", robotOnline);
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline) {
        /*Only start the blinking loop once*/
        [self toggleLED];
    }
    robotOnline = YES;
}

- (void)toggleLED {
    /*Toggle the LED on and off*/
    if (ledON) {
        ledON = NO;
        [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    } else {
        ledON = YES;
        [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:1.0];
    }
    [self performSelector:@selector(toggleLED) withObject:nil afterDelay:0.5];
}

-(void)setupRobotConnection {
    /*Try to connect to the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];        
    }
}
- (void)updateState:(NSNumber *)newState {
    self.state = [newState intValue];
}
- (void)setState:(enum GameState)newState {
    if (!robotOnline) { _state = newState; return; }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (newState) {
        case WAITING:
            ledON = YES;
            [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:1.0];
            break;
        case PLAYING:
            // We have a color and a distance
            [RKRGBLEDOutputCommand sendCommandWithRed:_red green:_green blue:_blue];
            [RKRollCommand sendCommandWithHeading:0.0 velocity:0.5];
            [[[[RKRollCommand alloc] initWithHeading:0.0 velocity:0.0] autorelease] sendCommandWithDelay:0.75];
            [self performSelector:@selector(updateState) 
                       withObject:[NSNumber numberWithInt:WAITING] 
                       afterDelay:0.8];
            break;
        case FINISHED: {
            NSURL *danceURL = [NSURL 
                               URLWithString:[NSString 
                                              stringWithFormat:@"%@%@", 
                                              app.urlBase, macro]];
            NSURLRequest *danceReq = [NSURLRequest requestWithURL:danceURL];
            NSError *error = nil;
            NSURLResponse *resp = nil;
            NSData *danceMacro = [NSURLConnection sendSynchronousRequest:danceReq returningResponse:&resp error:&error];
            if (!error) {
                RKSaveMacroCommand *rsm = [[RKSaveMacroCommand alloc] initWithMacro:danceMacro macroID:2 flags:RKMacroFlagMotorControl|RKMacroFlagExclusiveDrive];
                [rsm sendCommand];
                [rsm release];
                RKRunMacroCommand *rkm = [[RKRunMacroCommand alloc] initWithId:2];
                [rkm sendCommand];
                [rkm release];
                app.interface.shouldStop = YES;
            }
            break;
        }
        default:
            break;
    }
    _state = newState;
}

- (void)didGetResponse {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *result = app.interface.lastResponse;
    NSArray *gameData = [[[result valueForKey:@"root"] valueForKey:@"headSetList"] valueForKey:@"headSetItem"];
    //NSLog(@"gameData %@", gameData);
    NSString *bestPlayerID = nil;
    int bestScore = 0;
    NSString *status = [[result valueForKey:@"root"] stringOrNilForKey:@"state"];
    if ([status isEqualToString:@"started"]) {
        for (NSDictionary *player in gameData) {
            int score = [[player stringOrNilForKey:@"meditation"] intValue];
            if (score > bestScore) {
                bestScore = score;
                bestPlayerID = [player stringOrNilForKey:@"unique_ID"];
                NSString *colorName = [player stringOrNilForKey:@"color"];
                UIColor *col = [UIColor 
                                performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@Color", colorName])];
                const CGFloat *comps = CGColorGetComponents(col.CGColor);
                _red = comps[0];
                _green = comps[1];
                _blue = comps[2];
            }
        }
        self.state = PLAYING;
    } else if ([status isEqualToString:@"done"]) {
        NSString *winner = [[result valueForKey:@"root"] stringOrNilForKey:@"winner"];
        for (NSDictionary *player in gameData) {
            NSString *playerId = [player stringOrNilForKey:@"unique_ID"];
            if (![playerId isEqualToString:winner]) continue;
            macro = [player stringOrNilForKey:@"spheroMacro"];
            break;
        }
        self.state = FINISHED;
    }
}

@end
