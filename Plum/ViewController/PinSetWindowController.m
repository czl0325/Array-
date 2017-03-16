//
//  PinSetWindowController.m
//  Plum
//
//  Created by tpk on 14-11-17.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "PinSetWindowController.h"
#import <QuartzCore/QuartzCore.h>

@interface PinSetWindowController ()

@end

@implementation PinSetWindowController

- (id)initWithPinObject:(PINObject*)obj {
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if (self) {
        // Initialization code here.
        m_pinObject = obj;
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
//    CALayer *layer = [CALayer layer];
//    [self.window.contentView setLayer:layer];
//    [self.window.contentView setWantsLayer:YES];
//    textUpperLimit.layer = [CALayer layer];
    self.window.title = [NSString stringWithFormat:@"IC : %d, PIN : %d",m_pinObject.ic,m_pinObject.pin];
    textUpperLimit.stringValue = [NSString stringWithFormat:@"%d",m_pinObject.upperLimit];
    textLowerLimit.stringValue = [NSString stringWithFormat:@"%d",m_pinObject.lowerLimit];
}

- (IBAction)clickOK:(id)sender {
    if ([textUpperLimit.stringValue intValue] <= [textLowerLimit.stringValue intValue]) {
        [self shakeWindow];
        return ;
    }
    m_pinObject.upperLimit = [textUpperLimit.stringValue intValue];
    m_pinObject.lowerLimit = [textLowerLimit.stringValue intValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePinObject" object:m_pinObject];
    
    [self playAnimation];
}

- (IBAction)clickCancel:(id)sender {
    [self playAnimation];
}

- (void)playAnimation {
    NSRect firstFrame = [self.window frame];
    //属性字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //设置目标对象
    [dict setObject:self.window forKey:NSViewAnimationTargetKey];
    //设置其实大小
    [dict setObject:[NSValue valueWithRect:firstFrame] forKey:NSViewAnimationStartFrameKey];
    firstFrame = NSMakeRect(firstFrame.origin.x+firstFrame.size.width/2, firstFrame.origin.y+firstFrame.size.height/2, 0, 0);
    //设置最终大小
    [dict setObject:[NSValue valueWithRect:firstFrame] forKey:NSViewAnimationEndFrameKey];
    //设置动画效果
    [dict setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
    //设置动画
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
    [animation setDuration:0.25f];
    [animation setDelegate:self];
    [animation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
    //启动动画
    [animation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation {
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

@end
