//
//  ViewController.m
//  objective-curlTest
//
//  Created by Aurélien Hugelé on 17/05/2020.
//  Copyright © 2020 nrj. All rights reserved.
//

#import "ViewController.h"
#import <objective_curl/objective-curl.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CurlFTP *ftp = [[CurlFTP alloc] init];

    // Also available are CurlSFTP, and CurlS3 classes which can be used in the same way.

    [ftp setVerbose:YES];
    [ftp setShowProgress:YES];

    // See the CurlDelegate protocol
    [ftp setDelegate:self];

#warning EMBED A "test.mp4" FILE (SOMETHING ABOVE 1MB) TO TEST THE UPLOAD
    NSString *testFile = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    NSLog(@"file to upload is located at path:%@",testFile);
    if(testFile == nil) {
        NSLog(@"You must embed a \"test.mp4\" file (something above 1mb) to test the upload!");
    }
    NSArray *filesToUpload = [[NSArray alloc] initWithObjects:testFile,nil];     // feel free to mix and match files and directories
    // kick off the upload on a background thread
    // note that should shout not set the protocol in the host argument itself. We know it ftp:// or ftps:// since we instanciated a CurlFTP class!
    [ftp uploadFilesAndDirectories:filesToUpload toHost:@"customer-support.herdly.cloud" username:@"<userName>" password:@"<passWord>" directory:@"customer-support" port:21];
    
}

#pragma mark - Delegate Methods

/*
 * Called when the upload has started.
 */
- (void)uploadDidBegin:(CurlUpload *)record
{
    NSLog(@"uploadDidBegin:%@",record);
}


/*
 * Called when the upload has progressed, 1-100%.
 */
- (void)uploadDidProgress:(CurlUpload *)record toPercent:(NSNumber *)percent
{
    NSLog(@"uploadDidProgress:%@ - percent:%@",record,percent);
}


/*
 * Called when the upload process has finished successfully.
 */
- (void)uploadDidFinish:(CurlUpload *)record;
{
    NSLog(@"uploadDidFinish:%@",record);
}

/*
 * Called if the upload was cancelled.
 */
- (void)uploadWasCancelled:(CurlUpload *)record;
{
    NSLog(@"uploadWasCancelled:%@",record);
}


/*
 * Called when the upload has failed. The message will contain a useful description of what went wrong.
 */
- (void)uploadDidFail:(CurlUpload *)record message:(NSString *)message
{
    NSLog(@"uploadDidFail:%@ - message:%@",record,message);
}



/*
 * Implement this method to determine how a UNKNOWN host key fingerprint should be handled.
 * Return an integer indicating how to proceed.
 *
 *     0 = OK. Also add to known_hosts file
 *     1 = OK.
 *     2 = REJECT.
 *     3 = DEFER. Do not proceed, but leave the connection intact. This is the default if no delegate implementation exists.
 */
- (int)acceptUnknownHostFingerprint:(NSString *)fingerprint forUpload:(CurlUpload *)record;
{
    NSLog(@"acceptUnknownHostFingerprint:%@ - forUpload:%@",fingerprint,record);
    return 1;
}



/*
 * Implement this method to determine how a MISMATCHED host key fingerprint should be handled.
 * See above for possible return values.
 */
- (int)acceptMismatchedHostFingerprint:(NSString *)fingerprint forUpload:(CurlUpload *)record;
{
    NSLog(@"acceptMismatchedHostFingerprint:%@ - forUpload:%@",fingerprint,record);
    return 1;
}



@end
