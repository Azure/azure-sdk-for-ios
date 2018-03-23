//
//  CryptoProvider.h
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#import <Foundation/Foundation.h>

@interface CryptoProvider : NSObject

+ (NSString*) hmacSHA256:(NSString*)data withKey:(NSString*) key;

@end
