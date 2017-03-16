//
//  ColorTextButton.h
//  macusb
//
//  Created by tpk on 14-9-2.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NSButton (ColorButton)
- (void)setHoverColor:(NSColor *)textColor;
- (void)setNormalColor:(NSColor *)textColor;
- (void)setPushColor:(NSColor *)textColor;
- (void)setDisableColor:(NSColor *)textColor;
- (void)setHeightLight:(BOOL)b;
@end

@interface CustomButton : NSButton
@end

@interface ColorButtonCell : NSButtonCell
{
    BOOL bClick;
}
@property (nonatomic,retain) NSColor *normal;
@property (nonatomic,retain) NSColor *hover;
@property (nonatomic,retain) NSColor *push;
@property (nonatomic,retain) NSColor *disable;
@end
