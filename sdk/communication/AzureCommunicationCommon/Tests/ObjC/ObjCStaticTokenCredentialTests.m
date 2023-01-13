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

@interface ObjCStaticTokenCredentialTests : XCTestCase
@property (nonatomic, strong) NSString *sampleToken;
@property (nonatomic, strong) NSString *sampleExpiredToken;
@property (nonatomic) double sampleTokenExpiry;
@property (nonatomic) double sampleExpiredTokenExpiry;
@property (nonatomic) NSTimeInterval timeout;
@end

@implementation ObjCStaticTokenCredentialTests

- (void)setUp {
    [super setUp];
        self.sampleToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc";
        self.sampleExpiredToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg";
        self.sampleTokenExpiry = 32503680000;
        self.sampleExpiredTokenExpiry = 100;
        self.timeout = 10.0;
}

- (void)test_StaticTokenCredential_ShouldStoreAnyToken {
    __block BOOL isComplete = NO;

    CommunicationTokenCredential *userCredential = [[CommunicationTokenCredential alloc]
                                                    initWithToken: self.sampleExpiredToken
                                                    error: nil];
    
    [userCredential tokenWithCompletionHandler:^(CommunicationAccessToken *accessToken, NSError * error) {
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, self.sampleExpiredToken);
        XCTAssertEqual(accessToken.expiresOn.timeIntervalSince1970, self.sampleExpiredTokenExpiry);
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

- (void)test_ThrowsIfInvalidToken {
    NSString *invalidTokens = @[@"foo", @"foo.bar", @"foo.bar.foobar"];
    NSError *error = nil;
    for(NSString *invalidToken in invalidTokens){
        CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                    initWithToken:invalidToken
                                                    error:&error];
        XCTAssertNil(credential);
        XCTAssertNotNil(error);
    }
}

@end
