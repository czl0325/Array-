//
//  SettingWindowController.h
//  Plum
//
//  Created by tpk on 14-11-7.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyTextView.h"
#import "PinView.h"
#import "PinSetWindowController.h"

@interface SettingWindowController : NSWindowController
<NSOpenSavePanelDelegate,NSWindowDelegate,
PinViewDelegate,NSAnimationDelegate>{
    IBOutlet NSTextField* textProductName;
    IBOutlet NSTextField* textRow;
    IBOutlet NSTextField* textColumn;
    IBOutlet NSTextField* textUpperLimit;
    IBOutlet NSTextField* textLowerLimit;
    IBOutlet NSTextField* textICPin;
    IBOutlet MyTextView* textPinCheck;
    IBOutlet NSTextField* textPinRow;
    IBOutlet NSTextField* textPinColumn;
    NSScrollView* pinScrollView;
    NSView* pinView;
    PinSetWindowController* pinSetting;
    NSMutableArray* m_PinArray;
    NSMutableArray* m_PinViews;
    BOOL isFirstIn;
}

@end
