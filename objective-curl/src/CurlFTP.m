//
//  CurlFTP.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "CurlFTP.h"
#import "CurlClientType.h"
#import "CurlUploadOperation.h"
#import "CurlUpload.h"
#import "NSString+PathExtras.h"
#import "SecProtocolType.h"


@implementation CurlFTP


/*
 * Initialize a directory list cache and other property defaults;
 */
- (id)init
{		
	if (self = [super init])
	{
		//[self setProtocol:kSecProtocolTypeFTPS]; // FTPS is FTP, use FTP as libcurl handles ftps as ftp.
        [self setProtocol:kSecProtocolTypeFTP];
		
		directoryListCache = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


/*
 * Cleanup.
 */
- (void)dealloc
{
	[directoryListCache release];
	
	[super dealloc];
}


- (NSString *)protocolPrefix
{
	return @"ftp";
}


- (int)defaultPort
{
	return 21;
}


- (int)clientType
{	
	return CURL_CLIENT_FTP;
}



/*
 * Recursively upload a list of files and directories using the specified host and the users home directory.
 */
- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:hostname 
								  username:username
								  password:@""
								 directory:@""
									  port:[self defaultPort]];
}


/*
 * Recursively upload a list of files and directories using the specified host and directory.
 */
- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:hostname 
								  username:username
								  password:password
								 directory:@""
									  port:[self defaultPort]];
}


/*
 * Recursively upload a list of files and directories using the specified host, directory and port number. The associated Upload object
 * is returned, however not retained.
 */
- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory
{		
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:hostname 
								  username:username
								  password:password
								 directory:directory
									  port:[self defaultPort]];	
}

- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory port:(int)port
{
	CurlUpload *upload = [[[CurlUpload alloc] init] autorelease];
	
	[upload setProtocol:[self protocol]];
	[upload setProtocolPrefix:[self protocolPrefix]];
	[upload setClientType:[self clientType]];
	[upload setLocalFiles:filesAndDirectories];
	[upload setHostname:hostname];
	[upload setUsername:username];
	[upload setPassword:password];
	[upload setPath:[directory oc_stringByRemovingTildePrefix]];
	[upload setPort:port];

	[self upload:upload];
	
	return upload;
}

- (void)upload:(CurlUpload *)record
{
	CurlUploadOperation *op = [[CurlUploadOperation alloc] initWithHandle:[self newHandle] delegate:delegate];
		
	[record setProgress:0];
	[record setStatus:CURL_TRANSFER_STATUS_QUEUED];
	[record setConnected:NO];
	[record setCancelled:NO];

	[op setUpload:record];
	[operationQueue addOperation:op];
	[op release];
}


/*
 * Returns an array of files that exist in a remote directory. Will use items in the directoryListCache if they exist. Uses 
 * the default FTP port.
 */
- (CurlRemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host
{
	return [self listRemoteDirectory:directory 
							  onHost:host
						 forceReload:NO
								port:[self defaultPort]];
}


/*
 * Returns an array of files that exist in a remote directory. The forceReload flag will bypass using the directoryListCache and
 * always return a fresh listing from the specified server.  Uses the default FTP port.
 */
- (CurlRemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload
{
	return [self listRemoteDirectory:directory 
							  onHost:host 
						 forceReload:reload 
								port:[self defaultPort]];
}


/*
 * Returns an array of files that exist in a remote directory. The forceReload flag will bypass using the directoryListCache and
 * always return a fresh listing from the specified server and port number.
 */
- (CurlRemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload port:(int)port
{	
//	RemoteFolder *folder = [[[RemoteFolder alloc] init] autorelease];
//	
//	[folder setProtocol:[self protocolType]];
//	[folder setHostname:host];
//	[folder setPort:port];
//	[folder setPath:[directory pathForFTP]];
//	[folder setForceReload:reload];
//	
//	
//	ListOperation *op = [[ListOperation alloc] initWithClient:self transfer:folder];
//	
//	[op setFolder:folder];
//	
//	[operationQueue addOperation:op];
//	
//	return folder;
	return nil;
}


@end
