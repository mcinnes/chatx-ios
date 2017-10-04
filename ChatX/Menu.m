//
//  Menu.m
//  Storyboard
//
//  Created by Daniel Rosero on 22/01/16.
//  Copyright © 2016 Kyohei Yamaguchi. All rights reserved.
//

#import "Menu.h"
//#import "MainViewControllerObjc.h"
//#import "Storyboard-Swift.h"
#import "KYDrawerController.h"
#import "CardCell.h"
#import <Parse/Parse.h>
@implementation Menu

-(void)viewDidLoad{
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, _profileImageView.frame.size.width, _profileImageView.frame.size.height) cornerRadius:MAX(_profileImageView.frame.size.width, _profileImageView.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor blackColor].CGColor;
    circle.strokeColor = [UIColor blackColor].CGColor;
    circle.lineWidth = 0;
    _profileImageView.layer.mask=circle;
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    if ([PFUser currentUser]) {
        [_logoutLabel setText:@"Logout"];
        [_nameLabel setText:[PFUser currentUser][@"name"]];
    } else {
        [_logoutLabel setText:@"Login"];
        [_nameLabel setText:@"Welcome..."];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath{
    [tableView deselectRowAtIndexPath:newIndexPath animated:YES];
    KYDrawerController *elDrawer = (KYDrawerController*)self.navigationController.parentViewController;
    
    
    //Case statement here to switch the things
    
     //elDrawer.mainViewController=navController;
    [elDrawer setDrawerState:KYDrawerControllerDrawerStateClosed animated:YES];
    
    switch (newIndexPath.row) {
        case 0:
            [elDrawer.mainViewController performSegueWithIdentifier:@"profileMenu" sender:self];
        case 8:
            if ([PFUser currentUser]) {
                [PFUser logOut];
                
            } else {
                //[PFUser logInWithUsername:@"matt" password:@"indiana1"];
                [elDrawer.mainViewController performSegueWithIdentifier:@"loginMenu" sender:self];

            }
            
            break;
            
        default:
            break;
    }
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //CardCell *cell = (CardCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//  
//    
//    static NSString *identifier = @"CardCell";
//    
//    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    
//    if (!cell) {
//        cell = [[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
//
//    cell.messageLabel.text = [NSString stringWithFormat:@"Welcome back, %@", [[PFUser currentUser]objectId]];
//        //NSLog(@"%@", [[PFUser currentUser]objectId]);
//    return cell;
//    
//}
@end
