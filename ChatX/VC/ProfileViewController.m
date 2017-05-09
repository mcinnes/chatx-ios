//
//  ProfileViewController.m
//  ChatX
//
//  Created by Matt McInnes on 2/5/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, _profilePicView.frame.size.width, _profilePicView.frame.size.height) cornerRadius:MAX(_profilePicView.frame.size.width, _profilePicView.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor blackColor].CGColor;
    circle.strokeColor = [UIColor blackColor].CGColor;
    circle.lineWidth = 0;
    _profilePicView.layer.mask=circle;
    
//    PFFile *imageFile = [[PFUser currentUser] objectForKey:@"profilePic"];
//    NSLog(@"%@", imageFile);
//    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//        if (!error) {
//            UIImage *image = [UIImage imageWithData:imageData];
//            self.profilePicView.image = image;
//        }}];
    self.profilePicView.image = [UIImage imageNamed:@"IMG_6168.JPG"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
