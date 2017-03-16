//
//  ICObject.h
//  Plum
//
//  Created by tpk on 14-11-10.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICObject : NSObject

@property(nonatomic,strong)NSString* productName;
@property(nonatomic,assign)int row;
@property(nonatomic,assign)int column;
@property(nonatomic,assign)int upperLimit;
@property(nonatomic,assign)int lowerLimit;
@property(nonatomic,strong)NSMutableArray* arrayICPin;
@property(nonatomic,strong)NSString* strICPin;
@property(nonatomic,assign)int pinRow;
@property(nonatomic,assign)int pinColumn;

+ (NSMutableArray*)changeToDataArray:(NSString*)textString;

@end
