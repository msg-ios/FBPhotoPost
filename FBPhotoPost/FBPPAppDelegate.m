//
//  FBPPAppDelegate.m
//  FBPhotoPost
//
//  Created by Marco S. Graciano on 1/14/13.
//  Copyright (c) 2013 MSG. All rights reserved.
//

#import "FBPPAppDelegate.h"

#import "FBPPViewController.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation FBPPAppDelegate

// If we have a valid session at the time of openURL call, we handle Facebook transitions by passing the url argument to handleOpenURL
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // BUG:
    // Nib files require the type to have been loaded before they can do the
    // wireup successfully.
    // http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
    [FBProfilePictureView class];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[FBPPViewController alloc] initWithNibName:@"FBPPViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application	{
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}

@end
