//
//  CameraViewController.h
//  VinReader
//
//  Created by Stephen Vilotti on 3/3/14.
//  Copyright (c) 2014 SolutionStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraViewController : UIViewController

<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;


@end
