//
//  ImageTableViewCell.h
//  ChatX
//
//  Created by Matt McInnes on 8/8/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *chatNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messageImage;

@end
