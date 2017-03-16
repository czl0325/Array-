//
//  ChartWindowController.m
//  Plum
//
//  Created by tpk on 14-11-12.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import "ChartWindowController.h"


@interface ChartWindowController ()

@end

@implementation ChartWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithX:(NSArray*)x withY:(NSArray*)y withTitle:(NSString*)title {
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if (self) {
        allArray = [NSMutableArray new];
        method = OLDMETHOD;
        for (int i=0; i<x.count; i++) {
            NSArray* oneX = [x objectAtIndex:i];
            NSArray* oneY = [y objectAtIndex:i];
            for (int j=0; j<oneX.count; j++) {
                NSDictionary* dicX = [oneX objectAtIndex:j];
                NSDictionary* dicY = [oneY objectAtIndex:j];
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:[dicX objectForKey:@"ic"], @"ic", [dicX objectForKey:@"pin"], @"pin", [dicX objectForKey:@"upperLimit"], @"upperLimit", [dicX objectForKey:@"lowerLimit"], @"lowerLimit", [dicY objectForKey:@"data"], @"data", nil];
                [allArray addObject:dic];
            }
        }
        windowTitle = title;
    }
    
    return self;
}

- (id)initWithArray:(NSArray*)array withTitle:(NSString*)title {
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if (self) {
        method = SORTMETHOD;
        allArray = [NSMutableArray arrayWithArray:array];
        [allArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary* d1 = (NSDictionary*)obj1;
            NSDictionary* d2 = (NSDictionary*)obj2;
            NSString* str1 = [d1 objectForKey:@"position"];
            NSString* str2 = [d2 objectForKey:@"position"];
            return ([str1 intValue]>[str2 intValue]);
        }];
        windowTitle = title;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self createPlot];
    [self.window setTitle:windowTitle?windowTitle:@"chart"];
}

- (void)createPlot {
    lineGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    CPTMutableTextStyle* graphTextStyle = [CPTMutableTextStyle textStyle];
    graphTextStyle.color = [CPTColor whiteColor];
    [lineGraph applyTheme:theme];
    lineGraph.title = @"IC PIN chart";
    lineGraph.titleTextStyle = graphTextStyle;
    lineHostView.hostedGraph = lineGraph;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)lineGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-1.0) length:CPTDecimalFromDouble(15.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-100.0) length:CPTDecimalFromDouble(1000.0)];
    
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = kCFNumberFormatterNoStyle;
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)lineGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy=CPTAxisLabelingPolicyNone;
    x.title = @"IC PIN";
    x.titleOffset = 20.0;
    x.majorIntervalLength = CPTDecimalFromFloat(1.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    x.minorTicksPerInterval = 0;
    x.labelFormatter=labelFormatter;
    
    // 设置X轴label
    NSMutableArray* xAxisLabels = [NSMutableArray new];
    for (int i=0; i<allArray.count; i++) {
        if (method == OLDMETHOD) {
            int pin = [[[allArray objectAtIndex:i] objectForKey:@"pin"]intValue];
            CPTAxisLabel *newLabel;
            newLabel=[[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"PIN%d",pin] textStyle:x.labelTextStyle];
            newLabel.tickLocation=[[NSNumber numberWithInt:i] decimalValue];
            newLabel.offset = 0.0f;
            [xAxisLabels addObject:newLabel];
        } else if (method == SORTMETHOD) {
            NSString* title = [[allArray objectAtIndex:i] objectForKey:@"title"];
            CPTAxisLabel *newLabel;
            newLabel=[[CPTAxisLabel alloc] initWithText:title textStyle:x.labelTextStyle];
            newLabel.tickLocation=[[NSNumber numberWithInt:i] decimalValue];
            newLabel.offset = 0.0f;
            [xAxisLabels addObject:newLabel];
        }
    }
    x.axisLabels =  [NSSet setWithArray:xAxisLabels];
    NSMutableArray *customTickLocations = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    for (NSUInteger i = 0; i < [xAxisLabels count]; i++) {
        [customTickLocations addObject:[NSNumber numberWithFloat:i]]; //设置x坐标
    }
    x.majorTickLocations = [NSSet setWithArray:customTickLocations];
    
    CPTXYAxis * y = axisSet.yAxis;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    y.majorIntervalLength = CPTDecimalFromFloat(100.0);
    y.minorTicksPerInterval = 10;
    y.labelFormatter = labelFormatter;
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"x Plot";
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle] ;
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource = self;
    [lineGraph addPlot:dataSourceLinePlot];
    
    // Add some data
    NSMutableArray *newData = [NSMutableArray array];
    for ( NSUInteger i = 0; i < allArray.count; i++ ) {
        NSNumber *x = @(i);
        NSNumber *y = [[allArray objectAtIndex:i] objectForKey:@"data"];
        [newData addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
    }
    plotData = newData;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = [[plotData objectAtIndex:index] valueForKey:key];
    return num;
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    NSNumber* num=[[plotData objectAtIndex:index] valueForKey:@"y"];
    CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%d", [num intValue]]];
    CPTMutableTextStyle *textStyle =[label.textStyle mutableCopy];
    NSDictionary* dic = [allArray objectAtIndex:index];
    if ([num intValue]>[[dic objectForKey:@"upperLimit"]intValue]||[num intValue]<[[dic objectForKey:@"lowerLimit"]intValue]) {
        textStyle.color = [CPTColor redColor];
    } else {
        textStyle.color = [CPTColor whiteColor];
    }
    label.textStyle = textStyle;
    return label ;
}


@end
