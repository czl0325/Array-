//
//  ICView.h
//  Plum
//
//  Created by tpk on 14-11-10.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ICViewDelegate <NSObject>
@optional
- (void)clickICView:(NSEvent *)event from:(id)sender;
@end

@interface ICView : NSControl {
    NSColor* normalColor;
    NSColor* enterColor;
    NSColor* selectColor;
    NSString *title;
    NSColor* fontColor;
    BOOL _selected;
    BOOL _isEnter;
    NSTextField* textTitle;
    NSMenu *ICMenu;
}

@property (weak) id<ICViewDelegate> delegate;
@property (nonatomic,assign) int row;
@property (nonatomic,assign) int column;
@property (nonatomic,strong) NSArray* arrayData;
@property (nonatomic,strong) NSArray* arrayTestPin;
@property (nonatomic,strong) NSArray* arrayAllSort;
@property (nonatomic,assign) BOOL isPass;

- (void)setNormalColor:(NSColor *)color;
- (void)setEnterColor:(NSColor *)color;
- (void)setSelectColor:(NSColor *)color;
- (void)setTitle:(NSString*)str;
- (void)setFontColor:(NSColor*)color;

@end
