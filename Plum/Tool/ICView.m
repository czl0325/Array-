//
//  ICView.m
//  Plum
//
//  Created by tpk on 14-11-10.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "ICView.h"
#import "NSViewExt.h"

@implementation ICView

@synthesize delegate;
@synthesize row;
@synthesize column;
@synthesize arrayData;
@synthesize arrayTestPin;
@synthesize arrayAllSort;
@synthesize isPass;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        normalColor = [NSColor colorWithCalibratedRed:66.0/255.0 green:118.0/255.0 blue:147.0/255.0 alpha:127.0/255.0];
        enterColor = [NSColor colorWithCalibratedRed:255.0/255.0 green:255.0/255.0 blue:0.0 alpha:50.0/255.0];;
        
        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
        
//        textTitle = [[NSTextField alloc]initWithFrame:NSMakeRect(5, 0, frame.size.width-10, frame.size.height-20)];
//        [textTitle setBezeled:NO];
//        [textTitle setDrawsBackground:NO];
//        textTitle.top = self.height-10;
//        textTitle.stringValue = @"row=1";
//
//        [self addSubview:textTitle];
        
        _selected = NO;
        _isEnter = NO;
        arrayData = nil;
        arrayTestPin = nil;
        arrayAllSort = nil;
        
        ICMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Custom"];
        
        NSMenuItem *item1 = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Test Again" action:@selector(testAgain) keyEquivalent:@""];
        [item1 setTarget:self];
        [item1 setEnabled:YES];
        [ICMenu addItem:item1];
        NSMenuItem *item2 = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Clear Data" action:@selector(clearData) keyEquivalent:@""];
        [item2 setTarget:self];
        [item2 setEnabled:YES];
        [ICMenu addItem:item2];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
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
    
    [[NSColor colorWithCalibratedRed:91.0/255.0 green:165.0/255.0 blue:195.0/255.0 alpha:1.0f]set];
    [NSBezierPath setDefaultLineWidth:3];
    [NSBezierPath strokeRect:dirtyRect];
    
    // title
    if (title.length > 0) {
        int fontSize = 1;
        NSMutableDictionary *titleAttributes = [[NSMutableDictionary alloc] init];
        while (TRUE) {
            [titleAttributes setValue:[NSFont fontWithName:@"Helvetica" size:fontSize] forKey:NSFontAttributeName];
            
            NSSize titleSize = [title sizeWithAttributes:titleAttributes];
            if (titleSize.width >= self.bounds.size.width*5/6 || titleSize.height >= self.bounds.size.height*3/4) {
                break;
            }
            fontSize++;
        }
        
        if (fontColor) {
            [titleAttributes setValue:fontColor forKey:NSForegroundColorAttributeName];
        } else {
            [titleAttributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        }
        
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

- (void)setSelectColor:(NSColor *)color {
    selectColor = color;
    [self setNeedsDisplay:YES];
}

- (void)setTitle:(NSString*)str {
    title = str;
    [self setNeedsDisplay:YES];
}

- (void)setFontColor:(NSColor*)color {
    fontColor = color;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if ([delegate respondsToSelector:@selector(clickICView:from:)]) {
        [delegate clickICView:theEvent from:self];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    _isEnter = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    _isEnter = NO;
    [self setNeedsDisplay:YES];
}

- (void)rightMouseUp:(NSEvent *)theEvent {
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [ICMenu popUpMenuPositioningItem:nil atLocation:location inView:self];
}

- (void)testAgain {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ICViewTestAgain" object:self];
}

- (void)seeChart {
    NSLog(@"seeChart");
}

- (void)clearData {
    if (!arrayAllSort) {
        return ;
    }
    arrayAllSort = nil;
    [self setTitle:[NSString stringWithFormat:@"%@%d",[self numberToChar:column+1],row+1]];
    [self setFontColor:[NSColor blackColor]];
    [self setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTextViewResult" object:self];
}

- (NSString*)numberToChar:(NSInteger)number {
    if (number<1 || number>24) {
        return @"";
    }
    return [NSString stringWithFormat:@"%c", (char)(number-1+'A')];
}


@end
