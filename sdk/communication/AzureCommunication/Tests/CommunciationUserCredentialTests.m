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

@interface CommunciationUserCredentialTests : XCTestCase
@property (nonatomic, strong) NSString *sampleToken;
@property (nonatomic, strong) NSString *sampleExpiredToken;
@property (nonatomic) double sampleTokenExpiry;
@property (nonatomic) int fetchTokenCallCount;
@end

@implementation CommunciationUserCredentialTests

- (void)setUp {
    [super setUp];
    
    self.sampleToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc";
    self.sampleExpiredToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg";
    self.sampleTokenExpiry = 32503680000;
    self.fetchTokenCallCount = 0;
}

- (void)test_ObjCDecodeToken {
    CommunicationUserCredential *userCredential = [[CommunicationUserCredential alloc] initWithToken: self.sampleToken
                                                                                               error: nil];
    
    [userCredential tokenWithCompletionHandler:^(AccessToken *accessToken, NSError * error) {
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, self.sampleToken);
        XCTAssertEqual(accessToken.expiresOn.timeIntervalSince1970, self.sampleTokenExpiry);
    }];
}

- (void)test_ObjCThrowsIfInvalidToken {
    NSArray<NSString *> *invalidTokens = @[@"foo",
                                           @"foo.bar",
                                           @"foo.bar.foobar"];
    
    for (int i = 0; i < invalidTokens.count; i++) {
        NSString *token = [invalidTokens objectAtIndex: i];
        CommunicationUserCredential *credential = [[CommunicationUserCredential alloc] initWithToken:token error:nil];
        XCTAssertNil(credential);
    }
}

- (void)test_ObjCRefreshTokenProactively_TokenAlreadyExpired {
    XCTestExpectation *expectation = [self expectationWithDescription:
                                      @"RefreshTokenProactively_TokenAlreadyExpired"];
    __weak CommunciationUserCredentialTests *weakSelf = self;
    
    CommunicationUserCredential *credential = [[CommunicationUserCredential alloc]
                                               initWithInitialToken:self.sampleExpiredToken
                                               refreshProactively:YES
                                               error:nil
                                               tokenRefresher:^(void (^ block)
                                                                (NSString * _Nullable accessToken,
                                                                 NSError * _Nullable error)) {
        weakSelf.fetchTokenCallCount += 1;
        block(weakSelf.sampleToken, nil);
    }];
    
    [credential tokenWithCompletionHandler:^(AccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(accessToken);
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
        XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:2.0];
}

- (void)test_ObjCRefreshTokenProactively_FetchTokenReturnsError {
    XCTestExpectation *expectation = [self expectationWithDescription:
                                      @"RefreshTokenProactively_FetchTokenReturnsError"];
    __weak CommunciationUserCredentialTests *weakSelf = self;
    NSString *errorDesc = @"Error while fetching token";
    CommunicationUserCredential *credential = [[CommunicationUserCredential alloc]
                                               initWithInitialToken:self.sampleExpiredToken
                                               refreshProactively:YES
                                               error:nil
                                               tokenRefresher:^(void (^ block)
                                                                (NSString * _Nullable token,
                                                                 NSError * _Nullable error)) {
        weakSelf.fetchTokenCallCount += 1;
        
        NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey: errorDesc};
        NSError *error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:400 userInfo:errorDictionary];
        
        block(nil, error);
    }];
    
    [credential tokenWithCompletionHandler:^(AccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertEqual([error.localizedDescription containsString: errorDesc], YES);
        XCTAssertNil(accessToken);
        XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:2.0];
}

- (void)test_ObjCRefreshTokenProactively_TokenExpiringSoon {
    NSArray<NSNumber *> *testCases = @[@1, @9];
    XCTestExpectation *expectation = [self expectationWithDescription:
                                      @"RefreshTokenProactively_TokenExpiringSoon"];
    __weak CommunciationUserCredentialTests *weakSelf = self;
    
    for (int i = 0; i < testCases.count; i++) {
        [self setUp];
        NSString *token = [self generateTokenValidForMinutes:testCases[i]];
        CommunicationUserCredential *credential = [[CommunicationUserCredential alloc]
                                                   initWithInitialToken:token
                                                   refreshProactively:YES
                                                   error:nil
                                                   tokenRefresher:
                                                   ^(void (^ block)
                                                     (NSString * _Nullable newToken,
                                                      NSError * _Nullable error)) {
            weakSelf.fetchTokenCallCount += 1;
            block(weakSelf.sampleToken, nil);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [credential tokenWithCompletionHandler:^(AccessToken * _Nullable accessToken,
                                                     NSError * _Nullable error) {
                XCTAssertNotNil(accessToken);
                XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
                
                if (i == testCases.count - 1) {
                    [expectation fulfill];
                }
            }];
        });
    }
    
    [self waitForExpectations:@[expectation] timeout:2.0];
}

- (void)test_ObjCRefreshTokenOnDemand_AsyncRefresh {
    XCTestExpectation *expectation = [self expectationWithDescription:
                                      @"RefreshTokenOnDemand_AsyncRefresh"];
    __weak CommunciationUserCredentialTests *weakSelf = self;
    
    CommunicationUserCredential *credential = [[CommunicationUserCredential alloc]
                                               initWithInitialToken:self.sampleExpiredToken
                                               refreshProactively:NO
                                               error:nil
                                               tokenRefresher:
                                               ^(void (^ _Nonnull block)
                                                 (NSString * _Nullable token,
                                                  NSError * _Nullable error)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            weakSelf.fetchTokenCallCount += 1;
            block(weakSelf.sampleToken, nil);
        });
    }];
    
    [credential tokenWithCompletionHandler:^(AccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(accessToken);
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
        XCTAssertEqual(accessToken.expiresOn.timeIntervalSince1970, weakSelf.sampleTokenExpiry);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:5.0];
}

- (NSString *)generateTokenValidForMinutes: (NSNumber *) minutes {
    NSString *d = @"2020-10-20T10:20:28+0000";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    
    NSDate *rightNow = [[dateFormatter dateFromString:d]
                        dateByAddingTimeInterval:(60 * minutes.intValue)];
    NSTimeInterval timeInterval = [rightNow timeIntervalSince1970];
    NSString *tokenString = [NSString stringWithFormat:@"{\"exp\":%f}", timeInterval];
    NSData *tokenStringData = [tokenString dataUsingEncoding: NSASCIIStringEncoding];

    NSString *validToken = [NSString stringWithFormat:@"%@.%@.%@",
                            @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
                            [tokenStringData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength],
                            @"adM-ddBZZlQ1WlN3pdPBOF5G4Wh9iZpxNP_fSvpF4cWs"];
    
    return validToken;
}

@end
