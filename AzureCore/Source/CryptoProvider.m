//
//  CryptoProvider.m
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#import "CryptoProvider.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

@implementation CryptoProvider

+ (NSString*) hmacSHA256:(NSString*)data withKey:(NSString*) key {
    
    NSData *cData = [data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    NSData *kData = [[NSData alloc] initWithBase64EncodedString:key options:kNilOptions];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, kData.bytes, kData.length, cData.bytes, cData.length, cHMAC);
    
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *hashString = [hash base64EncodedStringWithOptions:kNilOptions];
    
    return hashString;
}

@end
