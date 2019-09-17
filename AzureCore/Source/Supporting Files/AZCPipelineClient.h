//
//  AZCPipeline.h
//  AzureCore
//
//  Created by Travis Prescott on 9/12/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PipelineConfiguration;
@class Pipeline;
@class HttpRequest;

@interface AZCPipelineClient : NSObject

@property(weak, nonatomic) NSString *                baseUrl;
@property(weak, nonatomic) PipelineConfiguration *   config;
@property(weak, nonatomic) Pipeline *                pipeline;

- (id)initWithBaseUrl:(NSString *)baseUrl withConfig:(PipelineConfiguration *)config andPipeline:(Pipeline *)pipeline;
- (HttpRequest *)requestWithMethod:(NSInteger *)method withUrlTemplate:(NSString *)urlTemplate withQueryParams:(NSDictionary<NSString *, NSString *> *)queryParams withHeaders:(NSDictionary<NSString *, NSString *> *)headers withContent:(NSData *)data withFormContent:(NSDictionary<NSString *, NSObject *> *)formContent withStreamContent:(NSObject *)streamContent;
- (NSString *)formatUrlTemplate:(NSString *)urlTemplate;
- (NSString *)formatUrlSectionForTemplate:(NSString *)template;
- (NSString *)joinBase:(NSString *)base withStub:(NSString *)stub;

@end

NS_ASSUME_NONNULL_END
