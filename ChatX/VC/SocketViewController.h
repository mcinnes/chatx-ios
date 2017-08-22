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
#import "SocketIOPacket.h"
#import "IODProfanityFilter.h"
#import <ISMessages/ISMessages.h>
#import <Parse/Parse.h>
#import "Text-MessageObject.h"
#import "ContentView.h"
#import "ChatTableViewCellXIB.h"
#import "ChatCellSettings.h"
#import "ImageTableViewCell.h"
#import "ChatSettingsViewController.h"
#import "ImageQueryObject.h"
#import "TGRImageViewController.h"

@interface SocketViewController : ViewController <SocketIODelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, UITextViewDelegate>
{
    SocketIO *socketIO;
}
//@property (retain, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *tb;
@property (weak, nonatomic) NSString *roomNumber;

//Keyboard

@end
