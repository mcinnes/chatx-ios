//
//  CardCell.h
//  LocalEtivity
//
//  Created by Matt on 2/03/2017.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageLabel;

@end
