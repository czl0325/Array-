//
//  ChartWindowController.h
//  Plum
//
//  Created by tpk on 14-11-12.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

typedef enum {
    OLDMETHOD=1,
    SORTMETHOD,
}METHOD;

@interface ChartWindowController : NSWindowController
<CPTPlotDataSource, CPTAxisDelegate,
CPTPlotSpaceDelegate,CPTAnimationDelegate,
CPTBarPlotDelegate> {
    NSMutableArray* allArray;
    CPTXYGraph *lineGraph;
    NSArray* plotData;
    NSString* windowTitle;
    METHOD method;
    
    IBOutlet CPTGraphHostingView *lineHostView;
}

- (id)initWithX:(NSArray*)x withY:(NSArray*)y withTitle:(NSString*)title;
- (id)initWithArray:(NSArray*)array withTitle:(NSString*)title;

@end
