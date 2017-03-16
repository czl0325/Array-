//
//  RootWindowController.m
//  Plum
//
//  Created by tpk on 14-11-6.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "RootWindowController.h"
#import "NSViewExt.h"
#import "NSWindowExt.h"
#import "CSVObject.h"
#import "NSDate-Utilities.h"
#import "NSTools.h"

@interface RootWindowController ()

@end

@implementation RootWindowController

#define WIDTHINTERVAL   5
#define HEIGHTINTERVAL  5

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:@"updateView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoSettingView:) name:@"gotoSettingView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ICViewTestAgain:) name:@"ICViewTestAgain" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTextViewResult:) name:@"updateTextViewResult" object:nil];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    masterVersion = @"";
    slaveVersion = @"";
    
    usbHid = [[UsbHID alloc]init];
    usbHid.delegate = self;
    
    testICObject = nil;
    arrayRow = [NSMutableArray new];
    arrayOneTestPin = [NSMutableArray new];
    arrayICView = [NSMutableArray new];
    //arrayInitialData = [NSMutableArray new];
    m_nTestRow = 0;
    m_nTestColumn = 0;
    testCount = 0;
    isInitial = NO;
    [textViewResult setCanEdit:YES];
    
    NSUserDefaults* userInfo = [NSUserDefaults standardUserDefaults];
    
    if ([userInfo objectForKey:@"productName"]) {
        textProductName.stringValue = [userInfo objectForKey:@"productName"];
        if (!testICObject) {
            testICObject = [[ICObject alloc]init];
        }
        testICObject.productName = textProductName.stringValue;
    }
    if ([userInfo objectForKey:@"upperLimit"]) {
        textUpperLimit.stringValue = [userInfo objectForKey:@"upperLimit"];
        testICObject.upperLimit = [[userInfo objectForKey:@"upperLimit"]intValue];
    }
    if ([userInfo objectForKey:@"lowerLimit"]) {
        textLowerLimit.stringValue = [userInfo objectForKey:@"lowerLimit"];
        testICObject.lowerLimit = [[userInfo objectForKey:@"lowerLimit"]intValue];
    }
    if ([userInfo objectForKey:@"row"]&&[userInfo objectForKey:@"column"]) {
        for (int i=0; i<[[userInfo objectForKey:@"row"]intValue]; i++) {
            [arrayRow addObject:[NSString stringWithFormat:@"row %d",i+1]];
        }
        testICObject.row = [[userInfo objectForKey:@"row"]intValue];
        testICObject.column = [[userInfo objectForKey:@"column"]intValue];
        if ([userInfo objectForKey:@"textICPin"]) {
            textICPIN.stringValue = [userInfo objectForKey:@"textICPin"];
        }
        if ([userInfo objectForKey:@"pinArray"]) {
            testICObject.arrayICPin = [userInfo objectForKey:@"pinArray"];
        }
        [self setupICView:[[userInfo objectForKey:@"column"] intValue] withRow:[[userInfo objectForKey:@"row"] intValue]];
    }
    if (arrayICView.count > 1) {
        [btOnePic.cell setState:0];
        [btClear setEnabled:YES];
    } else {
        [btOnePic.cell setState:1];
        [btClear setEnabled:NO];
    }
    
    isRunning = NO;
    isClearAll = YES;
    
    imageUSBState.image = [NSImage imageNamed:@"Disconnect.png"];
    [imageUSBState setToolTip:@"Usb Error"];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    //设置阴影为白色
    [shadow setShadowColor:[NSColor blueColor]];
    //设置阴影为右下方
    [shadow setShadowOffset:NSMakeSize(20, 20)];
    //这一步不可少，设置NSView的任何与Layer有关的效果都需要
    [textBarCode setWantsLayer:YES];
    //最后一步，完成
    [textBarCode setShadow:shadow];
    
    plistPath = [[NSBundle mainBundle] bundlePath];
    plistPath = [plistPath stringByAppendingPathComponent:@"Contents"];
    plistPath = [plistPath stringByAppendingPathComponent:@"Resources"];
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath: plistPath error:nil];
    NSMutableArray* arrayplist = [NSMutableArray new];
    for (NSString* str in files) {
        if ([str hasSuffix:@".plist"]) {
            [arrayplist addObject:str];
        }
    }
    [popupButton removeAllItems];
    [popupButton addItemsWithTitles:arrayplist];
    
    isWaitData = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        while (true) {
            sleep(1);
            if (isWaitData) {
                if ([[NSDate date] timeIntervalSinceDate:dateForStartWait]>5) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //回调或者说是通知主线程刷新，
                        isWaitData = NO;
                        if (arrayICView.count>1) {
                            [btStart setEnabled:NO];
                        } else {
                            [btStart setEnabled:YES];
                        }
                        if (!isInitial) {
                            [btInitial setEnabled:YES];
                            [arrayInitialData removeAllObjects];
                        }
                        [self shakeWindow];
                    });
                }
            }
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupICView:(int)ICCount withRow:(int)ICRow {
    [viewICarray removeAllSubviews];
    [arrayICView removeAllObjects];
    
    [arrayRow removeAllObjects];
    for (int i=0; i<ICRow; i++) {
        [arrayRow addObject:[NSString stringWithFormat:@"row %d",i+1]];
    }
    
    m_nTestRow = 0;
    m_nTestColumn = 0;
    
    int width = (viewICarray.width-(ICCount+1)*WIDTHINTERVAL)/ICCount;
    int height = (viewICarray.height-(ICRow+1)*HEIGHTINTERVAL)/ICRow;
    int tag = 0;
    for (int i=0; i<ICRow; i++) {
        for (int j=0; j<ICCount; j++) {
            ICView* b = [[ICView alloc]initWithFrame:NSMakeRect(0, 0, width, height)];
            b.left = WIDTHINTERVAL+(WIDTHINTERVAL+width)*(j%ICCount);
            b.top = viewICarray.height-HEIGHTINTERVAL-(HEIGHTINTERVAL+height)*i;
            [b setTitle:[NSString stringWithFormat:@"%@%d",[self numberToChar:(NSInteger)j+1],i+1]];
            b.column = j;
            b.row = i;
            b.tag = tag;
            tag++;
            b.delegate = self;
            b.arrayTestPin = testICObject.arrayICPin;
            [viewICarray addSubview:b];
            [arrayICView addObject:b];
        }
    }
    if (arrayICView.count>1) {
        [btClear setEnabled:YES];
        [btStart setEnabled:NO];
    } else {
        [btClear setEnabled:NO];
        [btStart setEnabled:YES];
    }
}

- (IBAction)clickInitial:(id)sender {
    isInitial = NO;
    isRunning = YES;
    testCount = 0;
    
    [arrayOneTestPin removeAllObjects];
    [arrayInitialData removeAllObjects];
    arrayInitialData = nil;
    textViewResult.string = @"";
    dateForStartWait = [NSDate date];
    isWaitData = YES;
    [btInitial setEnabled:NO];
    
    char outbuff[4];
    memset(outbuff, 0x00, sizeof(outbuff));
    outbuff[0]=0x01;
    outbuff[1]=0x04;
    outbuff[2]=0x01;
    outbuff[3]=testCount+1;
    [usbHid senddata:outbuff];
}

- (IBAction)clickSetting:(id)sender {
    if (passWindowController) {
        [passWindowController close];
        passWindowController = nil;
    }
    passWindowController = [[PasswordWindowController alloc]initWithWindowNibName:@"PasswordWindowController"];
    [passWindowController showWindow:self];
    passWindowController.window.alphaValue = 0.0f;
    
    NSRect firstFrame = NSMakeRect(self.window.left+self.window.width/2, self.window.frame.origin.y+self.window.height/2, 0, 0);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:passWindowController.window forKey:NSViewAnimationTargetKey];
    [dict setObject:[NSValue valueWithRect:firstFrame] forKey:NSViewAnimationStartFrameKey];
    firstFrame = NSMakeRect(self.window.left+(self.window.width-passWindowController.window.width)/2, self.window.frame.origin.y+(self.window.height-passWindowController.window.height)/2, passWindowController.window.width, passWindowController.window.height);
    [dict setObject:[NSValue valueWithRect:firstFrame] forKey:NSViewAnimationEndFrameKey];
    [dict setObject:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
    [animation setDuration:0.25f];
    [animation startAnimation];
}

- (IBAction)clickOnePic:(id)sender {
    if ([btOnePic.cell state]==1) {
        [btClear setEnabled:NO];
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"multichip"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [btClear setEnabled:YES];
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"multichip"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)clickStart:(id)sender {
    if (textBarCode.stringValue.length==0) {
        NSRunAlertPanel(@"Error", @"Barcode is empty!", @"OK", nil, nil);
        return ;
    }
    if (!isInitial) {
        NSRunAlertPanel(@"Error", @"Please Get Initial Number!", @"OK", nil, nil);
        return ;
    }
    if (!arrayICView || arrayICView.count==0) {
        NSRunAlertPanel(@"Error", @"Please Setting!", @"OK", nil, nil);
        return ;
    }
    if (isClearAll || arrayICView.count == 1) {
        [self createResult];
        isClearAll = NO;
    }
    
    isRunning = YES;
    [btStart setEnabled:NO];
    
    m_nTestRow = 0;
    m_nTestColumn = 0;
    testCount = 0;
    dateForStartWait = [NSDate date];
    isWaitData = YES;
    char outbuff[4];
    memset(outbuff, 0x00, sizeof(outbuff));
    outbuff[0]=0x01;
    outbuff[1]=0x04;
    outbuff[2]=0x01;
    outbuff[3]=testCount+1;
    [usbHid senddata:outbuff];
    
    [arrayOneTestPin removeAllObjects];
    NSString* textstring = [NSString stringWithFormat:@"************************************************************\n* Plum Test V2.0\n* Master Firmware Version: V%@\n* Slaver Firmware Version: V%@\n* %@\n* SN : %@\n* Format : (PIN : TestValue(LowerLimit-UpperLimit))\n************************************************************\n",masterVersion,slaveVersion,formatDateToStringALL([NSDate date]),textBarCode.stringValue];
    NSMutableAttributedString* mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
    [mstring addAttribute:NSForegroundColorAttributeName value:TEXTCOLOR range:NSMakeRange(0,[mstring length])];
    [textViewResult insertText:mstring];
}

- (IBAction)clickClear:(id)sender {
    isClearAll=YES;
    textBarCode.stringValue=@"";
    m_nTestRow=0;
    m_nTestColumn=0;
    testCount=0;
    for (ICView* v in arrayICView) {
        [v setTitle:[NSString stringWithFormat:@"%@%d",[self numberToChar:(NSInteger)v.column+1],v.row+1]];
        [v setFontColor:[NSColor blackColor]];
        v.arrayData = nil;
        v.arrayTestPin = nil;
        v.arrayAllSort = nil;
    }
    textViewResult.string = @"";
}

- (IBAction)clickStop:(id)sender {
    if (arrayICView.count>1) {
        [btStart setEnabled:NO];
    } else {
        [btStart setEnabled:YES];
    }
}

#pragma mark 刷新页面的通知
- (void)updateView:(NSNotification*)sender {
    ICObject* obj = (ICObject*)sender.object;
    [arrayICView removeAllObjects];
    [arrayInitialData removeAllObjects];
    arrayInitialData = nil;
    isInitial = NO;
    isClearAll = YES;
    [btInitial setTitle:@"Initial"];
    [btInitial setEnabled:YES];
    textPassNum.stringValue = @"0";
    textFailNum.stringValue = @"0";
    textAllNum.stringValue = @"0";
    textPercentage.stringValue = @"0.00%";
    textBarCode.stringValue = @"";
    textViewResult.string = @"";
    textPassOrFail.stringValue = @"Null";
    testICObject = obj;
    textProductName.stringValue = obj.productName;
    textICPIN.stringValue = obj.strICPin;
    textUpperLimit.stringValue = [NSString stringWithFormat:@"%d",obj.upperLimit];
    textLowerLimit.stringValue = [NSString stringWithFormat:@"%d",obj.lowerLimit];
    [self setupICView:obj.column withRow:obj.row];
}

#pragma mark 进入设置页面的通知
- (void)gotoSettingView:(NSNotification*)sender {
    settingWindow = [[SettingWindowController alloc]initWithWindowNibName:@"SettingWindowController"];
    [NSApp beginSheet:settingWindow.window modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

#pragma mark 重新再测试一次的通知
- (void)ICViewTestAgain:(NSNotification*)sender {
    ICView* b = (ICView*)sender.object;
    if (b.arrayAllSort) {
        b.arrayAllSort = nil;
    }
    [self clickICView:nil from:b];
}

#pragma mark 更新NSTextview的通知
- (void)updateTextViewResult:(NSNotification*)sender {
    ICView* b = (ICView*)sender.object;
    NSMutableAttributedString* attString = textViewResult.textStorage;
    NSString* str = attString.string;
    while (1) {
        NSRange range1 = [str rangeOfString:[NSString stringWithFormat:@"%@%d:",[self numberToChar:b.column+1],b.row+1] options:NSBackwardsSearch];
        if (range1.length<=0) {
            break;
        }
        NSUInteger start = range1.location;
        NSRange range2 = [str rangeOfString:[NSString stringWithFormat:@"end%@%d",[self numberToChar:b.column+1],b.row+1] options:NSBackwardsSearch];
        if (range2.length<=0) {
            break;
        }
        NSUInteger end = range2.location+range2.length+2;
        [attString deleteCharactersInRange:NSMakeRange(start, end-start)];
        break;
    }
    if (textViewResult.textStorage.length>0) {
        NSData* data2 = [textViewTemp.textStorage dataFromRange:NSMakeRange(0, textViewTemp.textStorage.length) documentAttributes:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} error:nil];
        [data2 writeToFile:logPath atomically:YES];
    }
    
    NSString* csvString = [NSString stringWithContentsOfFile:[[CSVObject sharedManager] getCSVFileName] encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray* array = [NSMutableArray arrayWithArray:[csvString componentsSeparatedByString:@"\n"]];
    for (NSUInteger i=array.count-1; i!=0; i--) {
        NSString* one = [array objectAtIndex:i];
        NSRange range = [one rangeOfString:[NSString stringWithFormat:@"%@%d,",[self numberToChar:b.column+1],b.row+1]];
        if (range.length > 0) {
            [array removeObject:one];
            break;
        }
    }
    csvString = @"";
    for (NSString* one in array) {
        csvString = [csvString stringByAppendingString:one];
        csvString = [csvString stringByAppendingString:@"\n"];
    }
    [csvString writeToFile:[[CSVObject sharedManager]getCSVFileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    int nAll = [textAllNum.stringValue intValue];
    int nPass = [textPassNum.stringValue intValue];
    int nFail = [textFailNum.stringValue intValue];
    nAll-=1;
    textAllNum.stringValue = [NSString stringWithFormat:@"%d",nAll];
    if (b.isPass) {
        nPass-=1;
        textPassNum.stringValue = [NSString stringWithFormat:@"%d",nPass];
    } else {
        nFail-=1;
        textFailNum.stringValue = [NSString stringWithFormat:@"%d",nFail];
    }
    if (nAll==0) {
        textPercentage.stringValue = @"0.00%";
    } else {
        float percentage = nPass/(float)nAll;
        textPercentage.stringValue = [NSString stringWithFormat:@"%.2f%%",percentage*100];
    }
}

#pragma mark 点击IC模块
- (void)clickICView:(NSEvent *)event from:(id)sender {
    ICView* b = (ICView*)sender;
    if (b.arrayAllSort && b.arrayAllSort.count>0) {
        //chartWindow = [[ChartWindowController alloc]initWithX:b.arrayTestPin withY:b.arrayData withTitle:[NSString stringWithFormat:@"IC row %d column %d",b.row,b.column]];
        chartWindow = [[ChartWindowController alloc]initWithArray:b.arrayAllSort withTitle:[NSString stringWithFormat:@"IC row %d column %d",b.row,b.column]];
        [chartWindow showWindow:self];
        [chartWindow.window setFrame:NSMakeRect(self.window.left+(self.window.width-chartWindow.window.width)/2, self.window.frame.origin.y+(self.window.height-chartWindow.window.height)/2, chartWindow.window.width, chartWindow.window.height) display:YES];
    } else {
        if (textBarCode.stringValue.length==0) {
            NSRunAlertPanel(@"Error", @"Barcode is empty!", @"OK", nil, nil);
            return ;
        }
        if (!isInitial) {
            NSRunAlertPanel(@"Error", @"Please Get Initial Number!", @"OK", nil, nil);
            return ;
        }
        if (!arrayICView || arrayICView.count==0) {
            NSRunAlertPanel(@"Error", @"Please Setting!", @"OK", nil, nil);
            return ;
        }
        if (isClearAll || arrayICView.count==1) {
            [self createResult];
            isClearAll = NO;
        }
        
        [textViewResult setSelectedRange:NSMakeRange(textViewResult.textStorage.string.length, 0)];
        NSString* textstring = [NSString stringWithFormat:@"%@%d:\n************************************************************\n* Plum Test V1.0\n* %@\n* SN : %@\n* Format : (PIN : TestValue(LowerLimit-UpperLimit))\n************************************************************\n\n",[self numberToChar:b.column+1],b.row+1,formatDateToStringALL([NSDate date]),textBarCode.stringValue];
        NSMutableAttributedString* mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
        [mstring addAttribute:NSForegroundColorAttributeName value:TEXTCOLOR range:NSMakeRange(0,[mstring length])];
        [textViewResult insertText:mstring];
        
        m_nTestRow = b.row;
        m_nTestColumn = b.column;
        testCount=0;
        dateForStartWait = [NSDate date];
        isWaitData = YES;
        char outbuff[4];
        memset(outbuff, 0x00, sizeof(outbuff));
        outbuff[0]=0x01;
        outbuff[1]=0x04;
        outbuff[2]=0x01;
        outbuff[3]=testCount+1;
        [usbHid senddata:outbuff];
        [arrayOneTestPin removeAllObjects];
    }
}

- (void)createResult {
    //NSDate* date = [NSDate date];
    //[[CSVObject sharedManager] createCSV:[NSString stringWithFormat:@"%@_%@_%04ld%02ld%02ld%02ld%02ld%02ld.csv",textProductName.stringValue,textBarCode.stringValue,date.year,date.month,date.day,date.hour,date.minute,date.seconds] withFront:[NSString stringWithFormat:@"*****************************************\nPruduct Name : %@\nBarCode      : %@\nDateTime     : %04ld-%02ld-%02ld %02ld:%02ld:%02ld\n*****************************************\n",textProductName.stringValue,textBarCode.stringValue,date.year,date.month,date.day,date.hour,date.minute,date.seconds]];
    [[CSVObject sharedManager] createCSVOnly:[NSString stringWithFormat:@"%@(FW V%@).csv",textProductName.stringValue,masterVersion]];
    
    NSArray *downlaodPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *downlaodDir = [downlaodPaths objectAtIndex:0];
    NSString* path = [downlaodDir stringByAppendingPathComponent:@"plum"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:@"log"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    logPath = [NSString stringWithFormat:@"%@/%@_%@.rtf",path,textProductName.stringValue,textBarCode.stringValue];
    textViewResult.string = @"";
}

#pragma mark USB的代理
- (void)usbhidDidRecvData:(uint8_t*)recvData length:(CFIndex)reportLength {
#ifdef TEST
    NSLog(@"usb接收到数据:%02x,%02x,%02x,%02x",recvData[0],recvData[1],recvData[2],recvData[3]);
#endif
    dateForStartWait = [NSDate date];
    if (recvData[0]==0x34 && recvData[1]==0xb1) {
        masterVersion = [NSString stringWithFormat:@"%d.%d",recvData[3],recvData[4]];
        char buff2[2] = {0x01, 0xb2};
        [usbHid senddata:buff2];
    } else if (recvData[0]==0x34 && recvData[1]==0xb2) {
        slaveVersion = [NSString stringWithFormat:@"%d.%d",recvData[3],recvData[4]];
    } else if (recvData[0]==0xff) {
        for (int i=6; i<46; i+=2) {
            int number = BYTETOWORD(recvData[i], recvData[i+1]);
            [arrayOneTestPin addObject:@(number)];
        }
    } else if (recvData[0]==0x80 && isRunning) {
        testCount++;
        if (testCount >= testICObject.arrayICPin.count) {
            testCount = 0;
            isWaitData = NO;
            if (isInitial) {
#ifdef TEST
                //输出测试数据
                NSArray *downlaodPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *downlaodDir = [downlaodPaths objectAtIndex:0];
                char filepath[100];
                memset(filepath, 0, sizeof(filepath));
                sprintf(filepath, "%s/data.log",[downlaodDir cStringUsingEncoding:NSASCIIStringEncoding]);
                FILE* file = fopen(filepath, "at+");
                if (file!=NULL) {
                    NSString* sss = @"";
                    sss = [sss stringByAppendingString:@"TestData:"];
                    for (NSNumber* num in arrayOneTestPin) {
                        sss = [sss stringByAppendingString:[NSString stringWithFormat:@"%d,",[num intValue]]];
                    }
                    sss = [sss stringByAppendingString:@"\n"];
                    fputs([sss cStringUsingEncoding:NSUTF8StringEncoding], file);
                }
                fclose(file);
                //*********
#endif
                NSUInteger iccount = testICObject.arrayICPin.count;
                
                NSMutableArray* resultTestPin = [NSMutableArray new];
                NSMutableArray* viewArrayData = [NSMutableArray new];
                BOOL isPass = YES;
                BOOL isShort = NO;
                BOOL isOpen = NO;
                for (ICView* v in arrayICView) {
                    if (v.row==m_nTestRow&&v.column==m_nTestColumn/testICObject.arrayICPin.count) {
                        for (int i=0; i<iccount; i++) {
                            NSArray *testpinarray = [testICObject.arrayICPin objectAtIndex:i];
                            NSMutableArray* tempArray = [NSMutableArray new];
                            for (int j=0; j<testpinarray.count; j++) {
                                NSDictionary* dic = [testpinarray objectAtIndex:j];
                                int pin = [[dic objectForKey:@"pin"]intValue];
                                if (arrayOneTestPin.count>=pin+i*testpinarray.count) {
                                    int pinData = [[arrayOneTestPin objectAtIndex:(pin+i*testpinarray.count)-1]intValue];
                                    int initData = [[arrayInitialData objectAtIndex:(pin+i*testpinarray.count)-1]intValue];
                                    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@(i+1), @"ic", @(pin), @"pin", @(pinData-initData), @"data", @(initData), @"initdata", nil];
                                    [resultTestPin addObject:dic];
                                    [tempArray addObject:dic];
                                }
                            }
                            [viewArrayData addObject:tempArray];
                        }
                        v.arrayData = viewArrayData;
                        //显示产品界面是pass还是fail
                        for (NSArray* array in testICObject.arrayICPin) {
                            for (NSDictionary* d1 in array) {
                                for (NSDictionary* d2 in resultTestPin) {
                                    if ([[d1 objectForKey:@"ic"]intValue]==[[d2 objectForKey:@"ic"]intValue]&&[[d1 objectForKey:@"pin"]intValue]==[[d2 objectForKey:@"pin"]intValue]) {
                                        if ([[d2 objectForKey:@"data"]intValue]>[[d1 objectForKey:@"upperLimit"]intValue] || [[d2 objectForKey:@"data"]intValue]<[[d1 objectForKey:@"lowerLimit"]intValue]) {
                                            isPass = NO;
                                            goto CHECKRESULT;
                                        }
                                    }
                                }
                            }
                        }
                    CHECKRESULT:
                        if (isPass) {
                            [v setFontColor:[NSColor colorWithCalibratedRed:0.0f green:100.0/255.0f blue:0.0f alpha:1.0f]];
                            [v setTitle:@"PASS"];
                            v.isPass = YES;
                        } else {
                            [v setFontColor:[NSColor redColor]];
                            [v setTitle:@"FAIL"];
                            v.isPass = NO;
                        }
                        break;
                    }
                }
                [self changeNumberOfResult:isPass];
//                [[CSVObject sharedManager] setCSVString:@""];
                NSArray* rcArray = [NSArray arrayWithContentsOfFile:[plistPath stringByAppendingPathComponent:[popupButton titleOfSelectedItem]]];
                NSDate* date = [NSDate date];
                //[[CSVObject sharedManager] addString:[NSString stringWithFormat:@"---------%@%ld---------%@---------%04ld-%02ld-%02ld %02ld:%02ld:%02ld\n",[self numberToChar:m_nTestColumn+1],m_nTestRow+1,isPass?@"PASS":@"FAIL",date.year,date.month,date.day,date.hour,date.minute,date.seconds]];
                //[[CSVObject sharedManager] addString:@"IC,PIN,Upeer,Lower,Value,Result\n"];
                
                NSString* textstring;
                NSMutableAttributedString* mstring;
                
                NSMutableArray* arrayTextViewResult = [NSMutableArray new];
                for (int i=0; i<iccount; i++) {
                    NSArray *testpinarray = [testICObject.arrayICPin objectAtIndex:i];
                    for (int j=0; j<testpinarray.count; j++) {
                        NSDictionary* d1 = [testpinarray objectAtIndex:j];
                        for (NSDictionary* d2 in resultTestPin) {
                            if ([[d1 objectForKey:@"ic"]intValue]==[[d2 objectForKey:@"ic"]intValue]&&[[d1 objectForKey:@"pin"]intValue]==[[d2 objectForKey:@"pin"]intValue]) {                       BOOL pinPass = NO;
                                if ([[d2 objectForKey:@"data"]intValue]>[[d1 objectForKey:@"upperLimit"]intValue] || [[d2 objectForKey:@"data"]intValue]<[[d1 objectForKey:@"lowerLimit"]intValue]) {
                                    pinPass = NO;
                                } else {
                                    pinPass = YES;
                                }
                                //[[CSVObject sharedManager] addString:[NSString stringWithFormat:@"%d,%d,%d,%d,%d,%@\n",i+1,[[d1 objectForKey:@"pin"]intValue],[[d1 objectForKey:@"upperLimit"]intValue],[[d1 objectForKey:@"lowerLimit"]intValue],[[d2 objectForKey:@"data"]intValue],pinPass?@"PASS":@"FAIL"]];
                                //textstring = [NSString stringWithFormat:@"IC%d-PIN%d : %d      ",i+1,[[d1 objectForKey:@"pin"]intValue],[[d2 objectForKey:@"data"]intValue]];
                                //NSDictionary* textdic = [NSDictionary dictionaryWithObjectsAndKeys:([self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]]&&[self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]].length>0)?[self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]]:@"NULL", @"title", [d2 objectForKey:@"data"], @"data", [NSNumber numberWithBool:pinPass], @"pass", [d1 objectForKey:@"ic"], @"ic", [d1 objectForKey:@"pin"], "pin", [d1 objectForKey:@"upperLimit"], @"upperLimit", [d1 objectForKey:@"lowerLimit"], @"lowerLimit", nil];
                                NSMutableDictionary* newdic = [NSMutableDictionary dictionary];
                                [newdic setObject:([self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]]&&[self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]].length>0)?[self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]]:@"NULL" forKey:@"title"];
                                [newdic setObject:[d2 objectForKey:@"data"] forKey:@"data"];
                                [newdic setObject:[d2 objectForKey:@"initdata"] forKey:@"initdata"];
                                [newdic setObject:[NSNumber numberWithBool:pinPass] forKey:@"pass"];
                                [newdic setObject:[d1 objectForKey:@"ic"] forKey:@"ic"];
                                [newdic setObject:[d1 objectForKey:@"pin"] forKey:@"pin"];
                                [newdic setObject:[d1 objectForKey:@"upperLimit"] forKey:@"upperLimit"];
                                [newdic setObject:[d1 objectForKey:@"lowerLimit"] forKey:@"lowerLimit"];
                                [newdic setObject:@([self getPositionByTitle:rcArray title:([self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]]&&[self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]].length>0)?[self getStringByPin:rcArray pin:[[d1 objectForKey:@"pin"]intValue]]:@"NULL"])forKey:@"position"];
                                
                                [arrayTextViewResult addObject:newdic];
                            }
                        }
                    }
                }
                
                for (ICView* v in arrayICView) {
                    if (v.row==m_nTestRow&&v.column==m_nTestColumn/testICObject.arrayICPin.count) {
                        v.arrayAllSort = arrayTextViewResult;
                        break ;
                    }
                }
                
                NSString* csvString = [[CSVObject sharedManager] readForCSV];
                int linefeed = 0;
                if (csvString.length < 10) {
                    [[CSVObject sharedManager] setCSVString:@""];
                    [[CSVObject sharedManager] addString:[NSString stringWithFormat:@"Plum Test,Master Firmware Version:%@,Slave Firmware Version:%@\n%@\n",masterVersion,slaveVersion,textProductName.stringValue]];
                    [[CSVObject sharedManager] addString:@"SerialNumber,Position,OverAllResult,ErrorCode,TestTime,"];
                    while (true) {
                        if (linefeed>=rcArray.count) {
                            break;
                        }
                        for (NSDictionary* d1 in rcArray) {
                            if ([[d1 objectForKey:@"Position"]intValue]==linefeed+1) {
                                [[CSVObject sharedManager] addString:[NSString stringWithFormat:@"%@,",[d1 objectForKey:@"RC"]]];
                                linefeed++;
                                break;
                            }
                        }
                    }
                    [[CSVObject sharedManager] addString:@"\n"];
                    [[CSVObject sharedManager] addString:@"UpperLimit-->, , , , ,"];
                    linefeed = 0;
                    while (true) {
                        if (linefeed>=rcArray.count) {
                            break;
                        }
                        if (arrayTextViewResult.count==0) {
                            break;
                        }
                        for (NSDictionary* d1 in rcArray) {
                            if ([[d1 objectForKey:@"Position"]intValue]==linefeed+1) {
                                for (NSDictionary* d2 in arrayTextViewResult) {
                                    if ([[d2 objectForKey:@"title"] isEqualToString:[d1 objectForKey:@"RC"]]) {
                                        [[CSVObject sharedManager] addString:[NSString stringWithFormat:@"%d,",[[d2 objectForKey:@"upperLimit"]intValue]]];
                                        linefeed++;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    [[CSVObject sharedManager] addString:@"\n"];
                    [[CSVObject sharedManager] addString:@"LowerLimit-->, , , , ,"];
                    linefeed = 0;
                    while (true) {
                        if (linefeed>=rcArray.count) {
                            break;
                        }
                        if (arrayTextViewResult.count==0) {
                            break;
                        }
                        for (NSDictionary* d1 in rcArray) {
                            if ([[d1 objectForKey:@"Position"]intValue]==linefeed+1) {
                                for (NSDictionary* d2 in arrayTextViewResult) {
                                    if ([[d2 objectForKey:@"title"] isEqualToString:[d1 objectForKey:@"RC"]]) {
                                        [[CSVObject sharedManager] addString:[NSString stringWithFormat:@"%d,",[[d2 objectForKey:@"lowerLimit"]intValue]]];
                                        linefeed++;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    [[CSVObject sharedManager] addString:@"\n"];
                    [[CSVObject sharedManager] writeToCSV];
                }
                
                
                [[CSVObject sharedManager] setCSVString:@""];
                [[CSVObject sharedManager] addString:[NSString stringWithFormat:@"%@,%@%ld,%@,MYTEMP,%@,",textBarCode.stringValue,[self numberToChar:m_nTestColumn+1],m_nTestRow+1,isPass?@"PASS":@"FAIL",formatDateToStringALL(date)]];
                linefeed = 0;
                NSMutableArray* tempArray = [NSMutableArray arrayWithArray:arrayTextViewResult];
                if (tempArray.count != rcArray.count) {
                    NSRunAlertPanel(@"Error", @"Setting Error!", @"OK", nil, nil);
                    textViewResult.string = @"";
                    for (ICView* v in arrayICView) {
                        if (v.row==m_nTestRow&&v.column==m_nTestColumn/testICObject.arrayICPin.count) {
                            v.arrayAllSort = nil;
                            [v setTitle:[NSString stringWithFormat:@"%@%d",[self numberToChar:(NSInteger)v.column+1],v.row+1]];
                            [v setFontColor:[NSColor blackColor]];
                            break ;
                        }
                    }
                    int nAll = [textAllNum.stringValue intValue];
                    int nPass = [textPassNum.stringValue intValue];
                    int nFail = [textFailNum.stringValue intValue];
                    nAll-=1;
                    textAllNum.stringValue = [NSString stringWithFormat:@"%d",nAll];
                    if (isPass) {
                        nPass-=1;
                        textPassNum.stringValue = [NSString stringWithFormat:@"%d",nPass];
                    } else {
                        nFail-=1;
                        textFailNum.stringValue = [NSString stringWithFormat:@"%d",nFail];
                    }
                    if (nAll==0) {
                        textPercentage.stringValue = @"0.00%";
                    } else {
                        float percentage = nPass/(float)nAll;
                        textPercentage.stringValue = [NSString stringWithFormat:@"%.2f%%",percentage*100];
                    }
                    return ;
                }
                while (true) {
                    if (linefeed>=rcArray.count) {
                        break;
                    }
                    for (NSDictionary* d1 in rcArray) {
                        if ([[d1 objectForKey:@"Position"]intValue]==linefeed+1) {
                            for (NSDictionary* d2 in tempArray) {
                                if ([[d2 objectForKey:@"title"] isEqualToString:[d1 objectForKey:@"RC"]]) {
                                    //textview的输出
                                    textstring = [NSString stringWithFormat:@"%@ : %d (%d - %d , %d)      ",[d2 objectForKey:@"title"],[[d2 objectForKey:@"data"]intValue],[[d2 objectForKey:@"lowerLimit"]intValue],[[d2 objectForKey:@"upperLimit"]intValue],[[d2 objectForKey:@"initdata"]intValue]];
                                    linefeed++;
                                    if (linefeed%5==0) {
                                        textstring = [textstring stringByAppendingString:@"\n"];
                                    }
                                    mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
                                    if ([[d2 objectForKey:@"pass"]boolValue]) {
                                        [mstring addAttribute:NSForegroundColorAttributeName value:TEXTPASSCOLOR range:NSMakeRange(0,[mstring length])];
                                    } else {
                                        [mstring addAttribute:NSForegroundColorAttributeName value:TEXTFAILCOLOR range:NSMakeRange(0,[mstring length])];
                                        if ([[d2 objectForKey:@"data"]intValue]<[[d2 objectForKey:@"lowerLimit"]intValue]&&[[d2 objectForKey:@"data"]intValue]>=-10) {
                                            isOpen = YES;
                                        } else if ([[d2 objectForKey:@"data"]intValue]>[[d2 objectForKey:@"upperLimit"]intValue]||[[d2 objectForKey:@"data"]intValue]<-10) {
                                            isShort = YES;
                                        }
                                    }
                                    [textViewResult insertText:mstring];
                                    
                                    //csv的输出
                                    //[[CSVObject sharedManager] addString:[NSString stringWithFormat:@"%d,%@,%d,%d,%d,%@\n",[[d2 objectForKey:@"ic"]intValue],[d2 objectForKey:@"title"],[[d2 objectForKey:@"upperLimit"]intValue],[[d2 objectForKey:@"lowerLimit"]intValue],[[d2 objectForKey:@"data"]intValue],([[d2 objectForKey:@"pass"]boolValue])?@"PASS":@"FAIL"]];
                                    [[CSVObject sharedManager] addString:[NSString stringWithFormat:@"%d,",[[d2 objectForKey:@"data"]intValue]]];
                                    [tempArray removeObject:d2];
                                    break;
                                }
                            }
                        }
                    }
                }
                
                [[CSVObject sharedManager] addString:@"\n"];
                if (isShort&&isOpen) {
                    NSString* mystring = [[CSVObject sharedManager]getCSVString];
                    mystring = [mystring stringByReplacingOccurrencesOfString:@"MYTEMP" withString:@"Open and Short"];
                    [[CSVObject sharedManager] setCSVString:mystring];
                } else {
                    if (isShort) {
                        NSString* mystring = [[CSVObject sharedManager]getCSVString];
                        mystring = [mystring stringByReplacingOccurrencesOfString:@"MYTEMP" withString:@"Short"];
                        [[CSVObject sharedManager] setCSVString:mystring];
                    } else if (isOpen) {
                        NSString* mystring = [[CSVObject sharedManager]getCSVString];
                        mystring = [mystring stringByReplacingOccurrencesOfString:@"MYTEMP" withString:@"Open"];
                        [[CSVObject sharedManager] setCSVString:mystring];
                    } else {
                        NSString* mystring = [[CSVObject sharedManager]getCSVString];
                        mystring = [mystring stringByReplacingOccurrencesOfString:@"MYTEMP" withString:@""];
                        [[CSVObject sharedManager] setCSVString:mystring];
                    }
                }
                [[CSVObject sharedManager] writeToCSV];
                
                [textViewResult insertText:@"\n\n"];
                
                textstring = [NSString stringWithFormat:@"********************Finish %@%ld Test at %@\n",[self numberToChar:m_nTestColumn+1],m_nTestRow+1,formatDateToStringALL(date)];
                mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
                [mstring addAttribute:NSForegroundColorAttributeName value:TEXTCOLOR range:NSMakeRange(0,[mstring length])];
                [textViewResult insertText:mstring];
                
                if (isShort) {
                    textstring = @"********************Result:Short Test Fail\n";
                    mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
                    [mstring addAttribute:NSForegroundColorAttributeName value:TEXTCOLOR range:NSMakeRange(0,[mstring length])];
                    [mstring addAttribute:NSForegroundColorAttributeName value:TEXTFAILCOLOR range:NSMakeRange([mstring length]-5,5)];
                    [textViewResult insertText:mstring];
                }
                
                if (isOpen) {
                    textstring = @"********************Result:Open Test Fail\n";
                    mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
                    [mstring addAttribute:NSForegroundColorAttributeName value:TEXTCOLOR range:NSMakeRange(0,[mstring length])];
                    [mstring addAttribute:NSForegroundColorAttributeName value:TEXTFAILCOLOR range:NSMakeRange([mstring length]-5,5)];
                    [textViewResult insertText:mstring];
                }
                
                textstring = [NSString stringWithFormat:@"********************All Result: %@\n", isPass?@"Pass":@"Fail"] ;
                mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
                [mstring addAttribute:NSForegroundColorAttributeName value:TEXTCOLOR range:NSMakeRange(0,[mstring length])];
                if (!isPass) {
                    [mstring addAttribute:NSForegroundColorAttributeName value:TEXTFAILCOLOR range:NSMakeRange([mstring length]-5,5)];
                } else {
                    [mstring addAttribute:NSForegroundColorAttributeName value:PASSCOLOR range:NSMakeRange([mstring length]-5,5)];
                }
                [textViewResult insertText:mstring];
                if (arrayICView.count>1) {
                    textstring = [NSString stringWithFormat:@"end%@%ld\n\n",[self numberToChar:m_nTestColumn+1],m_nTestRow+1];
                    mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
                    [mstring addAttribute:NSForegroundColorAttributeName value:TEXTCOLOR range:NSMakeRange(0,[mstring length])];
                    [textViewResult insertText:mstring];
                }
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:logPath] && arrayICView.count==1) {
                    NSMutableData* data1 = [NSMutableData dataWithContentsOfFile:logPath];
                    NSDictionary* docAttributes;
                    NSAttributedString* attrString = [[NSAttributedString alloc]
                                                      initWithRTF:data1 documentAttributes:&docAttributes];
                    [textViewTemp insertText:attrString];
                    [textViewTemp insertText:@"\n\n"];
                    [textViewTemp insertText:textViewResult.textStorage];
                    NSData* data2 = [textViewTemp.textStorage dataFromRange:NSMakeRange(0, textViewTemp.textStorage.length) documentAttributes:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} error:nil];
                    [data2 writeToFile:logPath atomically:YES];
                    textViewTemp.string = @"";
#ifdef OLDMETHOD
                    NSData* data1 = [NSData dataWithContentsOfFile:logPath];
                    NSData* data2 = [textViewTemp.textStorage dataFromRange:NSMakeRange(0, textViewTemp.textStorage.length) documentAttributes:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} error:nil];
                    NSFileHandle *inFile = [NSFileHandle fileHandleForUpdatingAtPath:logPath];
                    [inFile seekToFileOffset:data1.length];  //将节点跳到文件的末尾
                    [inFile writeData:data2];
                    [inFile synchronizeFile];
                    [inFile closeFile];
#endif
                } else {
                    NSData* data = [textViewResult.textStorage dataFromRange:NSMakeRange(0, textViewResult.textStorage.length) documentAttributes:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} error:nil];
                    [data writeToFile:logPath atomically:YES];
                }
                
                if (arrayICView.count>1) {
                    [btStart setEnabled:NO];
                } else {
                    [btStart setEnabled:YES];
                }
                
                BOOL allPass = YES;
                for (ICView* v in arrayICView) {
                    if (v.isPass == NO) {
                        allPass = NO;
                        break;
                    }
                }
                textPassOrFail.stringValue = allPass?@"PASS":@"FAIL";
                if (allPass) {
                    textPassOrFail.textColor = PASSCOLOR;
                } else {
                    textPassOrFail.textColor = TEXTFAILCOLOR;
                }
                if (arrayICView.count==1) {
                    textBarCode.stringValue = @"";
                }
                isRunning = NO;
            } else {
                arrayInitialData = [NSMutableArray arrayWithArray:arrayOneTestPin];
                isInitial = YES;
                isRunning = NO;
                [btInitial setTitle:@"Initial OK"];
                [btInitial setEnabled:YES];
                NSString* textstring = @"********************Initial OK********************\n\n";
                NSMutableAttributedString* mstring = [[NSMutableAttributedString alloc]initWithString:textstring];
                [textViewResult insertText:mstring];
                
#ifdef TEST
                //输出初始化数据
                NSArray *downlaodPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *downlaodDir = [downlaodPaths objectAtIndex:0];
                char filepath[100];
                memset(filepath, 0, sizeof(filepath));
                sprintf(filepath, "%s/data.log",[downlaodDir cStringUsingEncoding:NSASCIIStringEncoding]);
                FILE* file = fopen(filepath, "at+");
                if (file!=NULL) {
                    NSString* sss = @"";
                    sss = [sss stringByAppendingString:@"Initial:"];
                    for (NSNumber* num in arrayInitialData) {
                        sss = [sss stringByAppendingString:[NSString stringWithFormat:@"%d,",[num intValue]]];
                    }
                    sss = [sss stringByAppendingString:@"\n"];
                    fputs([sss cStringUsingEncoding:NSUTF8StringEncoding], file);
                }
                fclose(file);
                //*********
#endif
            }
        } else {
            char outbuff[4];
            memset(outbuff, 0x00, sizeof(outbuff));
            outbuff[0]=0x01;
            outbuff[1]=0x04;
            outbuff[2]=0x01;
            outbuff[3]=testCount+1;
            [usbHid senddata:outbuff];
        }
    } else if (recvData[0]==0x81) {
        isWaitData = NO;
        if (arrayICView.count>1) {
            [btStart setEnabled:NO];
        } else {
            [btStart setEnabled:YES];
        }
        if (!isInitial) {
            [btInitial setEnabled:YES];
        }
        isRunning = NO;
        m_nTestColumn=0;
        NSRunAlertPanel(@"Error", @"Return Error!", @"OK", nil, nil);
    }
}

- (void)usbhidDidMatch {
    isRunning = NO;
    if (arrayICView.count>1) {
        [btStart setEnabled:NO];
    } else {
        [btStart setEnabled:YES];
    }
    imageUSBState.image = [NSImage imageNamed:@"Connect.png"];
    [imageUSBState setToolTip:@"Usb Connected"];
    char buff1[2] = {0x01, 0xb1};
    [usbHid senddata:buff1];
}

- (void)usbhidDidRemove {
    isRunning = NO;
    [btStart setEnabled:NO];
    imageUSBState.image = [NSImage imageNamed:@"Disconnect.png"];
    [imageUSBState setToolTip:@"Usb Error"];
    isInitial = NO;
    [btInitial setTitle:@"Initial"];
}

- (NSString*)numberToChar:(NSInteger)number {
    if (number<1 || number>24) {
        return @"";
    }
    return [NSString stringWithFormat:@"%c", (char)(number-1+'A')];
}

#pragma mark 测试结束后的操作
- (void)changeNumberOfResult:(BOOL)isPass {
    int nAll = [textAllNum.stringValue intValue];
    int nPass = [textPassNum.stringValue intValue];
    int nFail = [textFailNum.stringValue intValue];
    nAll+=1;
    textAllNum.stringValue = [NSString stringWithFormat:@"%d",nAll];
    if (isPass) {
        nPass+=1;
        textPassNum.stringValue = [NSString stringWithFormat:@"%d",nPass];
    } else {
        nFail+=1;
        textFailNum.stringValue = [NSString stringWithFormat:@"%d",nFail];
    }
    float percentage = nPass/(float)nAll;
    textPercentage.stringValue = [NSString stringWithFormat:@"%.2f%%",percentage*100];
}

- (NSString*)getStringByPin:(NSArray*)array pin:(int)pin{
    for (NSDictionary* dic in array) {
        if ([dic objectForKey:@"ICPIN"]&&[[dic objectForKey:@"ICPIN"]intValue]==pin) {
            return [dic objectForKey:@"RC"];
        }
    }
    return nil;
}

- (int)getPositionByTitle:(NSArray*)array title:(NSString*)title{
    for (NSDictionary* dic in array) {
        if ([[dic objectForKey:@"RC"] isEqualToString:title]) {
            return [[dic objectForKey:@"Position"]intValue];
        }
    }
    return -1;
}

- (void)shakeWindow {
    static int numberOfShakes = 10;
    static float durationOfShake = 0.3f;
    static float vigourOfShake = 0.05f;
    
    CGRect frame=[self.window frame];
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
    for (NSInteger index = 0; index < numberOfShakes; index++){
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
    }
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    
    [self.window setAnimations:[NSDictionary dictionaryWithObject: shakeAnimation forKey:@"frameOrigin"]];
    [[self.window animator] setFrameOrigin:[self.window frame].origin];
}

@end
