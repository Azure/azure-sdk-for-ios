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
#import <AzureCommunication/AzureCommunication-Swift.h>
#import <AzureCore/AzureCore-Swift.h>

@interface ObjCCommunicationUserCredentialAsyncTests : XCTestCase
@property (nonatomic, strong) NSString *sampleToken;
@property (nonatomic, strong) NSString *sampleExpiredToken;
@property (nonatomic) double sampleTokenExpiry;
@property (nonatomic) int fetchTokenCallCount;
@end

@implementation ObjCCommunicationUserCredentialAsyncTests

- (void)setUp {
    [super setUp];
    
    self.sampleToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc";
    self.sampleExpiredToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg";
    self.sampleTokenExpiry = 32503680000;
    self.fetchTokenCallCount = 0;
}

- (void)test_ObjCRefreshTokenOnDemand_AsyncRefresh {
    XCTestExpectation *expectation = [self expectationWithDescription:
                                      @"RefreshTokenOnDemand_AsyncRefresh"];
    __weak ObjCCommunicationUserCredentialAsyncTests *weakSelf = self;
    
    CommunicationUserCredential *credential = [[CommunicationUserCredential alloc]
                                               initWithInitialToken:self.sampleExpiredToken
                                               refreshProactively:NO
                                               error:nil
                                               tokenRefresher:
                                               ^(void (^ _Nonnull block)
                                                 (NSString * _Nullable token,
                                                  NSError * _Nullable error)) {
            weakSelf.fetchTokenCallCount += 1;
            block(weakSelf.sampleToken, nil);
    }];
    
    [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(accessToken);
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
        XCTAssertEqual(accessToken.expiresOn.timeIntervalSince1970, weakSelf.sampleTokenExpiry);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:5.0];
}

@end
