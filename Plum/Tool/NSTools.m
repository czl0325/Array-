//
//  UITools.m
//  PetClaw
//
//  Created by yihang zhuang on 11/1/12.
//  Copyright (c) 2012 ZQ. All rights reserved.
//

#import "NSTools.h"

#pragma mark NSTextField
NSTextField* createLable(NSString* str, float fontsize) {
    NSTextField* textField = [[NSTextField alloc]initWithFrame:NSMakeRect(0, 0, 100, fontsize+6)];
    textField.bordered = NO;
    textField.backgroundColor = [NSColor clearColor];
    textField.editable = NO;
    textField.alignment = NSLeftTextAlignment;
    textField.font = [NSFont systemFontOfSize:fontsize];
    textField.stringValue = str;;
    return textField;
}


#pragma mark date
NSString *formatDateToString( NSDate *date ){
    NSString *s = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",
                   (long)date.year,(long)date.month,(long)date.day];
    return s;
}

NSString *formatDateToStringALL( NSDate *date ){
    NSString *s = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld",
                   (long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)date.minute,(long)date.seconds];
    return s;
}

NSDate *formatStringToDate( NSString *string ){
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:string];
    return date;
}

NSDate *formatStringToDateEx( NSString *string ){
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:string];
    
    return date;
}

NSDate *dateZero( NSDate *olddate ){
    NSMutableString* string = [NSMutableString stringWithString:formatDateToStringALL(olddate)];
    [string replaceCharactersInRange:NSMakeRange(string.length-2, 2) withString:@"00"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:string];
    return date;
}




