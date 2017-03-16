//
//  ColorButton.m
//  KingCrab
//
//  Created by tpk on 14-10-22.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "ColorButton.h"

@implementation ColorButton

@synthesize backColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        isEnable = YES;
        isfull = YES;
        backColor = [NSColor colorWithCalibratedRed:0.0f green:100.0/255.0 blue:0.0 alpha:1.0f];
        self.image = [NSImage imageNamed:@"Connect.png"];
        
        
//        outerShadow = [[NSShadow alloc] init];
//        [outerShadow setShadowColor: [NSColor blackColor]];
//        [outerShadow setShadowOffset: NSMakeSize(0.1, 0.1)];
//        [outerShadow setShadowBlurRadius: 2];
    }
    return self;
}

- (void)viewDidMoveToWindow {
    [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
//    NSRect slotRect = NSMakeRect(0, 0, dirtyRect.size.width, dirtyRect.size.height);
//    NSBezierPath *slotPath = [NSBezierPath bezierPathWithRoundedRect: slotRect xRadius: dirtyRect.size.width/2 yRadius: dirtyRect.size.height/2];
//    [NSGraphicsContext saveGraphicsState];
//    [outerShadow set];
//    [[NSColor darkGrayColor] setFill];
//    [slotPath fill];
    
//    NSBezierPath *bp = [NSBezierPath bezierPathWithOvalInRect:dirtyRect];
//    [backColor set];
//    [bp fill];
}

-(BOOL)getEnable {
    return isEnable;
}

-(void)setEnable:(BOOL)enable {
//    if (isEnable==enable) {
//        return;
//    }
    isEnable = enable;
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    if (isEnable) {
        self.image = [NSImage imageNamed:@"Connect.png"];
        //backColor = [NSColor colorWithCalibratedRed:0.0f green:100.0/255.0 blue:0.0 alpha:1.0f];
        self.alphaValue=1.0f;
        isfull=YES;
    } else {
        self.image = [NSImage imageNamed:@"Disconnect.png"];
        //backColor = [NSColor redColor];
        //timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeAlpha) userInfo:nil repeats:YES];
    }
    [self setNeedsDisplay:YES];
}

- (void)changeAlpha {
    if (isfull) {
        self.alphaValue-=0.2f;
        if (self.alphaValue<=0.0f) {
            isfull=NO;
        }
    } else {
        self.alphaValue+=0.2f;
        if (self.alphaValue>=1.0f) {
            isfull=YES;
        }
    }
}

//-(void)setPopupView:(BaseStateViewController*)viewController {
//    if (popoverController) {
//        popoverController = nil;
//    }
//    popoverController = [[INPopoverController alloc] initWithContentViewController:viewController];
//}
//
//- (void)mouseDown:(NSEvent *)theEvent {
//    if (!popoverController.popoverIsVisible) {
//        [popoverController presentPopoverFromRect:[self bounds] inView:self preferredArrowDirection:INPopoverArrowDirectionDown anchorsToPositionView:YES];
//    }
//}

//- (void)mouseEntered:(NSEvent *)theEvent {
//    if (!popoverController.popoverIsVisible) {
//        [popoverController presentPopoverFromRect:[self bounds] inView:self preferredArrowDirection:INPopoverArrowDirectionLeft anchorsToPositionView:YES];
//    }
//}

//- (void)mouseExited:(NSEvent *)theEvent {
//    [popoverController closePopover:nil];
//}

@end
