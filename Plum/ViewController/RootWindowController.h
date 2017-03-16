//
//  RootWindowController.h
//  Plum
//
//  Created by tpk on 14-11-6.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ICView.h"
#import "UsbHID.h"
#import "ICObject.h"
#import "MyTextView.h"
#import "INAppStoreWindow.h"
#import "SettingWindowController.h"
#import "ChartWindowController.h"
#import "PasswordWindowController.h"

#define TEXTCOLOR [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1.0]
#define TEXTFAILCOLOR      [NSColor redColor]
#define TEXTPASSCOLOR   [NSColor blackColor]
#define PASSCOLOR  [NSColor colorWithCalibratedRed:0.0 green:100.0/255.0 blue:0.0 alpha:1.0]

#define BYTETOWORD(b1,b2) ((b1<<8)|b2)
#define BYTETOBCD(bcd) (bcd&15)+((bcd>>4)*10)

@interface RootWindowController : NSWindowController
<UsbHIDDelegate,ICViewDelegate>{
    UsbHID* usbHid;
    BOOL isRunning;
    SettingWindowController* settingWindow;
    ChartWindowController* chartWindow;
    PasswordWindowController* passWindowController;
    ICObject* testICObject;
    NSMutableArray* arrayRow;
    NSInteger m_nTestRow;
    NSInteger m_nTestColumn;
    NSMutableArray* arrayOneTestPin;
    NSMutableArray* arrayICView;
    NSMutableArray* arrayInitialData;
    BOOL isClearAll;
    int testCount;
    BOOL isInitial;
    NSString* logPath;
    NSString* plistPath;
    BOOL isWaitData;
    NSDate* dateForStartWait;
    NSString* masterVersion;
    NSString* slaveVersion;
    
    IBOutlet NSView* viewICarray;
    IBOutlet NSButton* btStart;
    IBOutlet NSButton* btClear;
    IBOutlet NSButton* btInitial;
    IBOutlet NSButton* btOnePic;
    IBOutlet NSImageView* imageUSBState;
    IBOutlet NSTextField* textProductName;
    IBOutlet NSTextField* textICPIN;
    IBOutlet NSTextField* textUpperLimit;
    IBOutlet NSTextField* textLowerLimit;
    IBOutlet NSTextField* textBarCode;
    IBOutlet NSPopUpButton* popupButton;
    IBOutlet NSTextField* textPassOrFail;
    IBOutlet NSTextField* textPassNum;
    IBOutlet NSTextField* textFailNum;
    IBOutlet NSTextField* textAllNum;
    IBOutlet NSTextField* textPercentage;
    IBOutlet MyTextView* textViewResult;
    IBOutlet MyTextView* textViewTemp;
}

@end
