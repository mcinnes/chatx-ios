//
//  SocketViewController.m
//  ChatX
//
//  Created by Matt McInnes on 27/3/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
// this file needs to be re-written as it is more of a POC than a finalised product

#import "SocketViewController.h"
#import "SocketIOPacket.h"
#import "IODProfanityFilter.h"
#import <ISMessages/ISMessages.h>
#import <Parse/Parse.h>
#import "Text-MessageObject.h"
#import "ContentView.h"
#import "ChatTableViewCellXIB.h"
#import "ChatCellSettings.h"
//#import "Image-MessageObject.h"
#import "ImageTableViewCell.h"
#import "ChatSettingsViewController.h"

@interface SocketViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (strong, nonatomic) NSString *selectedImage;
@property (strong, nonatomic) NSMutableArray *conversationObjects;

//Chat Cell
@property (weak, nonatomic) IBOutlet ContentView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;

@property (strong,nonatomic) ChatTableViewCellXIB *chatCell;
@property (strong,nonatomic) ImageTableViewCell *imageCell;

//@property (strong,nonatomic) ChatTableViewCellXIB *chatCell;


@property (strong,nonatomic) ContentView *handler;

@end

@implementation SocketViewController {
    BOOL photoMessage;
    NSData *imageData;
    ChatCellSettings *chatCellSettings;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.yPositionStore = _tb.frame.origin.y;

    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [modalButton setTarget:self];
    [modalButton setAction:@selector(showSettings:)];
    
    [self.navigationItem setRightBarButtonItem:modalButton animated:YES];

    _conversationObjects = [NSMutableArray new];
    // Do any additional setup after loading the view.
    
    // create socket.io client instance
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    // connect to the socket.io server that is running locally at port 3000
    [socketIO connectToHost:@"59.191.208.17" onPort:3000];
    
    [self downloadPreviousMessages];
    
    chatCellSettings = [ChatCellSettings getInstance];

    UINib *nib = [UINib nibWithNibName:@"ChatSendCell" bundle:nil];
     
     [[self tableView] registerNib:nib forCellReuseIdentifier:@"chatSend"];
     
     nib = [UINib nibWithNibName:@"ChatReceiveCell" bundle:nil];
     
     [[self tableView] registerNib:nib forCellReuseIdentifier:@"chatReceive"];
    
    nib = [UINib nibWithNibName:@"ImageReceiveCell" bundle:nil];
    
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"imageReceive"];

    
    //Instantiating custom view that adjusts itself to keyboard show/hide
    self.handler = [[ContentView alloc] initWithTextView:self.chatTextView ChatTextViewHeightConstraint:self.chatTextViewHeightConstraint contentView:self.contentView ContentViewHeightConstraint:self.contentViewHeightConstraint andContentViewBottomConstraint:self.contentViewBottomConstraint];
    
    //Setting the minimum and maximum number of lines for the textview vertical expansion
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:3];
    
    //Pin toolbar hopefully

    
    //Tap gesture on table view so that when someone taps on it, the keyboard is hidden
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.tableView addGestureRecognizer:gestureRecognizer];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
}
- (void) dismissKeyboard
{
    [self.messageText resignFirstResponder];
}

-(void)downloadPreviousMessages{
    
    PFQuery *query1 = [PFQuery queryWithClassName:_roomNumber];
    [query1 addDescendingOrder:@"createdAt"];
    query1.limit = 20;
    
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
        
        for (PFObject *object in [messages reverseObjectEnumerator]) {
            //_textView.text = [_textView.text stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n\n", object[@"nickname"], object[@"msg"]]];
            
            Text_MessageObject *messageObj = [[Text_MessageObject alloc]initMessageWithName:object[@"nickname"] message:object[@"msg"] time:nil type:@"text" userId:object[@"userId"] image:NULL];
            [self updateTableView:messageObj];
            
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectPhoto:(UIButton *)sender {
    
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];

    }
    
    else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
    }
    
    else if (status == PHAuthorizationStatusNotDetermined) {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:picker animated:YES completion:NULL];

            }
            
            else {
                // Access has been denied.
            }
        }];  
    }
    
}

-(void) updateTableView:(Text_MessageObject *)msg {
    [self.messageText setText:@""];
    //[self.handler textViewDidChange:self.messageText];
    
    [self.tableView beginUpdates];
    
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:_conversationObjects.count inSection:0];
    
    [_conversationObjects insertObject:msg atIndex:_conversationObjects.count];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1, nil] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.tableView endUpdates];
    
    //Always scroll the chat table when the user sends the message
    if([self.tableView numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }
}

- (IBAction)snemess:(id)sender {
    
    NSLog(@"Current User: %@",[PFUser currentUser]);
   
    if (photoMessage) {
        [self createImageMessage];
        photoMessage = nil;
    } else {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.messageText.text forKey:@"msg"];
        [dict setObject:[[PFUser currentUser]objectId] forKey:@"name"];
        [dict setObject:[PFUser currentUser][@"nickname"] forKey:@"nickname"];
        [dict setObject:[[PFUser currentUser] objectId] forKey:@"userId"];
        [dict setObject:_roomNumber forKey:@"roomNumber"];

        //send event is like emit
        [socketIO sendEvent:@"send" withData:dict];
    }
    
    self.messageText.text = nil;

}

-(void)createImageMessage{
    
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    // Save the image to Parse
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The image has now been uploaded to Parse. Associate it with a new object
            PFObject* newPhotoObject = [PFObject objectWithClassName:@"images"];
            [newPhotoObject setObject:imageFile forKey:@"image"];
            [newPhotoObject setObject:[[PFUser currentUser]objectId] forKey:@"userID"];
            
            [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Saved: %@", [newPhotoObject objectId]);
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

                    [dict setObject:[[PFUser currentUser]objectId] forKey:@"name"];
                    [dict setObject:[newPhotoObject objectId] forKey:@"image"];
                    [dict setObject:[PFUser currentUser][@"nickname"] forKey:@"nickname"];

                    //send event is like emit
                    [socketIO sendEvent:@"image" withData:dict];
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }progressBlock:^(int percentDone) {
        UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 50)];
        [paintView setBackgroundColor:[UIColor yellowColor]];
        UIProgressView *progressView = [[UIProgressView alloc] init];
        progressView.frame = CGRectMake(0,0,self.view.frame.size.width,30);
        [paintView addSubview:progressView];
        
        [self.view addSubview:paintView];
        progressView.progress = (float)percentDone;
        NSLog(@"%d", percentDone);
    }];

    
}

# pragma mark socket.IO-objc delegate methods

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveMessage >>> data: %@", packet);
    
    NSString *filtered = [IODProfanityFilter stringByFilteringString:packet.data]; // @"a great ∗∗∗∗∗∗∗ example string"

    _textView.text = [_textView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n\n", filtered]];
}

- (void) socketIODidConnect:(SocketIO *)socket
{

    NSString *sessionToken = [[PFUser currentUser]sessionToken];

    NSLog(@"socket.io connected.");
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"Matt" forKey:@"name"];
    [dict setObject:_roomNumber forKey:@"roomNumber"];
    //[dict setObject:sessionToken forKey:@"session-token"];
    //[dict setObject@"userID" forKey[[pfuser currentUser]objectID]];
    [socketIO sendEvent:@"join" withData:dict];

}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *tempDict = [packet.args objectAtIndex:0];
 

    if ([packet.name isEqualToString:@"update"]){
        //_textView.text = [_textView.text stringByAppendingString:[NSString stringWithFormat:@"Server-Update: %@\n\n", [packet.args objectAtIndex:0]]];
    }
    else if ([packet.name isEqualToString:@"join"]){
        
        [ISMessages showCardAlertWithTitle:@"Connected"
                                   message:@"Successfully connected to chat"
                                  duration:3.f
                               hideOnSwipe:YES
                                 hideOnTap:YES
                                 alertType:ISAlertTypeSuccess
                             alertPosition:ISAlertPositionTop
                                   didHide:^(BOOL finished) {
                                       NSLog(@"Alert did hide.");
                                   }];
        
    }
    else if ([packet.name isEqualToString:@"image"]){
        
        PFQuery *query1 = [PFQuery queryWithClassName:@"images"];
        
        [query1 getObjectInBackgroundWithId:tempDict[@"image"] block:^(PFObject *imageObject, NSError *error) {
            
            PFFile *imageFile = imageObject[@"image"];
            
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!data) {
                    return NSLog(@"%@", error);
                }
                NSLog(@"Image Downloaded");
                UIImage *demoImage = [UIImage imageWithData:data];
                
                Text_MessageObject *messageObj = [[Text_MessageObject alloc]initMessageWithName:tempDict[@"nickname"] message:nil time:nil type:@"image" userId:nil image:demoImage];
                //NSLog(@"%@", data);
                
                [self updateTableView:messageObj];

            }];
            
        }];;
        
    }
    else if ([packet.name isEqualToString:@"advertisment"]){
        
        NSString *adString = [IODProfanityFilter stringByFilteringString:[NSString stringWithFormat:@"Advertisment:\n %@\n\n", tempDict[@"msg"]]];
        
        Text_MessageObject *messageObj = [[Text_MessageObject alloc]initMessageWithName:tempDict[@"source"] message:adString time:nil type:@"advertisment" userId:tempDict[@"userId"] image:NULL];

        
        //[_conversationObjects addObject:messageObj];
        
        [self updateTableView:messageObj];
        
        //callback to server
         [PFCloud callFunctionInBackground:@"advertismentCallback"
                            withParameters:@{@"adID":@"demoID", @"userID":[[PFUser currentUser]objectId]}
                                    block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"%@", success);
                                    }
         }];
        


    }
    else if ([packet.name isEqualToString:@"chat"]){
        NSLog(@"tempdict: %@", tempDict);
        NSString *msg = [IODProfanityFilter stringByFilteringString:tempDict[@"msg"]];
        
        Text_MessageObject *messageObj = [[Text_MessageObject alloc]initMessageWithName:tempDict[@"nickname"] message:msg time:tempDict[@"createdAt"] type:@"text" userId:tempDict[@"userId"] image:NULL];
        
       
        
        //[_conversationObjects addObject:messageObj];
        
        [self updateTableView:messageObj];

        
    } else {
        
        //_textView.text = [_textView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n\n", packet.name]];

    }
    NSLog(@"didReceiveEvent(%ld)", _conversationObjects.count);
    [self.tableView reloadData];

}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    if ([error code] == SocketIOUnauthorized) {
        NSLog(@"not authorized");
    } else {
        NSLog(@"onError() %@", error);
        
        [ISMessages showCardAlertWithTitle:@"Could not connect to server"
                                   message:@""
                                  duration:3.f
                               hideOnSwipe:YES
                                 hideOnTap:YES
                                 alertType:ISAlertTypeError
                             alertPosition:ISAlertPositionTop
                                   didHide:^(BOOL finished) {
                                       NSLog(@"Alert did hide.");
                                   }];
    }
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
    [ISMessages showCardAlertWithTitle:@"Lost connection to server"
                               message:@""
                              duration:3.f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeWarning
                         alertPosition:ISAlertPositionTop
                               didHide:^(BOOL finished) {
                                   NSLog(@"Alert did hide.");
                               }];
}
- (IBAction)removeFromSuper:(id)sender {
  //  [_tb removeFromSuperview];
    //self.messageText.inputAccessoryView = _tb;

}
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect newFrame = _tb.frame;
    newFrame.origin.y = [UIScreen mainScreen].bounds.size.height - kbSize.height - newFrame.size.height;
    _tb.frame = newFrame;
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGRect newFrame = _tb.frame;
    //newFrame.origin.y = self.yPositionStore;
   // self.toolBar.frame = newFrame;
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    imageData = UIImagePNGRepresentation(chosenImage);
    photoMessage = true;
    
    //NSLog(@"%@", _selectedImage);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _conversationObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    Text_MessageObject *message = [_conversationObjects objectAtIndex:indexPath.row];
    
    if ([message.messageType isEqualToString:@"image"]){
        

        _imageCell = (ImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"imageReceive"];
        
        _imageCell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        _imageCell.messageImage.image = message.image;
        _imageCell.chatNameLabel.text = message.nickname;
        //_chatCell.chatTimeLabel.text = message.userTime;
        
        //_imageCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser"];
        return _imageCell;
        
    }
    else if([message.userId isEqualToString:[[PFUser currentUser]objectId]])
    {
       
        _chatCell = (ChatTableViewCellXIB *)[tableView dequeueReusableCellWithIdentifier:@"chatSend"];
        
        _chatCell.chatMessageLabel.text = message.message;
        
        _chatCell.chatNameLabel.text = message.nickname;
        _chatCell.selectionStyle = UITableViewCellSelectionStyleNone;

        //_chatCell.chatTimeLabel.text = message.userTime;
        //_chatCell.chatBackground.backgroundColor = [UIColor redColor];

        _chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser"];
        return _chatCell;

    }
    else
    {
        /*Uncomment second line and comment first to use XIB instead of code*/
        //_chatCell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive"];
        
        _chatCell = (ChatTableViewCellXIB *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive"];
        
        _chatCell.chatMessageLabel.text = message.message;
        
        _chatCell.chatNameLabel.text = message.nickname;
        
        _chatCell.chatTimeLabel.text = message.time;
        
        _chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser"];
        
        if ([message.messageType isEqualToString:@"advertisment"]) {
#warning To Fix Background
            //_chatCell.chatBackground.backgroundColor = [UIColor redColor];
        }
        return _chatCell;

        /*Comment this line is you are using XIB*/
        //_chatCell.authorType = iMessageBubbleTableViewCellAuthorTypeReceiver;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Text_MessageObject *message = [_conversationObjects objectAtIndex:indexPath.row];
    
    CGSize size;
    
    CGSize Namesize;
    CGSize Timesize;
    CGSize Messagesize;
    
    NSArray *fontArray = [[NSArray alloc] init];
    
    //Get the chal cell font settings. This is to correctly find out the height of each of the cell according to the text written in those cells which change according to their fonts and sizes.
    //If you want to keep the same font sizes for both sender and receiver cells then remove this code and manually enter the font name with size in Namesize, Messagesize and Timesize.
    if([message.messageType isEqualToString:@"self"])
    {
        fontArray = chatCellSettings.getSenderBubbleFontWithSize;
    }
    else
    {
        fontArray = chatCellSettings.getReceiverBubbleFontWithSize;
    }
    
    //Find the required cell height
    Namesize = [@"Name" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:fontArray[0]}
                                     context:nil].size;
    
    
    if (message.message) {
        Messagesize = [message.message boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:fontArray[1]}
                                                    context:nil].size;
        

    } else {
        Messagesize = CGSizeMake(48, 40);
    }
    
    Timesize = [@"Time" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:fontArray[2]}
                                     context:nil].size;
    
    
    size.height = Messagesize.height + Namesize.height + Timesize.height + 48.0f;
    
    //return size.height;
    return 150.0f;
}

-(IBAction)showSettings:(id)sender{
    NSLog(@"Modal");
    
    [self performSegueWithIdentifier:@"settings" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"settings"]) {
        ChatSettingsViewController *settingsVC = segue.destinationViewController;
        [settingsVC setChatID:_roomNumber];
    }
}


@end
