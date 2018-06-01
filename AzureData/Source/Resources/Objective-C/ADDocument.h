//
//  ADDocument.h
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#ifndef ADDocument_h
#define ADDocument_h

@protocol ADResource
@end

@protocol ADSupportsPermissionToken
@end

@interface ADDocument: NSObject <ADResource, ADSupportsPermissionToken>

@property (nonatomic, readonly, copy) NSString* _Nonnull  id;
@property (nonatomic, readonly, copy) NSString* _Nonnull  resourceId;
@property (nonatomic, readonly, copy) NSString* _Nullable selfLink;
@property (nonatomic, readonly, copy) NSString* _Nullable etag;
@property (nonatomic, readonly, copy) NSDate*   _Nullable timestamp;
@property (nonatomic, readonly, copy) NSString* _Nullable attachmentsLink;
@property (nonatomic, readonly, copy) NSString* _Nullable altLink;
@property (nonatomic, readonly)       NSInteger           timeToLive;

- (nonnull instancetype)initWithId:(NSString* _Nonnull)id;
- (nullable instancetype)initFrom:(NSDictionary* _Nonnull)dictionary;
- (NSDictionary* _Nonnull)encode;

@end
 
#endif /* ADDocument_h */
