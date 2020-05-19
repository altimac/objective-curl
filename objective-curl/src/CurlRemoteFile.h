//
//  CurlRemoteFile.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>


@interface CurlRemoteFile : NSObject 
{
	NSString *name;
	long size;
	long lastModified;
	BOOL isDir;
	BOOL isSymLink;
}

@property(readwrite, copy) NSString *name;
@property(readwrite, assign) long size;
@property(readwrite, assign) long lastModified;
@property(readwrite, assign) BOOL isDir;
@property(readwrite, assign) BOOL isSymLink;

@end
