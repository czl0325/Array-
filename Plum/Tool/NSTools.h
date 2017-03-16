//
//  UITools.h
//  PetClaw
//
//  Created by yihang zhuang on 11/1/12.
//  Copyright (c) 2012 ZQ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSDate-Utilities.h"
#import "NSViewExt.h"

//UINavigationController *gNav;
#ifdef __cplusplus
extern "C" {
#endif
    
    //NSTextfield
    NSTextField* createLable(NSString* str, float fontsize);
    
    //date
    NSString *formatDateToString( NSDate *date );
    NSString *formatDateToStringALL( NSDate *date );
    NSDate *formatStringToDate( NSString *string );
    NSDate *formatStringToDateEx( NSString *string );
    NSDate *dateZero( NSDate *olddate );
    
#ifdef __cplusplus
}
#endif
