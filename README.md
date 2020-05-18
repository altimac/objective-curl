## Main goal of this fork

I had to use libcurl to upload files from an iOS app to a FTPS server. CFNetwork FTP code is deprecated and probably does not support SSL authentication. There is no other replacement than libcurl either in Swift or ObjC.
libcurl is quite complex to use and thus I wanted a Cocoa wrapper.
objective-curl is pretty old (not using ARC) but somewhat works.
To support FTPS (and not SFTP!!) I had to tweak the code a bit. Moreover to make it work on iOS instead of macOS several changes have been made. Using CommonCrypto (default on iOS/macOS) instead of OpenSSL (not available by default on iOS) also reduces the dependencies.

I may plan to modernize the code later, but this is not a priority. I've mostly tweaked the code to support FTPS (instead of FTP or SFTP) and do not plan to update the code for other types of transfer (scp, ssh, S3 etc...)

## ORIGINAL README:

The objective-curl framework provides an easy-to-use interface to [libcurl](http://curl.haxx.se/libcurl/c/) for Cocoa developers. Right now only uploading is supported and on the following protocols: FTP, SFTP, and Amazon S3 (HTTPS). There are a couple other frameworks out there that use libcurl for network operations but all subclass [NSURLHandle](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURLHandle_Class/Reference/Reference.html), which has been deprecated since 10.4. This framework is designed to be used in more modern Cocoa applications and requires Mac OSX 10.5 or higher. 

All curl objects are subclasses of  [NSObject](http://developer.apple.com/mac/library/documentation/cocoa/reference/Foundation/Classes/NSObject_Class/Reference/Reference.html).

Threading is done with  [NSOperation](http://developer.apple.com/mac/library/DOCUMENTATION/Cocoa/Reference/NSOperation_class/Reference/Reference.html) and [NSOperationQueue](http://developer.apple.com/mac/library/DOCUMENTATION/Cocoa/Reference/NSOperationQueue_class/Reference/Reference.html#//apple_ref/occ/cl/NSOperationQueue). (Added in OS X 10.5)

The framework also utilizes common Cocoa delegate patterns.

## Simple Example

    CurlFTP *ftp = [[CurlFTP alloc] init];
    
    // Also available are CurlSFTP, and CurlS3 classes which can be used in the same way.
    
    [ftp setVerbose:YES]
    [ftp setShowProgress:YES];
    [ftp setAuthUsername:@"me"];
    [ftp setAuthPassword:@"mypassword"];
    
    // See the CurlDelegate protocol
    [ftp setDelegate:self];
    
    // feel free to mix and match files and directories
    NSArray *filesToUpload = [[NSArray alloc] initWithObjects:@"/path/to/musicfile.mp3", 
                                                              @"/path/to/directory", 
                                                              @"/path/to/moviefile.avi", NULL];
    // kick off the upload on a background thread
    [ftp uploadFilesAndDirectories:filesToUpload toHost:@"localhost" directory:@"~/tmp"];

## OneWay

The objective-curl framework is currently powering the [OneWay](http://goto11.net/oneway) application.

## License

objective-curl is licensed under the MIT license.

Copyright (c) 2009-2010, Nick Jensen, &lt;[nickrjensen@gmail](mailto:nickrjensen@gmail.com)&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


[Curl](http://curl.haxx.se/) and [libcurl](http://curl.haxx.se/libcurl) are licensed under a MIT/X derivate license, see below.

Copyright (c) 1996 - 2010, Daniel Stenberg,  &lt;[daniel@haxxe.se](mailto:daniel@haxxe.se)&gt;
 
All rights reserved.
 
Permission to use, copy, modify, and distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright
notice and this permission notice appear in all copies.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
OR OTHER DEALINGS IN THE SOFTWARE.
 
Except as contained in this notice, the name of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.
