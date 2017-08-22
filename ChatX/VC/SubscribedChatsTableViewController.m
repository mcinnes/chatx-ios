//
//  SubscribedChatsTableViewController.m
//  ChatX
//
//  Created by Matt McInnes on 22/8/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "SubscribedChatsTableViewController.h"
#import <Parse/Parse.h>

@interface SubscribedChatsTableViewController ()

@end

@implementation SubscribedChatsTableViewController {
    NSArray *subscribedChatIDArray;
    NSMutableArray *chatNamesArray;
    NSMutableArray *currentCountsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    subscribedChatIDArray = [NSArray new];
    chatNamesArray = [NSMutableArray new];
    currentCountsArray = [NSMutableArray new];
    
    NSString *idString = [PFUser currentUser][@"subscribedChats"];
    NSLog(@"%@", idString);
    subscribedChatIDArray = [idString componentsSeparatedByString:@","];

    for (NSString *ids in subscribedChatIDArray){
        PFQuery *chatDetailsQuery = [PFQuery queryWithClassName:@"currentChats"];
        
        [chatDetailsQuery getObjectInBackgroundWithId:ids block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (!error) {
                [chatNamesArray addObject:object[@"name"]];
                [currentCountsArray addObject:object[@"currentCount"]];
            }
        }];
    }
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return subscribedChatIDArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basiccell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = chatNamesArray[indexPath.row];
    cell.detailTextLabel.text = currentCountsArray[indexPath.row];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
