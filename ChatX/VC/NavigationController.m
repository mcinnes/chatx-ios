//
//  NavigationController.m
//  ChatX
//
//  Created by Matt McInnes on 29/8/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "NavigationController.h"
#import "SocketViewController.h"
@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *barColour = [UIColor colorWithRed:(67/255.0) green:(67/255.0) blue:(67/255.0) alpha:1.0];
    
    [[UINavigationBar appearance] setBarTintColor:barColour];

    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIColor *greenTintColour = [UIColor colorWithRed:(21/255.0) green:(168/255.0) blue:(165/255.0) alpha:1.0];
    [[UINavigationBar appearance] setTintColor:greenTintColour];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
}
@end
