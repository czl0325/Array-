//
//  PasswordWindowController.h
//  Margaux-OQC
//
//  Created by tpk on 14-12-2.
//  Copyright (c) 2014年 tpk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyBoardTextField.h"

//输入密码页面

@interface PasswordWindowController : NSWindowController {
    IBOutlet NSSecureTextField* textPassword;   //密码输入控件
}

@end
