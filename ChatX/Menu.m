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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath{
    [tableView deselectRowAtIndexPath:newIndexPath animated:YES];
    
    KYDrawerController *elDrawer = (KYDrawerController*)self.navigationController.parentViewController;
    
    
     //elDrawer.mainViewController=navController;
    [elDrawer setDrawerState:KYDrawerControllerDrawerStateClosed animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CardCell *cell = (CardCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
  
    
    static NSString *identifier = @"CardCell";
    
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.messageLabel.text = [NSString stringWithFormat:@"Welcome back, %@", [[PFUser currentUser]objectId]];
//NSLog(@"%@", [[PFUser currentUser]objectId]);
    return cell;
}
@end
