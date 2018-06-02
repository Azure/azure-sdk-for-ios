//
//  ADDocument.m
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#import <Foundation/Foundation.h>
#import <AzureData/AzureData-Swift.h>
#import "ADDocument.h"

@implementation ADDocument

- (nonnull instancetype)initWithId:(NSString *)id {
    self = [super init];

    if (self) {
        _id = [id copy];
        _resourceId = @"";
        _selfLink = nil;
        _etag = nil;
        _timestamp = nil;
        _attachmentsLink = nil;
        _altLink = nil;
    }

    return self;
}

// MARK: - ADCodable

- (nullable instancetype)initFrom:(NSDictionary *)dictionary {
    self = [super init];

    NSString* id = [dictionary valueForKey:@"id"];
    NSString* resourceId = [dictionary valueForKey:@"_rid"];

    if (!(id && resourceId)) {
        return nil;
    }

    if (self) {
        _id = [id copy];
        _resourceId = [resourceId copy];
        _selfLink = [[dictionary valueForKey:@"_self"] copy];
        _etag = [[dictionary valueForKey:@"_etag"] copy];
        _timestamp = [ADDateEncoders decodeTimestampFrom:[[dictionary valueForKey:@"_ts"] copy]];
        _attachmentsLink = [[dictionary valueForKey:@"_attachments"] copy];
    }

    return self;
}

- (NSDictionary* _Nonnull)encode {
    NSDictionary* dictionary = [[NSMutableDictionary alloc] init];

    if (dictionary) {
        [dictionary setValue:_id forKey:@"id"];
        [dictionary setValue:_resourceId forKey:@"_rid"];
        [dictionary setValue:_selfLink forKey:@"_self"];
        [dictionary setValue:_etag forKey:@"_etag"];
        [dictionary setValue:[ADDateEncoders encodeTimestamp:_timestamp] forKey:@"_ts"];
        [dictionary setValue:_attachmentsLink forKey:@"_attachments"];
    }

    return dictionary;
}

@end
