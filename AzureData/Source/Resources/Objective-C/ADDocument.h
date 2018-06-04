//
//  ADDocument.h
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#ifndef ADDocument_h
#define ADDocument_h

// - NOTE:
//     ADDocument has to be written in Objective-C to allow Objective-C
//     clients to inherit from this class to create their own documents.
//     Classes exposed from Swift cannot be inherited from in Objective-C.

@protocol ADResource;
@protocol ADSupportsPermissionToken;

#pragma clang diagnostic push
// Ignore the 'Cannot find ADResource and ADSupportsPermissionToken protocols' warnings.
#pragma clang diagnostic ignored "-Weverything"

/// Represents a document in the Azure Cosmos DB service.
///
/// - Remark:
///   A document is a structured JSON document. There is no set schema for the JSON documents,
///   and a document may contain any number of custom properties as well as an optional list of attachments.
///   Document is an application resource and can be authorized using the master key or resource keys.
@interface ADDocument: NSObject <ADResource, ADSupportsPermissionToken>
#pragma clang diagnostic pop

@property (nonatomic, readonly, copy) NSString* _Nonnull  id;
@property (nonatomic, readonly, copy) NSString* _Nonnull  resourceId;
@property (nonatomic, readonly, copy) NSString* _Nullable selfLink;
@property (nonatomic, readonly, copy) NSString* _Nullable etag;
@property (nonatomic, readonly, copy) NSDate*   _Nullable timestamp;
@property (nonatomic, readonly, copy) NSString* _Nullable altLink;

/// The self-link corresponding to attachments of the document from the Azure Cosmos DB service.
@property (nonatomic, readonly, copy) NSString* _Nullable attachmentsLink;

/// The time to live in seconds of the document in the Azure Cosmos DB service.
@property (nonatomic, readonly)       NSInteger           timeToLive;

- (nonnull instancetype)initWithId:(NSString* _Nonnull)id;
- (nullable instancetype)initFrom:(NSDictionary* _Nonnull)dictionary;
- (NSDictionary* _Nonnull)encode;

@end
 
#endif /* ADDocument_h */
