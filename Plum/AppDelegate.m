//
//  AppDelegate.m
//  Plum
//
//  Created by tpk on 14-11-6.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation AppDelegate

@synthesize root;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    if (AXIsProcessTrustedWithOptions != NULL) {
//        // 10.9 and later
//        NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
//        BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
//        if (accessibilityEnabled) {
//            NSString *bundleid = [[NSBundle mainBundle] bundleIdentifier];
//            NSString *insert = [NSString stringWithFormat:@"INSERT or REPLACE INTO access  VALUES('kTCCServiceAccessibility','%@',0,0,0,NULL);", bundleid];
//            char *p = (char *)[insert cStringUsingEncoding:NSUTF8StringEncoding];
//            char *command= "/usr/bin/sqlite3";
//            char *args[] = {"/Library/Application Support/com.apple.TCC/TCC.db", p, nil};
//            AuthorizationRef authRef;
//            OSStatus status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
//            if (status == errAuthorizationSuccess) {
//                status = AuthorizationExecuteWithPrivileges(authRef, command, kAuthorizationFlagDefaults, args, NULL);
//                AuthorizationFree(authRef, kAuthorizationFlagDestroyRights);
//                if(status != 0){
//                    //handle errors...
//                }
//            }
//        }
//    } else {
//        // 10.8 and older
//    }
    
    root = [[RootWindowController alloc]initWithWindowNibName:@"RootWindowController"];
    [self.window setWindowController:root];
    [self.window makeKeyWindow];
    [self.window setContentSize:NSMakeSize(root.window.frame.size.width, root.window.frame.size.height)];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (BOOL)checkAppDuplicateAndBringToFrontWithBundle:(NSBundle *)bundle {
    NSRunningApplication *app;
    NSArray *appArray;
    NSUInteger tmp;
    pid_t selfPid;
    BOOL ret = NO;
    
    selfPid = [[NSRunningApplication currentApplication] processIdentifier];
    appArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:[bundle bundleIdentifier]];
    
    for (tmp = 0; tmp < [appArray count]; tmp++) {
        app = [appArray objectAtIndex:tmp];
        
        if ([app processIdentifier] == selfPid) {
            /* do nothing */
        } else  {
            [[NSWorkspace sharedWorkspace] launchApplication:[[app bundleURL] path]];
            ret = YES;
        }
    }
    
    return ret;
}

@end
