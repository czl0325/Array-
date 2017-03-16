//
//  PINObject.h
//  Plum
//
//  Created by tpk on 14-11-17.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PINObject : NSObject

@property(nonatomic,assign)int ic;
@property(nonatomic,assign)int pin;
@property(nonatomic,assign)int upperLimit;
@property(nonatomic,assign)int lowerLimit;

@end
