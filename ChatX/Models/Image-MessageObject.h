//
//  Image-MessageObject.h
//  ChatX
//
//  Created by Matt McInnes on 20/4/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Text-MessageObject.h"
@interface Image_MessageObject : Text_MessageObject

@property (strong, nonatomic) NSData *image;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *messageType;

-(id) initMessageWithName:(NSString *)name
                  image:(NSData *)image
                     time:(NSString *)time
                     type:(NSString *)type
                   userId:(NSString *)userId;

@end
