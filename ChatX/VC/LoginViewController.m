//
//  LoginViewController.m
//  ChatX
//
//  Created by Matt McInnes on 19/9/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-login.png"]];
    
    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-login"]];
    //self.logInView.logo.layer.cornerRadius = 7.0;
    //self.logInView.logo.clipsToBounds = YES;
    
    self.logInView.usernameField.placeholder = @"Username";
    self.logInView.passwordField.placeholder = @"Password";
    //self.logInView.logo = nil;
    self.logInView.signUpButton.backgroundColor = [UIColor colorWithRed:(21.0f/255.0f) green:(168.0f/255.0f) blue:(165.0f/255.0f) alpha:1.0f];
    self.logInView.facebookButton.backgroundColor = [UIColor colorWithRed:(60.0f/255.0f) green:(81.0f/255.0f) blue:(147.0f/255.0f) alpha:1.0f];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
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
