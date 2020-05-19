//
//  UploadOperation.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "NSObject+DDExtensions.h"
#import "NSString+PathExtras.h"

#import "CurlUploadOperation.h"
#import "CurlFileTransfer.h"
#import "CurlUpload.h"
#import "CurlUploadDelegate.h"
#import "CurlConnectionDelegate.h"
#import "CurlTransferStatus.h"


@implementation CurlUploadOperation


@synthesize upload;


/*
 * Thread entry point for recursive FTP uploads.
 */
- (void)main 
{
	if ([self isCancelled] || [self dependentOperationCancelled]) {
		
		[self notifyDelegateOfFailure];
		
		return;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
	// Set options for uploading
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
	curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, self);
	curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, handleUploadProgress);
	
	// Set interface specific auth options
	[self setProtocolSpecificOptions];
	
	double totalBytes = 0;
	
	// Enumurate files and directories to upload
	NSArray *filesToUpload = [[self enumerateFilesToUpload:[upload localFiles] 
													prefix:[upload path] 
												totalBytes:&totalBytes] retain];
	
	[upload setTransfers:filesToUpload];

	[upload setTotalFiles:[filesToUpload count]];
	[upload setTotalFilesUploaded:0];

	[upload setTotalBytes:totalBytes];
	[upload setTotalBytesUploaded:0];
	
			
	CURLcode result = -1;
	
	for (int i = 0; i < [filesToUpload count]; i++)
	{
		// Begin Uploading.
		CurlFileTransfer *file = [filesToUpload objectAtIndex:i];
		
		[upload setCurrentTransfer:file];
		
		if ([file fileNotFound])
		{
			NSLog(@"Local file not found: %@", [file localPath]);
			continue;
		}
		
		[self setFileSpecificOptions:file];
		
		FILE *fh = [file getHandle];
		
		NSString *url = [self urlForTransfer:file];
		
		curl_easy_setopt(handle, CURLOPT_READDATA, fh);
		curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)[file totalBytes]);
		curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
		
		// Perform
		result = curl_easy_perform(handle);
		
		// Cleanup any headers
		[file cleanupHeaders];
		
		// Cleanup any quote commands
		[file cleanupPostQuotes];
		
		// Close the file handle
		fclose(fh);
		
		// If this upload wasn't successful, bail out.
		if (result != CURLE_OK)
			break;			
		
		// Increment total files uploaded
		[upload setTotalFilesUploaded:i + 1];
	}
	
	// Cleanup Curl
	curl_easy_cleanup(handle);
	
	// Cleanup the files array.
	[filesToUpload release];

	// Process the result of the upload.
	[self handleUploadResult:result];
	
	// Done.
	[pool release];
}


- (NSString *)urlForTransfer:(CurlFileTransfer *)file
{
	NSString *filePath = [[file remotePath] oc_stringByAddingTildePrefix];
	
	NSString *path = [[NSString stringWithFormat:@"%@:%d", [upload hostname], [upload port]]
					  oc_stringByAppendingPathPreservingAbsolutePaths:filePath];
	
	NSString *url = [NSString stringWithFormat:@"%@://%@", [upload protocolPrefix], path];
	
	return url;
}




-(BOOL)dependentOperationCancelled
{
	BOOL answer = NO;

	for (int i = 0; i < [[self dependencies] count]; i++) {
		NSOperation *dependency = [[self dependencies] objectAtIndex:i];
		
		if ([dependency isCancelled]) {
			answer = YES;
			break;
		}
	}	
	
	return answer;
}


- (void)setProtocolSpecificOptions
{
	curl_easy_setopt(handle, CURLOPT_USERPWD, [[self credentials] UTF8String]);
    curl_easy_setopt(handle, CURLOPT_USE_SSL, CURLUSESSL_TRY);
    curl_easy_setopt(handle, CURLOPT_SSL_VERIFYPEER, 0L); // don't verify SSL certificate of server
	curl_easy_setopt(handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1L);
}


- (void)setFileSpecificOptions:(CurlFileTransfer *)file
{ 	
	if ([file isEmptyDirectory])
	 {
		 const char *removeTempFile = [[NSString stringWithFormat:@"DELE %@", [CurlFileTransfer emptyFilename]] UTF8String];

		 [file appendPostQuote:removeTempFile];
	 }	
	
	curl_easy_setopt(handle, CURLOPT_POSTQUOTE, [file postQuote]);
}



/*
 * Used to handle upload progress if the showProgress flag is set. Invoked by libcurl on progress updates to calculates the 
 * new upload progress and sets it on the upload.
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTPROGRESSFUNCTION 
 */
static int handleUploadProgress(CurlUploadOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow)
{
	CurlUpload *upload = [operation upload];
	
	if ([upload connected] && !connected) return 0;  // Reconnecting...
	
	if (!connected)
	{
		if ([upload status] != CURL_TRANSFER_STATUS_CONNECTING)
		{
			// Connecting ...
			[upload setConnected:NO];
			[upload setStatus:CURL_TRANSFER_STATUS_CONNECTING];
			
			// Notify the delegate
			[operation performDelegateSelector:@selector(curlIsConnecting:) withArgument:nil];
		}
		
	}
	else
	{
		if (![upload connected])
		{
			// We have a connection.
			[upload setConnected:YES];
			[upload setStatus:CURL_TRANSFER_STATUS_CONNECTED];
			
			// Notify the delegate
			[operation performDelegateSelector:@selector(curlDidConnect:) withArgument:nil];			
		}
		
		if ([upload connected] && [upload status] != CURL_TRANSFER_STATUS_UPLOADING && ulnow > 0)
		{
			[upload setStatus:CURL_TRANSFER_STATUS_UPLOADING];
		
			// Notify the delegate
			[operation performDelegateSelector:@selector(uploadDidBegin:) withArgument:nil];
		 
			// Start the BPS timer
			[operation startByteTimer];
		}
		
		if (ulnow > ultotal) return 0;		// This happens occasionally, not sure why...
		
		[operation calculateUploadProgress:ulnow total:ultotal];
	}	
	
	return ([upload cancelled] || [upload status] == CURL_TRANSFER_STATUS_FAILED);
}




- (void)calculateUploadProgress:(double)ulnow total:(double)ultotal
{
	// Compute the current files bytes uploaded
	double currentBytesUploaded = [[upload currentTransfer] isEmptyDirectory] ? [[upload currentTransfer] totalBytes] : ulnow;
	
	// Compute the total bytes uploaded
	double totalBytesUploaded = [upload totalBytesUploaded] + (currentBytesUploaded - [[upload currentTransfer] totalBytesUploaded]);
	
	// Compute current files percentage complete
	double percentComplete = [[upload currentTransfer] isEmptyDirectory] ? 100 : (ulnow * 100 / ultotal);
	
	[[upload currentTransfer] setTotalBytesUploaded:currentBytesUploaded];
	[[upload currentTransfer] setPercentComplete:percentComplete];
	
	[upload setTotalBytesUploaded:totalBytesUploaded];
	
	// Compute the total percent complete of the entire transfer
	int progressNow = ([upload totalBytesUploaded] * 100 / [upload totalBytes]);
	
	if (progressNow >= [upload progress])
	{
		// Set the current progress
		[upload setProgress:progressNow];
		
		// Notify the delegate
		[self performDelegateSelector:@selector(uploadDidProgress:toPercent:)
						 withArgument:[NSNumber numberWithInt:progressNow]];
	}
}




/*
 * Called when the upload loop execution has finished. Updates the state of the upload and notifies delegates.
 *
 */
- (void)handleUploadResult:(CURLcode)result
{
	if (result == CURLE_OK && [upload totalFiles] == [upload totalFilesUploaded])
	{
		// Success!
		[upload setStatus:CURL_TRANSFER_STATUS_COMPLETE];
		
		// Notify Delegates		
		[self performDelegateSelector:@selector(uploadDidFinish:) 
						 withArgument:nil];
	}
	else if ([upload cancelled])
	{
		// Cancelled!
		[upload setStatus:CURL_TRANSFER_STATUS_CANCELLED];

		// Notify Delegate
		[self performDelegateSelector:@selector(uploadWasCancelled:) 
						 withArgument:nil];
	}
	else
	{		
		// Handle Failure
		[self handleUploadFailed:result];
	}
}



/*
 * Handles a failed upload. Figures out what went wrong and notifies the delegate. 
 *
 */
- (void)handleUploadFailed:(CURLcode)result
{
	// The upload operation failed.
	int status;
	switch (result)
	{
		// Auth Failure
		case CURLE_LOGIN_DENIED:
			status = CURL_TRANSFER_STATUS_LOGIN_DENIED;
			break;
			
		// General Failure
		default:
			status = CURL_TRANSFER_STATUS_FAILED;
			break;
	}
	
	[upload setStatus:status];
	[upload setStatusMessage:[self getFailureDetailsForStatus:result withObject:upload]];
	
	[self notifyDelegateOfFailure];
}



- (void)notifyDelegateOfFailure
{
	if (delegate && [delegate respondsToSelector:@selector(uploadDidFail:message:)])
	{
		[[delegate oc_invokeOnMainThread] uploadDidFail:upload message:[upload statusMessage]];
	}	
}



/*
 * Takes in a list of files and directories to be uploaded, and returns an array of FileTransfers.
 * Gets the job done, but the code is a mess and I'm pretty sure it's leaking.
 * 
 */
- (NSArray *)enumerateFilesToUpload:(NSArray *)files prefix:(NSString *)prefix totalBytes:(double *)totalBytes
{
	NSMutableArray *filesToUpload = [[NSMutableArray alloc] init];
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	BOOL isDir;
	for (int i = 0; i < [files count]; i++)
	{		
		NSString *pathToFile = [files objectAtIndex:i];
				
		CurlFileTransfer *pendingTransfer = nil;
		
		if ([mgr fileExistsAtPath:pathToFile isDirectory:&isDir] && !isDir)
		{
			// Regular File
			
			pendingTransfer = [[CurlFileTransfer alloc] initWithLocalPath:pathToFile
									remotePath:[prefix stringByAppendingPathComponent:[pathToFile lastPathComponent]]];
		}
		else if ([[mgr contentsOfDirectoryAtPath:pathToFile error:nil] count] > 0)
		{
			// Non-Empty Directory
			
			NSDirectoryEnumerator *dir = [mgr enumeratorAtPath:pathToFile];
			NSString *basePath = [pathToFile lastPathComponent];
			NSString *filename = NULL;
			
			while (filename = [dir nextObject])
			{
				NSString *nextPath = [pathToFile stringByAppendingPathComponent:filename];
				
				if ([mgr fileExistsAtPath:nextPath isDirectory:&isDir] && !isDir)
				{
					pendingTransfer = [[CurlFileTransfer alloc] initWithLocalPath:nextPath 
										remotePath:[prefix stringByAppendingPathComponent:[basePath stringByAppendingPathComponent:filename]]];
					
				}
				else if ([[mgr contentsOfDirectoryAtPath:nextPath error:nil] count] == 0)
				{
					pendingTransfer = [[CurlFileTransfer alloc] initWithLocalPath:nextPath 
										remotePath:[prefix stringByAppendingPathComponent:[basePath stringByAppendingPathComponent:filename]]];

					[pendingTransfer setIsEmptyDirectory:YES];
					[pendingTransfer setRemotePath:[[pendingTransfer remotePath] 
								stringByAppendingPathComponent:[CurlFileTransfer emptyFilename]]];
				}
				else
				{
					continue;
				}
				
				if ([pendingTransfer isEmptyDirectory] || [pendingTransfer fileNotFound]) {
                    
					[pendingTransfer setTotalBytes:0];
				}
				else {
                    
                    NSError *err = nil;
                    NSString *filePath = [[pendingTransfer localPath] stringByResolvingSymlinksInPath];
                    NSDictionary *fileAttrs = [mgr attributesOfItemAtPath:filePath error:&err];
                    double fileSize = 0;
                    if (!err) {
                        
                        fileSize = [[fileAttrs objectForKey:NSFileSize] doubleValue];
                    }
                    
					[pendingTransfer setTotalBytes:fileSize];
				}
				// Add to totalBytes
				*totalBytes += [pendingTransfer totalBytes];
				
				[filesToUpload addObject:pendingTransfer];				
			}
			
			continue;
		}
		else
		{
			pendingTransfer = [[CurlFileTransfer alloc] initWithLocalPath:pathToFile 
								remotePath:[prefix stringByAppendingPathComponent:[pathToFile lastPathComponent]]];
			
			if ([mgr fileExistsAtPath:pathToFile])
			{
				// Empty Directory
				[pendingTransfer setIsEmptyDirectory:YES];
				[pendingTransfer setRemotePath:[[pendingTransfer remotePath] 
												stringByAppendingPathComponent:[CurlFileTransfer emptyFilename]]];

			}
			else
			{
				// Not Found	
				[pendingTransfer setFileNotFound:YES];
			}
		}
		
		if ([pendingTransfer isEmptyDirectory] || [pendingTransfer fileNotFound]) {

			[pendingTransfer setTotalBytes:0];
		}
		else {
            
            NSError *err = nil;
            NSString *filePath = [[pendingTransfer localPath] stringByResolvingSymlinksInPath];
            NSDictionary *fileAttrs = [mgr attributesOfItemAtPath:filePath error:&err];
            double fileSize = 0;

            if (!err) {
                
                fileSize = [[fileAttrs objectForKey:NSFileSize] doubleValue];
            }

			[pendingTransfer setTotalBytes:fileSize];
		}
		
		// Add to totalBytes
		*totalBytes += [pendingTransfer totalBytes];
	
						
		[filesToUpload addObject:pendingTransfer];
		
	}
	
	return [filesToUpload autorelease];
}


/*
 * Calls an UploadDelegate method on the main thread.
 *
 */
- (void)performDelegateSelector:(SEL)aSelector withArgument:(id)arg
{
	if (delegate && [delegate respondsToSelector:aSelector])
	{
		if (arg)
		{
			[[delegate oc_invokeOnMainThread] performSelector:aSelector withObject:upload withObject:arg];
		}
		else
		{
			[[delegate oc_invokeOnMainThread] performSelector:aSelector withObject:upload];
		}
	}
}



/* 
 * Returns a string that can be used for FTP authentication, "username:password", if no username is specified then "anonymous" will 
 * be used. If a username is present but no password is set, then the users keychain is checked.
 *
 */
- (NSString *)credentials
{
	NSString *creds;
	if ([upload hasAuthUsername])
	{
		creds = [NSString stringWithFormat:@"%@:%@", [upload username], [upload password]];
	}
	else
	{
		// Try anonymous login
		creds = [NSString stringWithFormat:@"anonymous:"];
	}
	
	return creds;
}


/*
 * Cleanup. Release the upload.
 *
 */
- (void)dealloc
{
	[upload release];
	
	[super dealloc];
}


- (void)startByteTimer
{
	NSThread* timerThread = [[NSThread alloc] initWithTarget:self 
													selector:@selector(enterByteTimerThread) 
													  object:nil];
	[timerThread start];
}


- (void)enterByteTimerThread
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	[[NSTimer scheduledTimerWithTimeInterval:2.0
									  target:self
									selector:@selector(calculateBytesPerSecond:)
									userInfo:nil
									 repeats:YES] retain];
	
	[runLoop run];
	[pool release];
}


- (void)calculateBytesPerSecond:(NSTimer *)timer
{
	if ([upload isActive])
	{
		double bps = [upload totalBytesUploaded] - [upload lastBytesUploaded];
		double sr  = ([upload totalBytes] - [upload totalBytesUploaded]) / bps;
		
		[upload setBytesPerSecond:bps];
		[upload setSecondsRemaining:sr];
		[upload setLastBytesUploaded:[upload totalBytesUploaded]];
	}
	else
	{
		[timer invalidate];
		[timer release];
	}
}


@end
