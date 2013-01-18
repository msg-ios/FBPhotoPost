//
//  FBPPViewController.h
//  FBPhotoPost
//
//  Created by Marco S. Graciano on 1/14/13.
//  Copyright (c) 2013 MSG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>

@interface FBPPViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBLoginViewDelegate, CLLocationManagerDelegate>
{
    UIImageView *photoView;
    BOOL newMedia;
}

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostPhoto;
@property (strong, nonatomic) IBOutlet UILabel *labelFirstName;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (IBAction)postPhotoClick:(UIButton *)sender;

- (IBAction)useCamera;
- (IBAction)useCameraRoll;

- (void)showAlert:(NSString *)message result:(id)result error:(NSError *)error;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end
