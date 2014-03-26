//
//  BarCodeViewController.m
//  VinReader
//
//  Created by Stephen Vilotti on 3/19/14.
//  Copyright (c) 2014 SolutionStream. All rights reserved.
//

#import "BarCodeViewController.h"
#import "VinObject.h"

@interface BarCodeViewController ()
@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (BOOL) startReading;
- (void) stopReading;
- (void) loadBeepSound;

@end

@implementation BarCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the flag to not reading
    _isReading = NO;
    
    _captureSession = nil;
    
    [self loadBeepSound];
    
       // Do any additional setup after loading the view.
}


- (IBAction)startStopReading:(id)sender {
    if (!_isReading){
        if ([self startReading]){
            [_bbitemStart setTitle:@"Stop"];
            [_lblStatus setText:@"Scanning for BarCode..."];
            [_lblPrompt setText:@"|--------------------------------------|"];
        }
    }
    else{
        [self stopReading];
        [_bbitemStart setTitle:@"Start!"];
        [_lblStatus setText:@"Code reader is not running"];
        [_lblPrompt setText:@"Tap on Start! to read a VIN Code"];
    }
        
    _isReading = !_isReading;
    
}

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input){
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
                       
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeCode39Code]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
    return YES;
}

- (void) stopReading {
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // Check to see if the array is not nil
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Check to see if it is a type 39 code - only interested in the first object
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeCode39Code]) {
            // The code is a Type 39 code, get the metadata now
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            _isReading = NO;
            
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        }
    }
}

- (void) loadBeepSound {
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        [_audioPlayer prepareToPlay];
    }
}


- (IBAction)scanButtonTapped:(id)sender{
    NSLog(@"TBD: scan barcode here...");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    MainFormViewController *mfvc = [segue destinationViewController];
    // Pass the selected object to the new view controller.
    
    // Create a new vin object to pass back to the previous scene
    VinObject *vin = [[VinObject alloc] init];
    // Set the vin number on the object
    // Check for pipe character
    NSString *capturedVIN = [_lblStatus text];
    NSString *searchText = @"|";
    //NSRange *range = [capturedVIN rangeOfString:searchText];
    if ([capturedVIN rangeOfString:searchText].location == NSNotFound) {
        capturedVIN = [capturedVIN substringFromIndex:1];
    }
    
    vin.vinNumber = capturedVIN;
    mfvc.vinObject = vin;
    
}



@end
