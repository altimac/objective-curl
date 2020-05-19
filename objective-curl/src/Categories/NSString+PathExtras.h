/*!
    @header NSString+PathExtras
    @abstract   Category methods for creating FTP-safe paths.
    @discussion Category methods for creating FTP-safe paths.
*/


#import <Foundation/Foundation.h>


@interface NSString (PathExtras)

- (NSString *)oc_stringByAppendingPathPreservingAbsolutePaths:(NSString *)str;
- (NSString *)oc_stringByAddingTildePrefix;
- (NSString *)oc_stringByRemovingTildePrefix;

@end
