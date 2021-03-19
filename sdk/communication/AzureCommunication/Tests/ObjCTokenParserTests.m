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

@interface ObjCTokenParserTests : XCTestCase

@end

@implementation ObjCTokenParserTests

- (void)test_ObjCThrowsIfInvalidTokenFoo {
    NSString *invalidFoo = @"foo";
    NSError *error = nil;
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithToken:invalidFoo
                                                error:&error];
    XCTAssertNil(credential);
    XCTAssertNotNil(error);
}

- (void)test_ObjCThrowsIfInvalidTokenFormat {
    NSString *invalidToken = @"foo.bar.foobar";
    NSError *error = nil;
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithToken:invalidToken
                                                error:&error];
    XCTAssertNil(credential);
    XCTAssertNotNil(error);
}

- (void)test_ObjCThrowsWhenInitWithBlock {
    NSString *invalidToken = @"foo.bar";
    NSError *error = nil;
    
    CommunicationTokenRefreshOptions *tokenRefreshOptions = [[CommunicationTokenRefreshOptions alloc]
                                                initWithInitialToken:invalidToken
                                                refreshProactively:YES
                                                tokenRefresher:^(void (^ _Nonnull block)
                                                                 (NSString * _Nullable token,
                                                                  NSError * _Nullable error)) {
    }];
    
    CommunicationTokenCredential *credential = [[CommunicationTokenCredential alloc]
                                                initWithOptions: tokenRefreshOptions
                                                error:&error];
    
    XCTAssertNil(credential);
    XCTAssertNotNil(error);
}

@end
