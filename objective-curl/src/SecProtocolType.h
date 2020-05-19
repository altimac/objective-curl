//
//  SecProtocolType.h
//  objective-curl
//
//  Created by Aurélien Hugelé on 17/05/2020.
//  Copyright © 2020 nrj. All rights reserved.
//

#ifndef SecProtocolType_h
#define SecProtocolType_h

// AH: Stolen from MacOS Security framework SDK at: Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Security.framework/Versions/A/Headers/SecKeychain.h

/*!
    @enum ProtocolTypeConstants
    @abstract Defines the protocol type associated with an AppleShare or Internet password.
    @constant kSecProtocolTypeFTP Indicates FTP.
    @constant kSecProtocolTypeFTPAccount Indicates FTP Account (client side), usage deprecated.
    @constant kSecProtocolTypeHTTP Indicates HTTP.
    @constant kSecProtocolTypeIRC Indicates IRC.
    @constant kSecProtocolTypeNNTP Indicates NNTP.
    @constant kSecProtocolTypePOP3 Indicates POP3.
    @constant kSecProtocolTypeSMTP Indicates SMTP.
    @constant kSecProtocolTypeSOCKS Indicates SOCKS.
    @constant kSecProtocolTypeIMAP Indicates IMAP.
    @constant kSecProtocolTypeLDAP Indicates LDAP.
    @constant kSecProtocolTypeAppleTalk Indicates AFP over AppleTalk.
    @constant kSecProtocolTypeAFP Indicates AFP over TCP.
    @constant kSecProtocolTypeTelnet Indicates Telnet.
    @constant kSecProtocolTypeSSH Indicates SSH.
    @constant kSecProtocolTypeFTPS Indicates FTPS (FTP over TLS/SSL).
    @constant kSecProtocolTypeHTTPS Indicates HTTPS (HTTP over TLS/SSL).
    @constant kSecProtocolTypeHTTPProxy Indicates HTTP proxy.
    @constant kSecProtocolTypeHTTPSProxy Indicates HTTPS proxy.
    @constant kSecProtocolTypeFTPProxy Indicates FTP proxy.
    @constant kSecProtocolTypeSMB Indicates SMB.
    @constant kSecProtocolTypeRTSP Indicates RTSP.
    @constant kSecProtocolTypeRTSPProxy Indicates RTSP proxy.
    @constant kSecProtocolTypeDAAP Indicates DAAP.
    @constant kSecProtocolTypeEPPC Indicates EPPC (Remote Apple Events).
    @constant kSecProtocolTypeIPP Indicates IPP.
    @constant kSecProtocolTypeNNTPS Indicates NNTPS (NNTP over TLS/SSL).
    @constant kSecProtocolTypeLDAPS Indicates LDAPS (LDAP over TLS/SSL).
    @constant kSecProtocolTypeTelnetS Indicates Telnet over TLS/SSL.
    @constant kSecProtocolTypeIMAPS Indicates IMAPS (IMAP4 over TLS/SSL).
    @constant kSecProtocolTypeIRCS Indicates IRCS (IRC over TLS/SSL).
    @constant kSecProtocolTypePOP3S Indicates POP3S (POP3 over TLS/SSL).
    @constant kSecProtocolTypeCVSpserver Indicates CVS pserver.
    @constant kSecProtocolTypeSVN Indicates Subversion.
    @constant kSecProtocolTypeAny Indicates that any protocol is acceptable. When performing a search, use this constant to avoid constraining your search results to a particular protocol.
*/
typedef CF_ENUM(FourCharCode, SecProtocolType)
{
    kSecProtocolTypeFTP         = 'ftp ',
    kSecProtocolTypeFTPAccount  = 'ftpa',
    kSecProtocolTypeHTTP        = 'http',
    kSecProtocolTypeIRC         = 'irc ',
    kSecProtocolTypeNNTP        = 'nntp',
    kSecProtocolTypePOP3        = 'pop3',
    kSecProtocolTypeSMTP        = 'smtp',
    kSecProtocolTypeSOCKS       = 'sox ',
    kSecProtocolTypeIMAP        = 'imap',
    kSecProtocolTypeLDAP        = 'ldap',
    kSecProtocolTypeAppleTalk   = 'atlk',
    kSecProtocolTypeAFP         = 'afp ',
    kSecProtocolTypeTelnet      = 'teln',
    kSecProtocolTypeSSH         = 'ssh ',
    kSecProtocolTypeFTPS        = 'ftps',
    kSecProtocolTypeHTTPS       = 'htps',
    kSecProtocolTypeHTTPProxy   = 'htpx',
    kSecProtocolTypeHTTPSProxy  = 'htsx',
    kSecProtocolTypeFTPProxy    = 'ftpx',
    kSecProtocolTypeCIFS        = 'cifs',
    kSecProtocolTypeSMB         = 'smb ',
    kSecProtocolTypeRTSP        = 'rtsp',
    kSecProtocolTypeRTSPProxy   = 'rtsx',
    kSecProtocolTypeDAAP        = 'daap',
    kSecProtocolTypeEPPC        = 'eppc',
    kSecProtocolTypeIPP         = 'ipp ',
    kSecProtocolTypeNNTPS       = 'ntps',
    kSecProtocolTypeLDAPS       = 'ldps',
    kSecProtocolTypeTelnetS     = 'tels',
    kSecProtocolTypeIMAPS       = 'imps',
    kSecProtocolTypeIRCS        = 'ircs',
    kSecProtocolTypePOP3S       = 'pops',
    kSecProtocolTypeCVSpserver  = 'cvsp',
    kSecProtocolTypeSVN         = 'svn ',
    kSecProtocolTypeAny         =  0
};

#endif /* SecProtocolType_h */
