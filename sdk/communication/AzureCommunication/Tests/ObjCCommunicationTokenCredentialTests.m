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

@interface ObjCCommunciationTokenCredentialTests : XCTestCase
@property (nonatomic, strong) NSString *sampleToken;
@property (nonatomic, strong) NSString *sampleExpiredToken;
@property (nonatomic) double sampleTokenExpiry;
@property (nonatomic) int fetchTokenCallCount;
@property (nonatomic) NSTimeInterval timeout;
@end

@implementation ObjCCommunciationTokenCredentialTests

- (void)setUp {
    [super setUp];
    
    self.sampleToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc";
    self.sampleExpiredToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg";
    self.sampleTokenExpiry = 32503680000;
    self.fetchTokenCallCount = 0;
    self.timeout = 10.0;
}

- (void)test_ObjCDecodeToken {
    __block BOOL isComplete = NO;

    CommunicationTokenCredential *userCredential = [[CommunicationTokenCredential alloc]
                                                    initWithToken: self.sampleToken
                                                    error: nil];
    
    [userCredential tokenWithCompletionHandler:^(CommunicationAccessToken *accessToken, NSError * error) {
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, self.sampleToken);
        XCTAssertEqual(accessToken.expiresOn.timeIntervalSince1970, self.sampleTokenExpiry);
        isComplete = YES;
    }];

    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow: self.timeout];
    while (isComplete == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }
    
    if (!isComplete) {
        XCTFail(@"test_ObjCDecodeToken timeout exceeded");
    }
}

- (void)test_ObjCRefreshTokenProactively_TokenAlreadyExpired {
    __weak ObjCCommunciationTokenCredentialTests *weakSelf = self;
    __block BOOL isComplete = NO;
    
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [[CommunicationTokenRefreshOptions alloc]
                                                initWithInitialToken:self.sampleExpiredToken
                                                refreshProactively:YES
                                                tokenRefresher:^(void (^ block)
                                                                 (NSString * _Nullable accessToken,
                                                                  NSError * _Nullable error)) {
        weakSelf.fetchTokenCallCount += 1;
        block(weakSelf.sampleToken, nil);
    }];
    
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error:nil];
    
    [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(accessToken);
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
        XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
        
        isComplete = YES;
    }];
    
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow: self.timeout];
    while (isComplete == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }
    
    if (!isComplete) {
        XCTFail(@"test_ObjCRefreshTokenProactively_TokenAlreadyExpired timeout exceeded");
    }
}

- (void)test_ObjCRefreshTokenProactively_FetchTokenReturnsError {
    __weak ObjCCommunciationTokenCredentialTests *weakSelf = self;
    __block BOOL isComplete = NO;
    NSString *errorDesc = @"Error while fetching token";
    
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [[CommunicationTokenRefreshOptions alloc]
                                                initWithInitialToken:self.sampleExpiredToken
                                                refreshProactively:YES
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
    
    [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertEqual([error.localizedDescription containsString: errorDesc], YES);
        XCTAssertNil(accessToken);
        XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
        
        isComplete = YES;
    }];
    

    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow: self.timeout];
    while (isComplete == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }

    if (!isComplete) {
        XCTFail(@"test_ObjCRefreshTokenProactively_FetchTokenReturnsError timeout exceeded");
    }
}

@end
