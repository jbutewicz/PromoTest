//
//  ViewController.m
//  PromoTest
//
//  Created by Joseph Butewicz on 11/17/13.
//  Copyright (c) 2013 Joseph Butewicz. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Get device unique ID
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    
    // Store code from UI
    NSString *code = textField.text;
    
    // Hide keyword
    [textField resignFirstResponder];

    // Clear text field
    _textView.text = @"";
    
    // Show progress window
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Redeeming code...";
    
    // Start NSURLSession
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    // POST parameters
    NSURL *url = [NSURL URLWithString:@"http://localhost:8888/promos/index.php"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"rw_app_id=1&code=%@&device_id=%@", code, uniqueIdentifier];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data,
                                                                          NSURLResponse *response,
                                                                          NSError *error) {
                                                          
                                                          // Remove progress window
                                                          [MBProgressHUD hideHUDForView:self.view animated:YES];

                                                          // Handle response
                                                          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                          NSInteger statusCode = [httpResponse statusCode];
                                                          if(error == nil) {
                                                              
                                                              if (statusCode == 400) {
                                                                  _textView.text = @"Invalid code";
                                                              } else if (statusCode == 403) {
                                                                  _textView.text = @"Code already used";
                                                              } else if (statusCode == 200) {
                                                                  
                                                                  // Parse out the JSON data
                                                                  NSError *jsonError;
                                                                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                       options:kNilOptions
                                                                                                                         error:&jsonError];
                                                                  
                                                                  NSString* unlockCode = [json objectForKey:@"unlock_code"];
                                                                  
                                                                  // JSON data parsed, continue handling response
                                                                  if ([unlockCode compare:@"com.razeware.test.unlock.cake"] == NSOrderedSame) {
                                                                      _textView.text = @"The cake is a lie!";
                                                                  } else {
                                                                      _textView.text = [NSString stringWithFormat:@"Received unexpected unlock code: %@", unlockCode];
                                                                  }
                                                                  
                                                              } else {
                                                                  _textView.text = @"Unexpected error";
                                                              }
                                                          
                                                          } else {
                                                              _textView.text = error.localizedDescription;
                                                          }
                                                              
                                                      }];

    [dataTask resume];

    return TRUE;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end