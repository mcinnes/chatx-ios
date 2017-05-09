//
//  NearMeViewController.h
//  Rides
//
//  Created by Matt on 8/12/2014.
//  Copyright (c) 2014 Matt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@interface NearMeViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@end
