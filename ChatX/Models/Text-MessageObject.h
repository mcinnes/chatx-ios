//
//  Text-MessageObject.h
//  ChatX
//
//  Created by Matt McInnes on 5/4/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Text_MessageObject : NSObject {
    
}

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *messageType;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) UIImage *image;


-(id) initMessageWithName:(NSString *)name
                   message:(NSString *)message
                      time:(NSString *)time
                      type:(NSString *)type
                   userId:(NSString *)userId
                    image:(UIImage *)image;
@end
