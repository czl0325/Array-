//
//  ColorButton.h
//  KingCrab
//
//  Created by tpk on 14-10-22.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <INPopoverController/INPopoverController.h>
//#import "BaseStateViewController.h"

@interface ColorButton : NSImageView {
    BOOL isEnable;
    NSTimer* timer;
    BOOL isfull;
    NSShadow* outerShadow;
    //INPopoverController *popoverController;
}

@property(nonatomic,strong)NSColor *backColor;

-(BOOL)getEnable;
-(void)setEnable:(BOOL)enable;
//-(void)setPopupView:(BaseStateViewController*)viewController;

@end
