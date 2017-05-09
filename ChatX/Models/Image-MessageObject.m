//
//  Image-MessageObject.m
//  ChatX
//
//  Created by Matt McInnes on 20/4/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "Image-MessageObject.h"

@implementation Image_MessageObject

@synthesize image = _image;
@synthesize nickname = _nickname;
@synthesize userId = _userId;
@synthesize messageType = _messageType;


-(id) initMessageWithName:(NSString *)name
                  image:(NSData *)image
                     time:(NSString *)time
                     type:(NSString *)type
                   userId:(NSString *)userId
{
    self = [super init];
    if(self)
    {
        self.nickname = name;
        self.image = image;
        //self.userTime = time;
        self.messageType = type;
        self.userId = userId;
    }
    
    return self;
}
@end
