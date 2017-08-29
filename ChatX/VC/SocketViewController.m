//
//  SocketViewController.m
//  ChatX
//
//  Created by Matt McInnes on 27/3/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
// this file needs to be re-written as it is more of a POC than a finalised product

#import "SocketViewController.h"
#import "TGRImageZoomAnimationController.h"


@interface SocketViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBarButton;
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


@property (strong,nonatomic) ContentView *handler;

@end

@implementation SocketViewController {
    BOOL photoMessage;
    NSData *imageData;
    ChatCellSettings *chatCellSettings;
    ImageQueryObject *imageQuery;
    
    UIView *toolbar;
    UITextView *messageText;
    UIButton *postComment;
    UIButton *selectImage;

}


- (void)viewDidLoad {
   
    [super viewDidLoad];
    //self.yPositionStore = _tb.frame.origin.y;

    UIButton* infoButton = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem* itemAboutUs =[[UIBarButtonItem alloc]initWithCustomView:infoButton];


    [self.navigationItem setRightBarButtonItem:itemAboutUs animated:YES];

    //[_messageText setPlaceholder:@"Message..."];
    
    _conversationObjects = [NSMutableArray new];
    
    // create socket.io client instance
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    // connect to the socket.io server that is running locally at port 3000
    [socketIO connectToHost:@"10.140.38.172" onPort:3000];
    
    imageQuery = [ImageQueryObject new];
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

    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];

   
    toolbar = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    
    [toolbar setBackgroundColor:[UIColor whiteColor]];
    
    messageText = [[UITextView alloc]initWithFrame:CGRectMake(8, 8, self.view.frame.size.width - 16 - 75 - 75, 34)];
    [messageText setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1]];
    messageText.layer.cornerRadius = 5;
    [messageText setFont:[UIFont fontWithName:@"Avenir Next" size:20]];
    [messageText setTextColor:[UIColor colorWithWhite:0.35 alpha:1]];
    [messageText setDelegate:self];
    
    postComment = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-75 - 75, 0, 75, 50)];
    [postComment setTitle:@"Post" forState:UIControlStateNormal];
    [postComment.titleLabel setFont:[UIFont fontWithName:@"Avenir Next" size:20]];
    [postComment setTitleColor:[UIColor colorWithRed:(255/255.0) green:(40/255.0) blue:(80/255.0) alpha:1.0] forState:UIControlStateNormal];
    [postComment addTarget:self action:@selector(snemess:) forControlEvents:UIControlEventTouchUpInside];
    
    selectImage = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-75, 0, 75, 50)];
    [selectImage setTitle:@"📷" forState:UIControlStateNormal];
    [selectImage.titleLabel setFont:[UIFont fontWithName:@"Avenir Next" size:20]];
    [selectImage setTitleColor:[UIColor colorWithRed:(255/255.0) green:(40/255.0) blue:(80/255.0) alpha:1.0] forState:UIControlStateNormal];
    [selectImage addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolbar addSubview:messageText];
    [toolbar addSubview:postComment];
    [toolbar addSubview:selectImage];

    [[[UIApplication sharedApplication]delegate].window addSubview:toolbar];
    //[self.navigationController.view addSubview:toolbar];
    messageText.inputAccessoryView = toolbar;

    
}
-(void)viewWillDisappear:(BOOL)animated{
    [toolbar removeFromSuperview];
}
-(void)viewWillAppear:(BOOL)animated{
    [[[UIApplication sharedApplication]delegate].window addSubview:toolbar];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Keyboard/TextEntry
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:gestureRecognizer];
}
-(void)dismissKeyboard{
    [messageText resignFirstResponder];
}

#pragma mark Message Handling
-(void)downloadPreviousMessages{
    
    PFQuery *query1 = [PFQuery queryWithClassName:_roomNumber];
    [query1 addDescendingOrder:@"createdAt"];
    query1.limit = 20;
    
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
        
        for (PFObject *object in [messages reverseObjectEnumerator]) {
            if ([object[@"type"] isEqualToString:@"image"]){
                PFFile *imageFile = [object objectForKey:@"image"];
                NSURL *imageFileURL = [[NSURL alloc] initWithString:imageFile.url];
                NSData *imageData = [NSData dataWithContentsOfURL:imageFileURL];
                
                Text_MessageObject *messageObj = [[Text_MessageObject alloc]initMessageWithName:object[@"nickname"] message:nil time:nil type:object[@"type"] userId:object[@"userId"] image:[imageQuery downloadSingleImagewithID:object[@"image"]]];
                
                [self updateTableView:messageObj];
            } else {
                Text_MessageObject *messageObj = [[Text_MessageObject alloc]initMessageWithName:object[@"nickname"] message:object[@"msg"] time:nil type:object[@"type"] userId:object[@"userId"] image:nil];
                [self updateTableView:messageObj];
            }
        }
    }];
}

- (IBAction)snemess:(id)sender {
    
    if (photoMessage) {
        [self createImageMessage];
        photoMessage = nil;
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:messageText.text forKey:@"msg"];
        [dict setObject:[[PFUser currentUser]objectId] forKey:@"name"];
        [dict setObject:[PFUser currentUser][@"nickname"] forKey:@"nickname"];
        [dict setObject:[[PFUser currentUser] objectId] forKey:@"userId"];
        [dict setObject:_roomNumber forKey:@"roomNumber"];
        [dict setObject:@"text" forKey:@"type"];
        //send event is like emit
        [socketIO sendEvent:@"send" withData:dict];
    }
    messageText.text = nil;
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
        
        NSString *adString = [IODProfanityFilter stringByFilteringString:[NSString stringWithFormat:@"Advertisment:\n %@", tempDict[@"msg"]]];
        
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


#pragma mark Image Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    imageData = UIImagePNGRepresentation(chosenImage);
    
    //Placeholders
    //self.messageText.placeholder = @"Image Selected";
    postComment.titleLabel.text = @"Upload";
    //We are uploading a photo
    photoMessage = true;
    
    //Dismiss Picker
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[[UIApplication sharedApplication]delegate].window addSubview:toolbar];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
                    [dict setObject:[[PFUser currentUser] objectId] forKey:@"userId"];
                    [dict setObject:_roomNumber forKey:@"roomNumber"];
                    [dict setObject:@"image" forKey:@"type"];
                    
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
        
        
        NSLog(@"%d", percentDone);
        //[self.messageText :[NSString stringWithFormat:@"Sending %d%%",percentDone]];
    }];
    //messageText.placeholder = @"Message...";
    self.sendBarButton.title = @"Send";
    
}
- (IBAction)selectPhoto:(UIButton *)sender {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [toolbar removeFromSuperview];
        
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
                [toolbar removeFromSuperview];
                [self presentViewController:picker animated:YES completion:NULL];
                
            }
            
            else {
                // Access has been denied.
            }
        }];  
    }
    
}

#pragma mark TableView
-(void) updateTableView:(Text_MessageObject *)msg {
    [messageText setText:@""];
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
        
        //_imageCell.selectionStyle = UITableViewCellSelectionStyleNone;

        
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
        //_chatCell.selectionStyle = UITableViewCellSelectionStyleNone;

        //_chatCell.chatTimeLabel.text = message.userTime;
        //_chatCell.chatBackground.backgroundColor = [UIColor redColor];

        _chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser"];
        return _chatCell;

    }
    else if ([message.messageType isEqualToString:@"advertisment"])
    {
        _chatCell = (ChatTableViewCellXIB *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive"];
        
        _chatCell.chatMessageLabel.text = message.message;
        
        _chatCell.chatNameLabel.text = message.nickname;
        
        _chatCell.chatTimeLabel.text = message.time;
        
        _chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser"];
        
        _chatCell.chatBackgroundView.backgroundColor = [UIColor colorWithRed:0.96 green:0.68 blue:0.06 alpha:1.0];
        
        return _chatCell;
    }
    else
    {
        
        _chatCell = (ChatTableViewCellXIB *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive"];
        
        _chatCell.chatMessageLabel.text = message.message;
        
        _chatCell.chatNameLabel.text = message.nickname;
        
        _chatCell.chatTimeLabel.text = message.time;
        
        _chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser"];
        
       
        return _chatCell;

    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ImageTableViewCell class]]) {
        NSLog(@"Image hopefully %@", cell.class);
        Text_MessageObject *obj = _conversationObjects[indexPath.row];
        
        [self showImageViewerwithImage:obj.image];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    }else{
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];

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
        

    } else if (message.image){
        Messagesize.height = 132.0;
    }
        
    else {
        Messagesize = CGSizeMake(48, 40);
    }
    
    Timesize = [@"Time" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:fontArray[2]}
                                     context:nil].size;
    
    
    size.height = Messagesize.height + Namesize.height + Timesize.height + 48.0f;
    
    return size.height;
    //return 150.0f;
}

-(IBAction)showSettings:(id)sender{
    //NSLog(@"Modal");
    [toolbar removeFromSuperview];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Chat Room Settings"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Subscribe"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              bool update = [imageQuery subscribeToChatwithID:_roomNumber];
                                                              [[[UIApplication sharedApplication]delegate].window addSubview:toolbar];

                                                          }]; // 2
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Settings"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self performSegueWithIdentifier:@"settings" sender:self];
                                                               
                                                           }]; // 3
    
    [alert addAction:firstAction]; // 4
    [alert addAction:secondAction]; // 5
    
    [self presentViewController:alert animated:YES completion:nil]; // 6
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"settings"]) {
        ChatSettingsViewController *settingsVC = segue.destinationViewController;
        [settingsVC setChatID:_roomNumber];
    } else if ([segue.identifier isEqualToString:@"imagePopup"]) {
        
    }
    
}

- (IBAction)messageTextChanged:(id)sender {
    if (messageText.text.length >=1) {
        _sendBarButton.enabled = true;
    } else {
        _sendBarButton.enabled = false;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] init];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] init];
    }
    return nil;
}

- (void)showImageViewerwithImage:(UIImage *)selectedImage{
    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:selectedImage];
    // Don't forget to set ourselves as the transition delegate
    viewController.transitioningDelegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
