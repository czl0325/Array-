//
//  PinSetWindowController.h
//  Plum
//
//  Created by tpk on 14-11-17.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PINObject.h"

@interface PinSetWindowController : NSWindowController
<NSAnimationDelegate, NSWindowDelegate>{
    IBOutlet NSTextField* textUpperLimit;
    IBOutlet NSTextField* textLowerLimit;
    PINObject* m_pinObject;
}

- (id)initWithPinObject:(PINObject*)obj;

@end
