//
//  FBPPViewController.m
//  FBPhotoPost
//
//  Created by Marco S. Graciano on 1/14/13.
//  Copyright (c) 2013 MSG. All rights reserved.
//

#import "FBPPViewController.h"

@implementation FBPPViewController

@synthesize photoView, profilePic, activityIndicator, locationManager, userLocation, geocoder, placemark;

#pragma mark - UIViewController


- (void)showActivityIndicator {
    if (![activityIndicator isAnimating]) {
        self.view.userInteractionEnabled = NO;
        [activityIndicator startAnimating];
    }
}

- (void)hideActivityIndicator {
    if ([activityIndicator isAnimating]) {
        [activityIndicator stopAnimating];
        self.view.userInteractionEnabled = YES;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Activity indicator
    int xPosition = (self.view.bounds.size.width / 2.0) - 15.0;
    int yPosition = (self.view.bounds.size.height / 2.0) - 15.0;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(xPosition, yPosition, 30, 30)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:activityIndicator];
    
    // Create Login View so that the app will be granted "status_update" permission.
    FBLoginView *loginview = [[FBLoginView alloc] init];
    
    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];
    
    // Location manager & geocoder init
    self.locationManager = [[CLLocationManager alloc] init];
    self.geocoder = [[CLGeocoder alloc] init];
    
    //Location manager configuration and startup
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    userLocation = locationManager.location;
    NSLog(@"Latitude: %f, Longitude: %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    
}

- (void)viewDidUnload{
    self.photoView = nil;
    self.profilePic = nil;
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Hide the activitiy indicator
    [self hideActivityIndicator];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    else{
        return NO;
    }
}


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        photoView.image = image;
        
        //Si es una nueva foto, la guarda en el rollo de fotos
        if (newMedia)
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }
}


-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Save failed" message: @"Failed to save photo" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // first get the button set for login mode
    self.buttonPostPhoto.enabled = YES;
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    self.profilePic.profileID = user.id;
    self.loggedInUser = user;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    BOOL canShareAnyhow = [FBNativeDialogs canPresentShareDialogWithSession:nil];
    self.buttonPostPhoto.enabled = canShareAnyhow;
    self.profilePic.profileID = nil;
    self.labelFirstName.text = nil;
    self.loggedInUser = nil;
}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    userLocation = newLocation;
    NSLog(@"Latitude: %f, Longitude: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            NSLog(@"Address: %@", [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                   placemark.subThoroughfare, placemark.thoroughfare,
                                   placemark.postalCode, placemark.locality,
                                   placemark.administrativeArea,
                                   placemark.country]);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}


#pragma mark - Handlers and helper methods

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         action();
                                                     }
                                                     //For this example, ignore errors (such as if user cancels).
                                                 }];
    } else {
        action();
    }
    
}


// Post Photo button handler. This way, we can upload a photo and its location.
- (IBAction)postPhotoClick:(UIButton *)sender {
    [self showActivityIndicator];
    
    UIImage *img = photoView.image;
    NSData *imageData = UIImageJPEGRepresentation(img, 90);
    NSString *message = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@\nLatitude: %f, Longitude: %f",
                         placemark.subThoroughfare, placemark.thoroughfare,
                         placemark.postalCode, placemark.locality,
                         placemark.administrativeArea,
                         placemark.country,
                         userLocation.coordinate.latitude,
                         userLocation.coordinate.longitude];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    message, @"message",
                                    imageData, @"source",
                                    nil];
    
    if (img) {
        [self performPublishAction:^{
            [FBRequestConnection startWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                        [self hideActivityIndicator];
                                        [self showAlert:@"Photo" result:result error:error];
                                        self.buttonPostPhoto.enabled = YES;
                                       }];

                self.buttonPostPhoto.enabled = NO;
        }];

    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"You must take a photo or pick one to post it."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }

}



//Take Photo button handler
- (void)useCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = YES;
    }
}


//Pick Photo button handler
- (void)useCameraRoll {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = NO;
    }
}


// UIAlertView
- (void)showAlert:(NSString *)message result:(id)result error:(NSError *)error {
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertMsg = error.localizedDescription;
        alertTitle = @"Error";
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"%@ succesfully posted!\nPost ID: %@",
                    message, [resultDict valueForKey:@"id"]];
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


@end
