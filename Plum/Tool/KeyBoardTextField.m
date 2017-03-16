//
//  KeyBoardTextField.m
//  KingCrab
//
//  Created by tpk on 14-10-28.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "KeyBoardTextField.h"

@implementation KeyBoardTextField

@synthesize myDelegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)viewDidMoveToWindow {
//    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveInKeyWindow);
//    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds] options:options owner:self userInfo:nil];
//    [self addTrackingArea:area];
//    [self setAcceptsTouchEvents:YES];
    
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
}

- (void)keyUp:(NSEvent *)theEvent {
    [super keyUp:theEvent];
    if ([myDelegate respondsToSelector:@selector(acceptKeyCode:keyCode:)]) {
        [myDelegate acceptKeyCode:self keyCode:theEvent.keyCode];
    }
}

//- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
//{
//    NSLog(@"performkeyequivalent");
//    return YES;
//}

//- (BOOL) acceptsFirstResponder {
//    return YES;
//}
//
//- (BOOL) becomeFirstResponder {
//    return YES;
//}
//
//- (BOOL) resignFirstResponder {
//    return NO;
//}

@end
