//
//  NSString+CCHmac.m
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#import "NSData+CCHmac.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSData (CCHmac)

- (NSData *)CCHmacWithBytes:(const unsigned char *) bytes {
    
    unsigned char hashResult[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, self.bytes, self.length, bytes, strlen((char*)bytes), hashResult);
    
    NSData *hash = [[NSData alloc] initWithBytes:hashResult length:sizeof(hashResult)];
    
    return hash;
}

@end
