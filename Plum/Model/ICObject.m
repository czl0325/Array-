//
//  ICObject.m
//  Plum
//
//  Created by tpk on 14-11-10.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "ICObject.h"

@implementation ICObject

@synthesize productName;
@synthesize row;
@synthesize column;
@synthesize upperLimit;
@synthesize lowerLimit;
@synthesize arrayICPin;
@synthesize strICPin;
@synthesize pinRow;
@synthesize pinColumn;

+ (NSMutableArray*)changeToDataArray:(NSString*)textString {
    NSMutableArray* mutableArray = [NSMutableArray new];
    NSArray* arrayAll = [textString componentsSeparatedByString:@";"];
    for (NSString* oneString in arrayAll) {
        NSArray* array = [oneString componentsSeparatedByString:@","];
        NSString* firstArray = [array objectAtIndex:0];
        if (array.count<=0 || firstArray.length==0) {
            continue ;
        }
        NSMutableArray* arrayOne = [NSMutableArray new];
        for (NSString* str in array) {
            if (str.length==0) {
                continue ;
            }
            NSRange range = [str rangeOfString:@"-"];
            if (range.length>0) {
                NSArray* arr = [str componentsSeparatedByString:@"-"];
                if (arr.count==2) {
                    int number1 = [[arr objectAtIndex:0] intValue];
                    int number2 = [[arr objectAtIndex:1] intValue];
                    for (int i=number1; i<=number2; i++) {
                        [arrayOne addObject:@(i)];
                    }
                }
            } else {
                [arrayOne addObject:@([str intValue])];
            }
        }
        [mutableArray addObject:arrayOne];
    }
    return mutableArray;
}

@end
