//
//  AppDelegate.h
//  Plum
//
//  Created by tpk on 14-11-6.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RootWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property(strong,nonatomic)RootWindowController* root;

@end
