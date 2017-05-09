//
//  ViewController.m
//  ChatX
//
//  Created by Matt McInnes on 25/3/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "KYDrawerController.h"

@interface ViewController () <PFLogInViewControllerDelegate>

@end

@implementation ViewController {
    UIView *rootView;
    EAIntroView *_intro;

}
- (void)viewDidLoad {
    [super viewDidLoad];
//
    if (![PFUser currentUser]) {
        PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
        logInController.delegate = self;
        logInController.logInView.logo = nil;
        logInController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;
        
        [self presentViewController:logInController animated:true completion:nil];
    }
    
   
//
    // Do any additional setup after loading the view, typically from a nib.
}
-(IBAction)openMenu:(id)sender{
    
    KYDrawerController *elDrawer = (KYDrawerController*)self.navigationController.parentViewController;
    [elDrawer setDrawerState:KYDrawerControllerDrawerStateOpened animated:YES];
    
    
}
#pragma mark login delegates
- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)introDidFinish:(EAIntroView *)introView wasSkipped:(BOOL)wasSkipped {
    if(wasSkipped) {
        NSLog(@"Intro skipped");
    } else {
        NSLog(@"Intro finished");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
