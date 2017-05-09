//
//  ChatSettingsViewController.m
//  ChatX
//
//  Created by Matt McInnes on 2/5/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "ChatSettingsViewController.h"
#import <Parse/Parse.h>

@interface ChatSettingsViewController ()
@end

@implementation ChatSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)subscribe:(id)sender {
    PFUser *me = [PFUser currentUser];
    me[@"currentChats"] = _chatID;
    [me saveInBackground];
}
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
