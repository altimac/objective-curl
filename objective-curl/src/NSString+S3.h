//
//  NSString+S3.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>


@interface NSString (S3)

- (NSString *)signS3PutRequestWithKey:(NSString *)key;

@end
