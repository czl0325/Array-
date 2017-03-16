//
//  CSVObject.m
//  Plum
//
//  Created by tpk on 14-11-11.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "CSVObject.h"

@implementation CSVObject

static CSVObject *_sharedManager = nil;

+(CSVObject *)sharedManager {
    @synchronized( [CSVObject class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized ([CSVObject class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)createCSV:(NSString*)csvName withFront:(NSString*)csvTitle {
    m_CSVName = @"";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString* path = [documentDir stringByAppendingPathComponent:@"plum"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:@"csv"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    m_CSVName = [path stringByAppendingPathComponent:csvName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:m_CSVName]) {
        FILE* file = fopen([m_CSVName cStringUsingEncoding:NSASCIIStringEncoding], "wt+");
        char title[500];
        memset(title, 0x00, sizeof(title));
        sprintf(title, "%s\n",[csvTitle UTF8String]);
        fputs(title, file);
        fclose(file);
    }
}

- (void)createCSVOnly:(NSString*)csvName {
    m_CSVName = @"";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString* path = [documentDir stringByAppendingPathComponent:@"plum"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:@"csv"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    m_CSVName = [path stringByAppendingPathComponent:csvName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:m_CSVName]) {
        [[NSFileManager defaultManager] createFileAtPath:m_CSVName contents:nil attributes:nil];
    }
}

- (NSString*)getCSVFileName {
    return m_CSVName;
}

- (NSString*)getCSVString {
    return m_CSVString;
}

- (void)setCSVString:(NSString*)str {
    m_CSVString = str;
}

- (void)addString:(NSString*)str {
    m_CSVString = [m_CSVString stringByAppendingString:str];
}

- (void)writeToCSV {
    FILE* file = fopen([m_CSVName cStringUsingEncoding:NSASCIIStringEncoding], "at+");
    if (file) {
        fputs([m_CSVString cStringUsingEncoding:NSASCIIStringEncoding], file);
        fclose(file);
    }
}

- (NSString*)readForCSV {
    return [NSString stringWithContentsOfFile:m_CSVName encoding:NSUTF8StringEncoding error:nil];
}

@end
