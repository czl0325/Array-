//
//  CSVObject.h
//  Plum
//
//  Created by tpk on 14-11-11.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSVObject : NSObject{
    NSString *m_CSVString;
    NSString *m_CSVName;
}

+ (CSVObject *)sharedManager;

- (void)createCSV:(NSString*)csvName withFront:(NSString*)csvTitle;
- (void)createCSVOnly:(NSString*)csvName;
- (NSString*)getCSVFileName;
- (NSString*)getCSVString;
- (void)setCSVString:(NSString*)str;
- (void)addString:(NSString*)str;
- (void)writeToCSV;
- (NSString*)readForCSV;

@end
