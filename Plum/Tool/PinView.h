//
//  PinView.h
//  Plum
//
//  Created by tpk on 14-11-17.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PINObject.h"

@protocol PinViewDelegate <NSObject>
@optional
- (void)clickPinView:(NSEvent *)event from:(id)sender;
- (void)doubleClickPinView:(NSEvent *)event from:(id)sender;
@end

@interface PinView : NSControl {
    NSColor* normalColor;
    NSColor* enterColor;
    NSString *title;
    BOOL _selected;
    BOOL _isEnter;
    PINObject* pinObject;
}

@property (weak) id<PinViewDelegate> delegate;

- (void)setNormalColor:(NSColor *)color;
- (void)setEnterColor:(NSColor *)color;
- (void)setTitle:(NSString*)str;
- (void)setPinObject:(PINObject*)obj;
- (PINObject*)getPinObject;

@end
