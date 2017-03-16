//
//  SettingWindowController.m
//  Plum
//
//  Created by tpk on 14-11-7.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "SettingWindowController.h"
#import "ICObject.h"
#import "NSViewExt.h"
#import "NSWindowExt.h"
#import "ICView.h"

@interface SettingWindowController ()

@end

@implementation SettingWindowController

#define WIDTHINTERVAL   5
#define HEIGHTINTERVAL  5

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePinObject:) name:@"updatePinObject" object:nil];
        isFirstIn = YES;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    pinScrollView = [[NSScrollView alloc]initWithFrame:NSMakeRect((textPinRow.isHidden?13:textPinRow.right+10), 0, self.window.width-(textPinRow.isHidden?26:textPinRow.right-23), textICPin.bottom-40)];
    pinScrollView.top = textICPin.bottom-20;
    [pinScrollView setHasVerticalScroller:YES];
    [self.window.contentView addSubview:pinScrollView];
    
    NSClipView* pinClipView = [[NSClipView alloc]initWithFrame:NSMakeRect(0, 0, pinScrollView.width, pinScrollView.height)];
    [pinScrollView addSubview:pinClipView];
    [pinScrollView setContentView:pinClipView];
    
    pinView = [[NSView alloc]initWithFrame:NSMakeRect(0, 0, pinScrollView.width-10, pinScrollView.height)];
    [pinScrollView addSubview:pinView];
    [pinScrollView setDocumentView:pinView];
    
    m_PinArray = [NSMutableArray new];
    m_PinViews = [NSMutableArray new];
    
    NSUserDefaults* userInfo = [NSUserDefaults standardUserDefaults];
    
    if ([userInfo objectForKey:@"productName"]) {
        textProductName.stringValue = [userInfo objectForKey:@"productName"];
    }
    if ([userInfo objectForKey:@"row"]) {
        textRow.stringValue = [userInfo objectForKey:@"row"];
    }
    if ([userInfo objectForKey:@"column"]) {
        textColumn.stringValue = [userInfo objectForKey:@"column"];
    }
    if ([userInfo objectForKey:@"upperLimit"]) {
        textUpperLimit.stringValue = [userInfo objectForKey:@"upperLimit"];
    }
    if ([userInfo objectForKey:@"lowerLimit"]) {
        textLowerLimit.stringValue = [userInfo objectForKey:@"lowerLimit"];
    }
    if ([userInfo objectForKey:@"textICPin"]) {
        textICPin.stringValue = [userInfo objectForKey:@"textICPin"];
    }
    if ([userInfo objectForKey:@"pinArray"]) {
        if (m_PinArray) {
            [m_PinArray removeAllObjects];
        } else {
            m_PinArray = [NSMutableArray new];
        }
        NSArray* array = [userInfo objectForKey:@"pinArray"];
        for (NSArray* oneArray in array) {
            NSMutableArray* inArray = [NSMutableArray new];
            for (NSDictionary* dic in oneArray) {
                [inArray addObject:dic];
            }
            [m_PinArray addObject:inArray];
        }
        [self setupPinView:m_PinArray];
    }
    
    [textPinCheck setCanEdit:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)clickOK:(id)sender {
    if (textProductName.stringValue.length==0
        ||textRow.stringValue.length==0
        ||textColumn.stringValue.length==0
        ||textUpperLimit.stringValue.length==0
        ||textLowerLimit.stringValue.length==0
        ||textICPin.stringValue.length==0
        ||m_PinArray.count==0) {
        NSRunAlertPanel(@"Error", @"Setting can not be nil!", @"OK", nil, nil);
        return ;
    }
    ICObject* obj = [[ICObject alloc]init];
    obj.productName = textProductName.stringValue;
    obj.row = [textRow.stringValue intValue];
    obj.column = [textColumn.stringValue intValue];
    obj.upperLimit = [textUpperLimit.stringValue intValue];
    obj.lowerLimit = [textLowerLimit.stringValue intValue];
    obj.arrayICPin = m_PinArray;
    obj.strICPin = textICPin.stringValue;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateView" object:obj];
    NSUserDefaults* userInfo = [NSUserDefaults standardUserDefaults];
    [userInfo setObject:obj.productName forKey:@"productName"];
    [userInfo setObject:@(obj.row) forKey:@"row"];
    [userInfo setObject:@(obj.column) forKey:@"column"];
    [userInfo setObject:@(obj.upperLimit) forKey:@"upperLimit"];
    [userInfo setObject:@(obj.lowerLimit) forKey:@"lowerLimit"];
    [userInfo setObject:obj.strICPin forKey:@"textICPin"];
    [userInfo setObject:obj.arrayICPin forKey:@"pinArray"];
    [userInfo synchronize];
    [NSApp stopModal];
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

- (IBAction)clickCancel:(id)sender {
    [NSApp stopModal];
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

- (IBAction)clickSave:(id)sender {
    NSSavePanel*    panel = [NSSavePanel savePanel];
//    NSView *viewExt = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 180, 40)];
//    NSTextField *labExt = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 10, 80, 20)];
//    [labExt setBordered:NO];
//    [labExt setDrawsBackground:NO];
//    labExt.stringValue = @"Image type: ";
//    NSComboBox *cbExt = [[NSComboBox alloc] initWithFrame:NSMakeRect(80, 8, 100, 25)];
//    [cbExt addItemsWithObjectValues:@[@".bmp", @".jpg", @".png", @".tif"]];
//    [viewExt addSubview:labExt];
//    [viewExt addSubview:cbExt];
//    [panel setAccessoryView:viewExt];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode) {
        if (returnCode==1) {
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            [dic setObject:textProductName.stringValue forKey:@"productName"];
            [dic setObject:textRow.stringValue forKey:@"row"];
            [dic setObject:textColumn.stringValue forKey:@"column"];
            [dic setObject:textUpperLimit.stringValue forKey:@"upperLimit"];
            [dic setObject:textLowerLimit.stringValue forKey:@"lowerLimit"];
            [dic setObject:textICPin.stringValue forKey:@"textICPin"];
            [dic setObject:m_PinArray forKey:@"pinArray"];
            [dic setObject:textPinRow.stringValue forKey:@"pinRow"];
            [dic setObject:textPinColumn.stringValue forKey:@"pinColumn"];
            [dic writeToFile:panel.URL.path atomically:YES];
        }
    }];
}

- (IBAction)clickLoad:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO]; //可以打开目录
	[openPanel setCanChooseFiles:YES]; //不能打开文件(我需要处理一个目录内的所有文件)
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger returnCode){
        if (returnCode==1) {
            NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:openPanel.URL.path];
            if ([dic objectForKey:@"productName"]) {
                textProductName.stringValue = [dic objectForKey:@"productName"];
            }
            if ([dic objectForKey:@"row"]) {
                textRow.stringValue = [dic objectForKey:@"row"];
            }
            if ([dic objectForKey:@"column"]) {
                textColumn.stringValue = [dic objectForKey:@"column"];
            }
            if ([dic objectForKey:@"upperLimit"]) {
                textUpperLimit.stringValue = [dic objectForKey:@"upperLimit"];
            }
            if ([dic objectForKey:@"lowerLimit"]) {
                textLowerLimit.stringValue = [dic objectForKey:@"lowerLimit"];
            }
            if ([dic objectForKey:@"textICPin"]) {
                textICPin.stringValue = [dic objectForKey:@"textICPin"];
            }
            if ([dic objectForKey:@"pinRow"]) {
                textPinRow.stringValue = [dic objectForKey:@"textICPin"];
            }
            if ([dic objectForKey:@"pinColumn"]) {
                textPinColumn.stringValue = [dic objectForKey:@"textICPin"];
            }
            if ([dic objectForKey:@"pinArray"]) {
                if (m_PinArray) {
                    [m_PinArray removeAllObjects];
                } else {
                    m_PinArray = [NSMutableArray new];
                }
                NSArray* array = [dic objectForKey:@"pinArray"];
                for (NSArray* oneArray in array) {
                    NSMutableArray* inArray = [NSMutableArray new];
                    for (NSDictionary* dic in oneArray) {
                        [inArray addObject:dic];
                    }
                    [m_PinArray addObject:inArray];
                }
                [self setupPinView:m_PinArray];
            }
        }
    }];
}

- (IBAction)clickCheck:(id)sender {
    if (textICPin.stringValue.length==0
        ||textUpperLimit.stringValue.length==0
        ||textLowerLimit.stringValue.length==0
        /*||textPinRow.stringValue.length==0
        ||textPinColumn.stringValue.length==0*/) {
        return ;
    }
    NSMutableArray* array = [ICObject changeToDataArray:textICPin.stringValue];
    [m_PinArray removeAllObjects];
    for (int i=0; i<array.count; i++) {
        NSArray* oneArray = [array objectAtIndex:i];
        NSMutableArray* myArray = [NSMutableArray new];
        for (int j=0; j<oneArray.count; j++) {
            int pin = [[oneArray objectAtIndex:j]intValue];
            NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:@(i+1),@"ic",@(pin),@"pin",@([textUpperLimit.stringValue intValue]),@"upperLimit",@([textLowerLimit.stringValue intValue]),@"lowerLimit", nil];
            [myArray addObject:d];
        }
        [m_PinArray addObject:myArray];
    }
    [self setupPinView:m_PinArray];
}

- (void)setupPinView:(NSMutableArray*)arrayPin {
    int width = (pinView.width-6*5)/5;
    int count = 0;
    for (NSArray* arr in arrayPin) {
        for (int i=0; i<arr.count; i++) {
            count++;
        }
    }
    [pinView removeAllSubviews];
    [m_PinViews removeAllObjects];
    [pinView setFrame:NSMakeRect(0, 0, pinView.width, (10+(count%5==0?count/5:count/5+1)*(width+5))>=pinScrollView.height?(10+(count%5==0?count/5:count/5+1)*(width+5)):pinScrollView.height)];
    count = 0;
    for (NSArray* oneArray in arrayPin) {
        for (int i=0; i<oneArray.count; i++) {
            NSDictionary* dic = [oneArray objectAtIndex:i];
            PinView* view = [[PinView alloc]initWithFrame:NSMakeRect(5, 5, width, width)];
            view.left = 5+(5+width)*(count%5);
            view.top = pinView.height-5-(5+width)*(count/5);
            int ic = [[dic objectForKey:@"ic"]intValue];
            int pin = [[dic objectForKey:@"pin"]intValue];
            int upperLimit = [[dic objectForKey:@"upperLimit"]intValue];
            int lowerLimit = [[dic objectForKey:@"lowerLimit"]intValue];
            [view setTitle:[NSString stringWithFormat:@"PIN %d",pin]];
            [view setToolTip:[NSString stringWithFormat:@"IC               : %d\nPIN             : %d\nUpperLimit : %d\nLowerLimit : %d",ic,pin,upperLimit,lowerLimit]];
            PINObject* obj = [[PINObject alloc]init];
            obj.ic = ic;
            obj.pin = pin;
            obj.upperLimit = upperLimit;
            obj.lowerLimit = lowerLimit;
            view.delegate = self;
            [view setPinObject:obj];
            [pinView addSubview:view];
            [m_PinViews addObject:view];
            count++;
        }
    }
}

- (void)doubleClickPinView:(NSEvent *)event from:(id)sender {
    PinView* oneView = (PinView*)sender;
    pinSetting = [[PinSetWindowController alloc]initWithPinObject:[oneView getPinObject]];
    [pinSetting showWindow:self];
    pinSetting.window.alphaValue = 0.0f;
    
    NSRect firstFrame = NSMakeRect(self.window.left+self.window.width/2, self.window.frame.origin.y+self.window.height/2, 0, 0);
    //属性字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //设置目标对象
    [dict setObject:pinSetting.window forKey:NSViewAnimationTargetKey];
    //设置其实大小
    [dict setObject:[NSValue valueWithRect:firstFrame] forKey:NSViewAnimationStartFrameKey];
    firstFrame = NSMakeRect(self.window.left+(self.window.width-pinSetting.window.width)/2, self.window.frame.origin.y+(self.window.height-pinSetting.window.height)/2, pinSetting.window.width, pinSetting.window.height);
    //设置最终大小
    [dict setObject:[NSValue valueWithRect:firstFrame] forKey:NSViewAnimationEndFrameKey];
    //设置动画效果
    [dict setObject:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
    //设置动画
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
    [animation setDuration:0.25f];
    //启动动画
    [animation startAnimation];
}

- (void)updatePinObject:(NSNotification*)sender {
    PINObject* obj = (PINObject*)sender.object;
    BOOL isFind = NO;
    for (NSMutableArray* array in m_PinArray) {
        int index = 0;
        for (NSDictionary* dic in array) {
            if ([[dic objectForKey:@"ic"]intValue]==obj.ic
                &&[[dic objectForKey:@"pin"]intValue]==obj.pin) {
                NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:@(obj.ic),@"ic",@(obj.pin),@"pin",@(obj.upperLimit),@"upperLimit",@(obj.lowerLimit),@"lowerLimit", nil];
                [array replaceObjectAtIndex:index withObject:d];
                isFind = YES;
                for (PinView* view in m_PinViews) {
                    PINObject* thisObj = [view getPinObject];
                    if (thisObj.ic == obj.ic && thisObj.pin == obj.pin) {
                        thisObj.upperLimit = obj.upperLimit;
                        thisObj.lowerLimit = obj.lowerLimit;
                        [view setToolTip:[NSString stringWithFormat:@"IC               : %d\nPIN             : %d\nUpperLimit : %d\nLowerLimit : %d",thisObj.ic,thisObj.pin,thisObj.upperLimit,thisObj.lowerLimit]];
                        break;
                    }
                }
                break;
            }
            index++;
        }
        if (isFind) {
            break;
        }
    }
}

@end
