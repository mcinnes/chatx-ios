//
//  Text-MessageObject.m
//  ChatX
//
//  Created by Matt McInnes on 5/4/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "Text-MessageObject.h"

@implementation Text_MessageObject

@synthesize message = _message;
@synthesize nickname = _nickname;
@synthesize userId = _userId;
@synthesize messageType = _messageType;


-(id) initMessageWithName:(NSString *)name
                   message:(NSString *)message
                      time:(NSString *)time
                      type:(NSString *)type
                    userId:(NSString *)userId
{
    self = [super init];
    if(self)
    {
        self.nickname = name;
        self.message = message;
        //self.userTime = time;
        self.messageType = type;
        self.userId = userId;
    }
    
    return self;
}
@end
