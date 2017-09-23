//
//  NearMeViewController.m
//  Rides
//
//  Created by Matt on 8/12/2014.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import "NearMeViewController.h"
#import "JPSThumbnailAnnotation.h"
#import <Parse/Parse.h>
#import "SocketViewController.h"
#import <ISMessages/ISMessages.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface NearMeViewController ()

@end

@implementation NearMeViewController {
    CLLocationManager *locationManager;
    _Bool *driving;
    MKMapView *mapView;
    NSString *titleString;
    NSString *roomNumber;
    NSString *roomID;
    bool mapMessageShown;

}
-(void)viewWillDisappear:(BOOL)animated{
    [locationManager stopUpdatingLocation];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Map View
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapView.delegate = self;
    [self.view addSubview:mapView];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];

#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        //[self.locationManager requestAlwaysAuthorization];
    }
#endif
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    mapView.showsUserLocation = YES;
    
    CLLocation *location = [locationManager location];
    [self getAnnotations:location map:mapView];
    
  
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = location.coordinate;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [mapView setRegion:mapRegion animated: YES];
    [mapView setMapType:MKMapTypeStandard];
    
    UILongPressGestureRecognizer *tapAndHoldGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAndHoldGesture:)];
    tapAndHoldGesture.minimumPressDuration = 0.5;
    tapAndHoldGesture.allowableMovement = 600;
    [mapView addGestureRecognizer:tapAndHoldGesture];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAndHoldGesture:)];
    [mapView addGestureRecognizer:pinchGestureRecognizer];
    
    
}

- (void) handleTapAndHoldGesture:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (self.navigationController.navigationBar.hidden == true) {
        self.navigationController.navigationBar.hidden = false;
    } else {
        if(!mapMessageShown){
            [self showMapMessage];
            mapMessageShown = true;
        }
        
        
        self.navigationController.navigationBar.hidden = true;

    }
}
-(void)showMapMessage{
    
    
    [ISMessages showCardAlertWithTitle:@"Hold the map to show navigation again"
                               message:@""
                              duration:3.f
                           hideOnSwipe:YES
                             hideOnTap:YES
                             alertType:ISAlertTypeSuccess
                         alertPosition:ISAlertPositionTop
                               didHide:^(BOOL finished) {
                                   NSLog(@"Alert did hide.");
                               }];
    
}
-(void)getAnnotations:(CLLocation *)location map:(MKMapView *)mapview {
    
    PFGeoPoint *currentLocation =  [PFGeoPoint geoPointWithLocation:location];
    
    NSLog(@"currloc %@", currentLocation);
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    format.dateFormat = @"yyy-MM-dd";
    
    NSLog(@"date %@", date);
    //NSPredicate *pred = [NSPredicate predicateWithFormat:@"music ContainedIn tags"];
    PFQuery *query = [PFQuery queryWithClassName:@"CurrentChats"];
    
    [query whereKey:@"location" nearGeoPoint:currentLocation withinKilometers:20.0];
    
    //[query whereKey:@"date" equalTo:date];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            
            NSLog(@"Map object count %ld",objects.count);
            
            for (PFObject *object in objects) {
                
                NSLog(@"%@", object.objectId);
                
                PFGeoPoint *location = [object objectForKey:@"location"];
                PFFile *imageFile = [object objectForKey:@"ImageIcon"];
                NSURL *imageFileURL = [[NSURL alloc] initWithString:imageFile.url];
                NSData *imageData = [NSData dataWithContentsOfURL:imageFileURL];
                
                
                JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
                
                thumbnail.image = [UIImage imageWithData:imageData];
                thumbnail.title = [NSString stringWithFormat:@"%@", object[@"ChatName"]];
                thumbnail.subtitle = [NSString stringWithFormat:@"Current Users: %@", object[@"CurrentCount"]];
                thumbnail.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                thumbnail.disclosureBlock = ^{ titleString = thumbnail.title; roomNumber=object[@"ChatRoomID"]; roomID = object.objectId; [self showlibchat]; };
                
                [mapview addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];
                
            }}}];
    
                
}

- (NSArray *)generateAnnotations {
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:20];
    return annotations;
}

-(void)viewEvent:(PFObject *)event{
  //  NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"%K like %@",
          //                      attributeName, attributeValue];
}
-(void)drivingChanged {
    
    if (!driving) {
        
    } else {
        
    }
}
- (IBAction)touchedd:(id)sender {
    [self changeMapType];
}

-(void)changeMapType {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Map Type"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Standard",@"Satellite",@"Hybrid", nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    }
    if (buttonIndex == 1) {
        NSLog(@"Standard");
        [mapView setMapType:MKMapTypeStandard];
    }
    if (buttonIndex == 2) {
        NSLog(@"Sat");
        [mapView setMapType:MKMapTypeSatellite];
    }
    if (buttonIndex == 3) {
        NSLog(@"Hybrid");
        [mapView setMapType:MKMapTypeHybrid];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!driving) {
        
    } else {
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.2;
        mapRegion.span.longitudeDelta = 0.2;
        
        [mapView setRegion:mapRegion animated: YES];
    }
    
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        
    }
}

-(void)showlibchat{
    [self performSegueWithIdentifier:@"library" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   
    if ([segue.identifier isEqualToString:@"library"]) {
        SocketViewController *socketVC = segue.destinationViewController;
        socketVC.title = titleString;
        socketVC.roomNumber = roomNumber;
        socketVC.roomID = roomID;
        
    }
}
-(void)didReceiveMemoryWarning{
    mapView = nil;
}
@end
