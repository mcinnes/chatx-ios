//
//  ImageQueryObject.h
//  ChatX
//
//  Created by Matt McInnes on 22/8/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ImageQueryObject : NSObject

-(UIImage *)downloadSingleImagewithID:(NSString *)imageID;

@end
