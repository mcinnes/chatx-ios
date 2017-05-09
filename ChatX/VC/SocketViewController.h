//
//  SocketViewController.h
//  ChatX
//
//  Created by Matt McInnes on 27/3/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "ViewController.h"
#import "SocketIO.h"
#import <Photos/Photos.h>

@interface SocketViewController : ViewController <SocketIODelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    SocketIO *socketIO;
}
@property (retain, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *tb;
@property (weak, nonatomic) NSString *roomNumber;


@end
