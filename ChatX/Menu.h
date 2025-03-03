//
//  Menu.h
//  Storyboard
//
//Just updated MainViewController and DrawerTableViewController (both programmed in Swift)
//to objectiveC version (MainViewControllerObjc and Menu), this way will be easier to implement on Objective-c Projects.
//
//  Created by Daniel Rosero on 22/01/16.
//  Copyright © 2016 Kyohei Yamaguchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationController.h"

@interface Menu : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NavigationController *navController;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
