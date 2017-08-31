//
//  NavigationController.h
//  ChatX
//
//  Created by Matt McInnes on 29/8/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse.h>

@interface NavigationController : UINavigationController
@property (weak, nonatomic) PFObject *chatObject;
@end
