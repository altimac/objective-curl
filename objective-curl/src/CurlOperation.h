//
//  CurlOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//


#import <Foundation/Foundation.h>
#import <sys/stat.h>
//#import "patched-curl.h"
#import <curl/curl.h>

@class CurlRemoteObject;

@interface CurlOperation : NSOperation 
{
	CURL *handle;
	id delegate;
}

@property(readwrite, assign) id delegate;

- (id)initWithHandle:(CURL *)aHandle delegate:(id)aDelegate;

- (NSString *)getFailureDetailsForStatus:(int)status withObject:(CurlRemoteObject *)object;

@end
