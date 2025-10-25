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

@implementation ObjCStaticTokenCredentialTests: ObjCCommunicationTokenCredentialTests

- (void)test_StaticTokenCredential_ShouldStoreAnyToken {
    CommunicationTokenCredential *userCredential = [[CommunicationTokenCredential alloc]
                                                    initWithToken: self.sampleExpiredToken
                                                    error: nil];
    
    [userCredential tokenWithCompletionHandler:^(CommunicationAccessToken *accessToken, NSError * error) {
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, self.sampleExpiredToken);
        XCTAssertEqual(accessToken.expiresOn.timeIntervalSince1970, self.sampleExpiredTokenExpiry);
    }];
}


- (void)test_ObjCDecodeToken {
    CommunicationTokenCredential *userCredential = [[CommunicationTokenCredential alloc]
                                                    initWithToken: self.sampleToken
                                                    error: nil];
    
    [userCredential tokenWithCompletionHandler:^(CommunicationAccessToken *accessToken, NSError * error) {
        XCTAssertNil(error);
        XCTAssertEqual(accessToken.token, self.sampleToken);
        XCTAssertEqual(accessToken.expiresOn.timeIntervalSince1970, self.sampleTokenExpiry);
    }];
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

- (void)test_ThrowsIfTokenRequestedAfterCancelled {
    CommunicationTokenCredential *userCredential = [[CommunicationTokenCredential alloc]
                                                    initWithToken: self.sampleToken
                                                    error: nil];
    [userCredential cancel];
    [userCredential tokenWithCompletionHandler:^(CommunicationAccessToken *accessToken, NSError * error) {
        XCTAssertNil(accessToken);
        XCTAssertNotNil(error);
        XCTAssertTrue([error.debugDescription containsString:credentialCancelledError]);
    }];
}
@end
