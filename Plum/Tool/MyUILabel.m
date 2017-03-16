//
//  MyUILabel.m
//  KingCrab
//
//  Created by tpk on 14-10-24.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "MyUILabel.h"

@implementation MyUILabel

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSMutableDictionary *titleAttributes = [[NSMutableDictionary alloc] init];
    [titleAttributes setValue:self.font forKeyPath:NSFontAttributeName];
    NSSize titleSize = [self.stringValue sizeWithAttributes:titleAttributes];
    CGFloat verticalPoint = ([self bounds].size.height / 2) - (titleSize.height / 2);
    CGFloat horizontalPoint = ([self bounds].size.width / 2) - (titleSize.width / 2);
    [self.stringValue drawAtPoint:NSMakePoint(horizontalPoint, verticalPoint) withAttributes:titleAttributes];
}

@end
