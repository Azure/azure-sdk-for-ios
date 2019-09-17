//
//  AZCPipeline.m
//  AzureCore
//
//  Created by Travis Prescott on 9/12/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#import "AZCPipelineClient.h"
#import <AzureCore/AzureCore-Swift.h>

@implementation AZCPipelineClient

- (id)initWithBaseUrl:(NSString *)baseUrl withConfig:(PipelineConfiguration *)config andPipeline:(Pipeline *)pipeline {
    self.baseUrl = baseUrl;
    self.config = config;
    self.pipeline = pipeline;
    return self;
}

- (HttpRequest *)requestWithMethod:(NSInteger *)method withUrlTemplate:(NSString *)urlTemplate withQueryParams:(NSDictionary<NSString *, NSString *> *)queryParams withHeaders:(NSDictionary<NSString *, NSString *> *)headers withContent:(NSData *)data withFormContent:(NSDictionary<NSString *, NSObject *> *)formContent withStreamContent:(NSObject *)streamContent {
    HttpRequest *request = [[HttpRequest alloc] initWithHttpMethod:*(HttpMethod *)method url:[self formatUrlTemplate: urlTemplate]];
    if (queryParams != nil) {
        [request formatWithQueryParams:queryParams];
    }
    if (headers != nil) {
    }
    return request;
}

- (NSString *)formatUrlTemplate:(NSString *)urlTemplate {
    NSString *url;
    if (urlTemplate != nil) {
        url = [self formatUrlSectionForTemplate: [self joinBase: self.baseUrl withStub: urlTemplate]];
    } else {
        url = self.baseUrl;
    }
    return url;
}

- (NSString *)formatUrlSectionForTemplate:(NSString *)template {
    // TODO: replace {these} with their values
    // NSArray *components = [template componentsSeparatedByString:@"/"];
    return template;
}

- (NSString *)joinBase:(NSString *)base withStub:(NSString *)stub {
    return [NSString stringWithFormat:@"%@%@", base, stub];
}

@end
