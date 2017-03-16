//
//  ColorTextButton.m
//  macusb
//
//  Created by tpk on 14-9-2.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "ColorTextButton.h"

@interface NSButtonCell()
- (void)_updateMouseTracking;
@end

@implementation ColorButtonCell
@synthesize normal,hover,push,disable;
- (NSColor *)textColor
{
    NSAttributedString *attrTitle = [self attributedTitle];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, MIN(len, 1)); // take color from first char
    NSDictionary *attrs = [attrTitle fontAttributesInRange:range];
    NSColor *textColor = [NSColor controlTextColor];
    if (attrs) {
        textColor = [attrs objectForKey:NSForegroundColorAttributeName];
    }
    return textColor;
}

- (void)setTextColor:(NSColor *)textColor
{
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
                                            initWithAttributedString:[self attributedTitle]];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    [attrTitle addAttribute:NSForegroundColorAttributeName
                      value:textColor
                      range:range];
    [attrTitle fixAttributesInRange:range];
    [self setAttributedTitle:attrTitle];
}

- (void)awakeFromNib
{
    [self setBordered:NO];
    [self setButtonType:NSMomentaryChangeButton];
    [self setTitle:[self title]];
    [self setTextColor:[NSColor blackColor]];
}


- (void)mouseEntered:(NSEvent *)event
{
    if (hover != nil)
    {
        [self setTextColor:hover];
    }
}

- (void)mouseExited:(NSEvent *)event
{
    NSLog(@"mouseExited\n");
    if(!bClick)
    {
        if (normal != nil)
        {
            [self setTextColor:normal];
            NSLog(@"[%@]mouseExited\n",self );
        }
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (push != nil)
    {
        [self setTextColor:push];
        bClick = YES;
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (hover != nil)
    {
        [self setTextColor:hover];
    }
}

- (void)_updateMouseTracking
{
    [super _updateMouseTracking];
    if ([self controlView] != nil && [[self controlView] respondsToSelector:@selector(_setMouseTrackingForCell:)])
    {
        [[self controlView] performSelector:@selector(_setMouseTrackingForCell:) withObject:self];
    }
}

- (void)_setMouseTrackingForCell:(id)sender {
    NSLog(@"setMouseTrackingForCell=%@",sender);
}

- (void)setHeightLight:(BOOL)b
{
    if(b)
    {
        if (hover != nil)
        {
            [self setTextColor:hover];
            bClick = YES;
        }
    }
    else
    {
        if (normal != nil)
        {
            [self setTextColor:normal];
            bClick = NO;
        }
    }
}

@end

@implementation NSButton (ColorButton)

- (void)setHoverColor:(NSColor *)textColor
{
    [[self cell] setHover:textColor];
}

- (void)setNormalColor:(NSColor *)textColor
{
    [[self cell] setNormal:textColor];
}

- (void)setPushColor:(NSColor *)textColor
{
    [[self cell] setPush:textColor];
}

- (void)setDisableColor:(NSColor *)textColor
{
    [[self cell] setDisable:textColor];
}

- (void)setHeightLight:(BOOL)b
{
    [[self cell] setHeightLight:b];
    [self setNeedsDisplay:YES];
}

@end

@implementation CustomButton

- (void)mouseDown:(NSEvent *)theEvent
{
    [[self cell] mouseDown:theEvent];
    [super mouseDown:theEvent];
    [[self cell] mouseUp:theEvent];
}

@end
