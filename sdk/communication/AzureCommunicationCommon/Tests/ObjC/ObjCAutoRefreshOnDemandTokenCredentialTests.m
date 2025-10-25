// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

#import <XCTest/XCTest.h>
#import <AzureCommunicationCommon/AzureCommunicationCommon-Swift.h>
#import "ObjCCommunicationTokenCredentialTests.h"

@interface ObjCAutoRefreshOnDemandTokenCredentialTests : ObjCCommunicationTokenCredentialTests
@end

@implementation ObjCAutoRefreshOnDemandTokenCredentialTests

- (void)test_ShouldBeCalledImmediatelyWithExpiredToken {
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_ShouldBeCalledImmediatelyWithExpiredToken"];
    
    __weak ObjCAutoRefreshOnDemandTokenCredentialTests *weakSelf = self;
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [self createTokenRefreshOptions:weakSelf initialToken:self.sampleExpiredToken refreshedToken:weakSelf.sampleToken];
    
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                                 NSError * _Nullable error) {
            XCTAssertNotNil(accessToken);
            XCTAssertNil(error);
            XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
            XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
            [expectation fulfill];
        }];
    });
    [self waitForExpectationsWithTimeout:self.timeout handler:^(NSError * _Nullable error) {
        [self failForTimeout:error testName:expectation.expectationDescription];
    }];
}

-(CommunicationTokenCredential *)createTokenRefreshOptions:(__weak ObjCAutoRefreshOnDemandTokenCredentialTests *)weakSelf initialToken:(NSString *)initialToken refreshedToken:(NSString *) refreshedToken {
    return (CommunicationTokenCredential *) [[CommunicationTokenRefreshOptions alloc]
            initWithInitialToken:initialToken
            refreshProactively:NO
            tokenRefresher:^(void (^ block)
                             (NSString * _Nullable accessToken,
                              NSError * _Nullable error)) {
                weakSelf.fetchTokenCallCount += 1;
                block(refreshedToken, nil);
            }];
}

- (void)test_ShouldNotBeCalledBeforeExpiringTime {
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_ShouldNotBeCalledBeforeExpiringTime"];
    __weak ObjCAutoRefreshOnDemandTokenCredentialTests *weakSelf = self;
    NSString *tokenValidFor15Mins = [self generateTokenValidForSeconds:15 * 60];
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [self createTokenRefreshOptions:weakSelf initialToken:tokenValidFor15Mins refreshedToken:weakSelf.sampleToken];
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                                 NSError * _Nullable error) {
            XCTAssertNotNil(accessToken);
            XCTAssertNil(error);
            XCTAssertEqual(accessToken.token, tokenValidFor15Mins);
            XCTAssertEqual(weakSelf.fetchTokenCallCount, 0);
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:self.timeout handler:^(NSError * _Nullable error) {
        [self failForTimeout:error testName:expectation.expectationDescription];
    }];
}

- (void)test_ShouldGetCalledImmediatelyWithoutInitialToken {
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_ShouldGetCalledImmediatelyWithoutInitialToken"];
    __weak ObjCAutoRefreshOnDemandTokenCredentialTests *weakSelf = self;
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [self createTokenRefreshOptions:weakSelf initialToken:nil refreshedToken:weakSelf.sampleToken];
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                                 NSError * _Nullable error) {
            XCTAssertNotNil(accessToken);
            XCTAssertNil(error);
            XCTAssertEqual(accessToken.token, self.sampleToken);
            XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:self.timeout handler:^(NSError * _Nullable error) {
        [self failForTimeout:error testName:expectation.expectationDescription];
    }];
}

- (void)test_ShouldThrowWhenTokenRefresherThrows {
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_ShouldThrowWhenTokenRefresherThrows"];
    __weak ObjCAutoRefreshOnDemandTokenCredentialTests *weakSelf = self;
    NSString *errorDesc = @"Error while fetching token";
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [[CommunicationTokenRefreshOptions alloc]
                                                initWithInitialToken:self.sampleExpiredToken
                                                refreshProactively:NO
                                                tokenRefresher:^(void (^ block)
                                                                 (NSString * _Nullable token,
                                                                  NSError * _Nullable error)) {
        weakSelf.fetchTokenCallCount += 1;
        NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey: errorDesc};
        NSError *error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:400 userInfo:errorDictionary];
        block(nil, error);
    }];
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                                 NSError * _Nullable error) {
            XCTAssertNotNil(error);
            XCTAssertTrue([error.localizedDescription containsString: errorDesc]);
            XCTAssertNil(accessToken);
            XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:self.timeout handler:^(NSError * _Nullable error) {
        [self failForTimeout:error testName:expectation.expectationDescription];
    }];
}

- (void)test_ShouldThrowExceptionOnExpiredTokenReturn {
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_ShouldThrowExceptionOnExpiredTokenReturn"];
    __weak ObjCAutoRefreshOnDemandTokenCredentialTests *weakSelf = self;
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [self createTokenRefreshOptions:weakSelf initialToken:weakSelf.sampleExpiredToken refreshedToken:weakSelf.sampleExpiredToken];
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                                 NSError * _Nullable error) {
            XCTAssertNotNil(error);
            XCTAssertTrue([error.debugDescription containsString: @"The token returned from the tokenRefresher is expired."]);
            XCTAssertNil(accessToken);
            XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:self.timeout handler:^(NSError * _Nullable error) {
        [self failForTimeout:error testName:expectation.expectationDescription];
    }];
}

- (void)test_ThrowsIfTokenRequestedAfterCancelled {
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_ThrowsIfTokenRequestedAfterCancelled"];
    __weak ObjCAutoRefreshOnDemandTokenCredentialTests *weakSelf = self;
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [self createTokenRefreshOptions:weakSelf initialToken:weakSelf.sampleToken refreshedToken:weakSelf.sampleToken];
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error:nil];
    [credential cancel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                                 NSError * _Nullable error) {
            XCTAssertNotNil(error);
            XCTAssertTrue([error.debugDescription containsString: credentialCancelledError]);
            XCTAssertNil(accessToken);
            XCTAssertEqual(weakSelf.fetchTokenCallCount, 0);
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:self.timeout handler:^(NSError * _Nullable error) {
        [self failForTimeout:error testName:expectation.expectationDescription];
    }];
}

@end
