//
//  NSString+MD5.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

+ (NSString *)oc_formattedMD5:(const char *)data length:(unsigned long)len
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, (CC_LONG)len, md5Buffer);
    
	NSMutableArray *values = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < strlen((char *)md5Buffer); i++)
	{
		char hexValue[4];
		sprintf(hexValue, "%02X", md5Buffer[i]);
		[values addObject:[NSString stringWithUTF8String:hexValue]];
	}
	
	return [values componentsJoinedByString:@":"];
}

//+ (NSString *)oc_formattedMD5FromBase64:(const char *)data length:(unsigned long)len
//{
//	BIO *b64, *bmem;
//
//	char *buffer = (char *)malloc(len);
//	memset(buffer, 0, len);
//
//	b64 = BIO_new(BIO_f_base64());
//
//	BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
//
//	bmem = BIO_new_mem_buf((char *)data, (int)len);
//	bmem = BIO_push(b64, bmem);
//
//	BIO_read(bmem, buffer, (int)len);
//
//	BIO_free_all(bmem);
//
//	NSString *result = [NSString oc_formattedMD5:buffer length:len];
//
//	free(buffer);
//
//	return result;
//}



@end
