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
#import "ObjCCommunicationTokenCredentialTests.h"

NSString *const credentialCancelledError = @"An instance of CommunicationTokenCredential cannot be reused once it has been canceled.";

@implementation ObjCCommunicationTokenCredentialTests

- (void)setUp {
    self.sampleToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc";
    self.sampleExpiredToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEwMH0.1h_scYkNp-G98-O4cW6KvfJZwiz54uJMyeDACE4nypg";
    self.sampleTokenExpiry = 32503680000;
    self.sampleExpiredTokenExpiry = 100;
    self.fetchTokenCallCount = 0;
    self.timeout = 10.0;
}

- (void)failForTimeout:(NSError * _Nullable) error testName:(NSString *)testName {
    if(error != NULL){
        XCTFail(@"%@ timeout exceeded!", testName);
    }
}

- (NSString *)generateTokenValidForSeconds: (int) seconds {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    NSDate *currentDate = [NSDate date];
    NSString *d = [dateFormatter stringFromDate:currentDate];
    NSDate *expiresOn = [[dateFormatter dateFromString:d]
                        dateByAddingTimeInterval:(seconds)];
    NSTimeInterval timeInterval = [expiresOn timeIntervalSince1970];
    NSString *tokenString = [NSString stringWithFormat:@"{\"exp\":%f}", timeInterval];
    NSData *tokenStringData = [tokenString dataUsingEncoding: NSASCIIStringEncoding];
    NSString *kSampleTokenHeader = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9";
    NSString *kSampleTokenSignature = @"adM-ddBZZlQ1WlN3pdPBOF5G4Wh9iZpxNP_fSvpF4cWs";
    NSString *validToken = [NSString stringWithFormat:@"%@.%@.%@",
                            kSampleTokenHeader,
                            [tokenStringData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength],
                            kSampleTokenSignature];
    
    return validToken;
}

@end
