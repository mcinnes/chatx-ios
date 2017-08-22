//
//  ImageQueryObject.m
//  ChatX
//
//  Created by Matt McInnes on 22/8/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "ImageQueryObject.h"
#import <Parse/Parse.h>

@implementation ImageQueryObject

-(UIImage *)downloadSingleImagewithID:(NSString *)imageID{
    __block UIImage* returnImage;
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"images"];
    
    [query1 getObjectInBackgroundWithId:imageID block:^(PFObject *imageObject, NSError *error) {
        
        PFFile *imageFile = imageObject[@"image"];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!data) {
                return NSLog(@"%@", error);
            }
            UIImage *downloadedImage = [UIImage imageWithData:data];
            
            returnImage = downloadedImage;
            
        }];
        
    }];;
    return returnImage;
}

@end
