//
//  CreateChatViewController.m
//  ChatX
//
//  Created by Matt McInnes on 2/5/17.
//  Copyright © 2017 Matt McInnes. All rights reserved.
//

#import "CreateChatViewController.h"
#import <Parse/Parse.h>
#import <RKTagsView.h>
#import "RKCustomButton.h"
#import <GooglePlaces/GooglePlaces.h>
@interface CreateChatViewController () <UITextFieldDelegate, RKTagsViewDelegate>

@property (weak, nonatomic) IBOutlet RKTagsView *tagsView;

@end

@implementation CreateChatViewController {
    CLLocationManager *locationManager;
    CLLocation *location;
    GMSPlacesClient *_placesClient;

    __weak IBOutlet UIImageView *imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tagsView.textField.placeholder = @"Add tag...";
    self.tagsView.textField.returnKeyType = UIReturnKeyDone;
    self.tagsView.textField.delegate = self;
    
    locationManager = [[CLLocationManager alloc] init];
    
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    location = [locationManager location];
    
    _placesClient = [GMSPlacesClient sharedClient];

    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        //for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            GMSPlaceLikelihood *likelihood = likelihoodList.likelihoods[0];
            GMSPlace* place = likelihood.place;
            NSLog(@"Current Place name %@ at likelihood %g", place.name, likelihood.likelihood);
            NSLog(@"Current Place address %@", place.formattedAddress);
            NSLog(@"Current Place attributions %@", place.attributions);
            NSLog(@"Current PlaceID %@", place.placeID);
            _nameTextField.text = [NSString stringWithFormat:@"%@ Chat", place.name];
       // }
        
        
        [_placesClient lookUpPhotosForPlaceID:place.placeID callback:^(GMSPlacePhotoMetadataList *_Nullable photos ,NSError *_Nullable error) {
            NSLog(@"Res: %@", photos.results);
            if (error) {
                 // TODO: handle the error.
                 NSLog(@"Error: %@", [error description]);
             } else {
                 if (photos.results.count > 0) {
                     GMSPlacePhotoMetadata *firstPhoto = photos.results.firstObject;
                     NSLog(@"Photos.Results: %@", photos.results);
                     [self loadImageForMetadata:firstPhoto];
                 }
             }
         }];
    }];
    
   
    
    _locationLabel.text = [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude];
    // Do any additional setup after loading the view.
}

- (void)loadImageForMetadata:(GMSPlacePhotoMetadata *)photoMetadata {
   [_placesClient loadPlacePhoto:photoMetadata
     constrainedToSize:imageView.bounds.size
     scale:imageView.window.screen.scale
     callback:^(UIImage *_Nullable photo, NSError *_Nullable error) {
         if (error) {
             // TODO: handle the error.
             NSLog(@"Error: %@", [error description]);
         } else {
             imageView.image = photo;
             //self.attributionTextView.attributedText = photoMetadata.attributions;
         }
     }];
}

-(IBAction)create:(id)sender{
    
    NSString *combined = [self.tagsView.tags componentsJoinedByString:@","];
    
    PFGeoPoint *locationGeo = [PFGeoPoint geoPointWithLocation:location];
    
    NSString *chatIDString = [self genRandStringLength:15];
    
    PFObject *chatObject = [PFObject objectWithClassName:@"CurrentChats"];
    
    chatObject[@"ChatName"] = _nameTextField.text;
    
    chatObject[@"ChatRoomID"] = chatIDString;
    
    chatObject[@"description"] = _descriptionTextField.text;

    chatObject[@"userId"] = [[PFUser currentUser]objectId];

    chatObject[@"location"] = locationGeo;
    
    chatObject[@"tags"] = combined;
    
    [chatObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description
        }
    }];
    
    PFObject *firstMessageObject = [PFObject objectWithClassName:chatIDString];
    
    firstMessageObject[@"nickname"] = @"ChatX";
    firstMessageObject[@"msg"] = [NSString stringWithFormat:@"Welcome to the %@ chat", _nameTextField.text];
    [firstMessageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description
        }
    }];
    
}

//NSArray* tempVCA = [self.navigationController viewControllers];
//
//for(UIViewController *tempVC in tempVCA)
//{
//    if([tempVC isKindOfClass:[CreateChatViewController class]])
//    {
//        [tempVC removeFromParentViewController];
//    }
//}

- (NSString *)genRandStringLength:(int)len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSLog(@"tags: %@", self.tagsView.tags);
    return YES;
}


#pragma mark - RKTagsViewDelegate

- (UIButton *)tagsView:(RKTagsView *)tagsView buttonForTagAtIndex:(NSInteger)index {
    RKCustomButton *customButton = [RKCustomButton buttonWithType:UIButtonTypeSystem];
    customButton.titleLabel.font = tagsView.font;
    [customButton setTitle:[NSString stringWithFormat:@"%@,", tagsView.tags[index]] forState:UIControlStateNormal];
    [customButton runBubbleAnimation];
    return customButton;
}


@end
