//
//  PinView.m
//  Plum
//
//  Created by tpk on 14-11-17.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "PinView.h"

@implementation PinView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _selected = NO;
        _isEnter = NO;
        title = @"";
        
        normalColor = [NSColor colorWithCalibratedRed:66.0/255.0 green:118.0/255.0 blue:147.0/255.0 alpha:127.0/255.0];
        enterColor = [NSColor colorWithCalibratedRed:255.0/255.0 green:255.0/255.0 blue:0.0 alpha:50.0/255.0];;
        
        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSColor* nowColor;
    if (_isEnter) {
        nowColor = enterColor;
    } else {
        nowColor = normalColor;
    }
    [nowColor set];
    [NSBezierPath fillRect:self.bounds];
    
//    [[NSColor colorWithCalibratedRed:91.0/255.0 green:165.0/255.0 blue:195.0/255.0 alpha:1.0f]set];
//    [NSBezierPath setDefaultLineWidth:3];
//    [NSBezierPath strokeRect:dirtyRect];
    
    // title
    if (title.length > 0) {
        NSMutableDictionary *titleAttributes = [[NSMutableDictionary alloc] init];
        [titleAttributes setValue:[NSFont fontWithName:@"Helvetica" size:25] forKey:NSFontAttributeName];
        
        [titleAttributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        
        NSSize titleSize = [title sizeWithAttributes:titleAttributes];
        CGFloat verticalPoint = ([self bounds].size.height/2) - (titleSize.height/2);
        CGFloat horizontalPoint = ([self bounds].size.width/2) - (titleSize.width/2);
        [title drawAtPoint:NSMakePoint(horizontalPoint, verticalPoint) withAttributes:titleAttributes];
    }
}

- (void)setNormalColor:(NSColor *)color {
    normalColor = color;
    [self setNeedsDisplay:YES];
}

- (void)setEnterColor:(NSColor *)color {
    enterColor = color;
    [self setNeedsDisplay:YES];
}

- (void)setTitle:(NSString*)str {
    title = str;
    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    _isEnter = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    _isEnter = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (theEvent.clickCount >= 2) {
        if ([delegate respondsToSelector:@selector(doubleClickPinView:from:)]) {
            [delegate doubleClickPinView:theEvent from:self];
        }
    } else {
        if ([delegate respondsToSelector:@selector(clickPinView:from:)]) {
            [delegate clickPinView:theEvent from:self];
        }
    }
}

- (void)scrollWheel:(NSEvent *)theEvent {
    [super scrollWheel:theEvent];
}

- (void)setPinObject:(PINObject*)obj {
    pinObject = obj;
}

- (PINObject*)getPinObject {
    return pinObject;
}

@end
