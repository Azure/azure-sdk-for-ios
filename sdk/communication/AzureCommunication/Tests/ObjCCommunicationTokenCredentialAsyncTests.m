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

@interface ObjCCommunicationTokenCredentialAsyncTests : XCTestCase
@property (nonatomic, strong) NSString *sampleToken;
@property (nonatomic) int fetchTokenCallCount;
@property (nonatomic) NSTimeInterval timeout;
@end

@implementation ObjCCommunicationTokenCredentialAsyncTests

NSString const * kSampleTokenHeader = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9";
NSString const * kSampleTokenSignature = @"adM-ddBZZlQ1WlN3pdPBOF5G4Wh9iZpxNP_fSvpF4cWs";

- (void)setUp {
    [super setUp];
    
    self.sampleToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc";
    self.fetchTokenCallCount = 0;
    self.timeout = 10.0;
}

- (void)test_ObjCRefreshTokenProactivelyTokenExpiringInOneMin {
    __weak ObjCCommunicationTokenCredentialAsyncTests *weakSelf = self;
    __block BOOL isComplete = NO;
    
    NSString *token = [self generateTokenValidForMinutes: 1];
    
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [[CommunicationTokenRefreshOptions alloc]
                                                initWithInitialToken:token
                                                refreshProactively:YES
                                                tokenRefresher:
                                                ^(void (^ block)
                                                  (NSString * _Nullable newToken,
                                                   NSError * _Nullable error)) {
        weakSelf.fetchTokenCallCount += 1;
        block(weakSelf.sampleToken, nil);
    }];
    
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error: nil];
    
    [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(accessToken);
        XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
        XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
        
        isComplete = YES;
    }];


    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow: self.timeout];
    while (isComplete == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }

    if (!isComplete) {
        XCTFail(@"test_ObjCRefreshTokenProactivelyTokenExpiringInOneMin timeout exceeded");
    }
}

- (void)test_ObjCRefreshTokenProactivelyTokenExpiringInNineMin {
    __weak ObjCCommunicationTokenCredentialAsyncTests *weakSelf = self;
    __block BOOL isComplete = NO;
    
    NSString *token = [self generateTokenValidForMinutes: 9];
    
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [[CommunicationTokenRefreshOptions alloc]
                                                initWithInitialToken:token
                                                refreshProactively:YES
                                                tokenRefresher:
                                                ^(void (^ block)
                                                  (NSString * _Nullable newToken,
                                                   NSError * _Nullable error)) {
        weakSelf.fetchTokenCallCount += 1;
        block(weakSelf.sampleToken, nil);
    }];
    
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions:tokenRefreshOptions
                                                error:nil];
    
    [credential tokenWithCompletionHandler:^(CommunicationAccessToken * _Nullable accessToken,
                                             NSError * _Nullable error) {
        XCTAssertNotNil(accessToken);
        XCTAssertEqual(accessToken.token, weakSelf.sampleToken);
        XCTAssertEqual(weakSelf.fetchTokenCallCount, 1);
        
        isComplete = YES;
    }];

    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow: self.timeout];
    while (isComplete == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }

    if (!isComplete) {
        XCTFail(@"test_ObjCRefreshTokenProactivelyTokenExpiringInNineMin timeout exceeded");
    }
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
