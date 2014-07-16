//
//  AppDelegate.m
//  CSF
//
//  Created by Seamus McGowan on 3/14/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "AppDelegate.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "GAI.h"
#import "FBTweakShakeWindow.h"
#import "ThemeManager.h"
#import "UIColor+Extended.h"
#import "UIImageView+Extended.h"

@implementation AppDelegate

- (UIWindow *)window {
    if (!_window) {
#ifdef DEBUG
        self.window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
#else
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        #endif
    }

    _window.backgroundColor = [[ThemeManager sharedInstance] tintColor];

    return _window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar appearance].tintColor = [ThemeManager sharedInstance].normalFontColor;

    [self configureNavigationBar];
    [self configureWindowBackgroundImage];
    [self configureDDLog];
    [self configureGoogleAnalytics];

    return YES;
}

- (void)configureNavigationBar {
    NSDictionary *textAttributes = @{NSFontAttributeName : [ThemeManager sharedInstance].normalFont};
    [UINavigationBar appearance].titleTextAttributes = textAttributes;
    [UINavigationBar appearance].barStyle            = UIBarStyleBlack;

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    shadow.shadowColor  = [UIColor clearColor];

    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
                      setTitleTextAttributes:@{NSForegroundColorAttributeName : [ThemeManager sharedInstance].normalFontColor,
                                               NSShadowAttributeName          : shadow,
                                               NSFontAttributeName            : [ThemeManager sharedInstance].normalFont
                      }
                                    forState:UIControlStateNormal];
}

- (void)configureDDLog {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
}

- (void)configureGoogleAnalytics {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].logger.logLevel         = kGAILogLevelNone;
    [GAI sharedInstance].dispatchInterval        = 120;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-52609602-1"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)configureWindowBackgroundImage {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"farm"]];
    [imageView tintWithColor:[ThemeManager sharedInstance].imageTintColor];
    imageView.frame = self.window.bounds;
    [self.window addSubview:imageView];
}

@end
