//
//  NSData+CCHmac.h
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#import <Foundation/Foundation.h>

@interface NSData (CCHmac)

- (NSData *)CCHmacWithBytes:(const unsigned char *) bytes;

@end
