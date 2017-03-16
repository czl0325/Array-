//
//  PasswordWindowController.m
//  Margaux-OQC
//
//  Created by tpk on 14-12-2.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "PasswordWindowController.h"
#import <QuartzCore/QuartzCore.h>

@interface PasswordWindowController ()

@end

@implementation PasswordWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)clickOK:(id)sender {
    if ([textPassword.stringValue isEqualToString:@"test"]) {
        [self close];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoSettingView" object:@(YES)];
    } else {
        [self shakeWindow];
    }
}

- (IBAction)clickCancel:(id)sender {
    [self close];
}

- (void)shakeWindow {
    static int numberOfShakes = 3;
    static float durationOfShake = 0.5f;
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

- (void) controlTextDidChange:(NSNotification *)notification {
    //在这里进行处理，比如计算输入的字符数等
    
} 

@end
