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

NSString const * kSampleTokenHeader = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9";
NSString const * kSampleTokenSignature = @"adM-ddBZZlQ1WlN3pdPBOF5G4Wh9iZpxNP_fSvpF4cWs";

- (void)setUp {
    [super setUp];
    
    self.sampleToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc";
    self.sampleExpiredToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg";
    self.sampleTokenExpiry = 32503680000;
    self.fetchTokenCallCount = 0;
}

- (void)test_ObjCRefreshTokenProactively_TokenExpiringInOneMin {
    XCTestExpectation *expectation = [self expectationWithDescription:
                                      @"RefreshTokenProactively_TokenExpiringInOneMin"];
    __weak ObjCCommunicationUserCredentialAsyncTests *weakSelf = self;
    
    NSString *token = [self generateTokenValidForMinutes: 1];
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
    
    [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(accessToken);
        XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
        XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
        
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:2.0];
}

- (void)test_ObjCRefreshTokenProactively_TokenExpiringInNineMin {
    XCTestExpectation *expectation = [self expectationWithDescription:
                                      @"RefreshTokenProactively_TokenExpiringInNineMin"];
    __weak ObjCCommunicationUserCredentialAsyncTests *weakSelf = self;
    
    NSString *token = [self generateTokenValidForMinutes: 9];
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
    
    [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(accessToken);
        XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
        XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
        
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:2.0];
}

- (NSString *)generateTokenValidForMinutes: (int) minutes {
    NSString *d = @"2020-10-20T10:20:28+0000";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    
    NSDate *rightNow = [[dateFormatter dateFromString:d]
                        dateByAddingTimeInterval:(60 * minutes)];
    NSTimeInterval timeInterval = [rightNow timeIntervalSince1970];
    NSString *tokenString = [NSString stringWithFormat:@"{\"exp\":%f}", timeInterval];
    NSData *tokenStringData = [tokenString dataUsingEncoding: NSASCIIStringEncoding];

    NSString *validToken = [NSString stringWithFormat:@"%@.%@.%@",
                            kSampleTokenHeader,
                            [tokenStringData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength],
                            kSampleTokenSignature];
    
    return validToken;
}

@end
