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
#import "AzureCommunicationCommon/AzureCommunicationCommon-Swift.h"
#import "CommunicationIdentifierFactory.h"

@interface CommunicationIdentifierFactoryTests : XCTestCase
@end

@implementation CommunicationIdentifierFactoryTests
- (void)test_createUnknownIdentifier {
    id<CommunicationIdentifier> identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:@"37691ec4-57fb-4c0f-ae31-32791610cb14"];
    XCTAssertTrue([identifier isKindOfClass:UnknownIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.Unknown);
    XCTAssertEqual(identifier.rawId, @"37691ec4-57fb-4c0f-ae31-32791610cb14");
    
    identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:@"48:37691ec4-57fb-4c0f-ae31-32791610cb14"];
    XCTAssertTrue([identifier isKindOfClass:UnknownIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.Unknown);
    XCTAssertEqual(identifier.rawId, @"48:37691ec4-57fb-4c0f-ae31-32791610cb14");
}

- (void)test_createPhoneNumberIdentifier {
    NSString *phoneNumberRawId = @"4:12345556789";
    id<CommunicationIdentifier> identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:phoneNumberRawId];
    XCTAssertTrue([identifier isKindOfClass:PhoneNumberIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.PhoneNumber);
    XCTAssertEqual(identifier.rawId, phoneNumberRawId);
    XCTAssertEqualObjects(((PhoneNumberIdentifier *)identifier).phoneNumber, @"+12345556789");
}

-(void)test_createCommunicationUserIdentifier {
    NSString *acsRawId = @"8:acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14";
    id<CommunicationIdentifier> identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:acsRawId];
    XCTAssertTrue([identifier isKindOfClass:CommunicationUserIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.CommunicationUser);
    XCTAssertEqualObjects(identifier.rawId, acsRawId);
    XCTAssertEqualObjects(((CommunicationUserIdentifier *)identifier).identifier, acsRawId);
    
    NSString *spoolRawId = @"8:spool:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14";
    identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:spoolRawId];
    XCTAssertTrue([identifier isKindOfClass:CommunicationUserIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.CommunicationUser);
    XCTAssertEqualObjects(identifier.rawId, spoolRawId);
    XCTAssertEqualObjects(((CommunicationUserIdentifier *)identifier).identifier, spoolRawId);
    
    NSString* dodAcsRawId = @"8:dod-acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14";
    identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:dodAcsRawId];
    XCTAssertTrue([identifier isKindOfClass:CommunicationUserIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.CommunicationUser);
    XCTAssertEqualObjects(identifier.rawId, dodAcsRawId);
    XCTAssertEqualObjects(((CommunicationUserIdentifier *)identifier).identifier, dodAcsRawId);
    
    NSString* gcchAcsRawId = @"8:gcch-acs:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14";
    identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:gcchAcsRawId];
    XCTAssertTrue([identifier isKindOfClass:CommunicationUserIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.CommunicationUser);
    XCTAssertEqualObjects(identifier.rawId, gcchAcsRawId);
    XCTAssertEqualObjects(((CommunicationUserIdentifier *)identifier).identifier, gcchAcsRawId);
}

-(void)test_createMicrosoftTeamsUserIdentifierAnonymousScope {
    NSString *teamUserAnonymousScope = @"8:teamsvisitor:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14";
    id<CommunicationIdentifier> identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:teamUserAnonymousScope];
    XCTAssertTrue([identifier isKindOfClass:MicrosoftTeamsUserIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.MicrosoftTeamsUser);
    XCTAssertEqualObjects(identifier.rawId, teamUserAnonymousScope);
    XCTAssertEqualObjects(((MicrosoftTeamsUserIdentifier *)identifier).userId, @"37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14");
    XCTAssertTrue(((MicrosoftTeamsUserIdentifier *)identifier).isAnonymous);
    XCTAssertEqual(((MicrosoftTeamsUserIdentifier *)identifier).cloudEnviroment, CommunicationCloudEnvironment.Public);
}

-(void)test_createMicrosoftTeamsUserIdentifierPublicScope {
    NSString *teamUserPublicCloudScope = @"8:orgid:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14";
    id<CommunicationIdentifier> identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:teamUserPublicCloudScope];
    XCTAssertTrue([identifier isKindOfClass:MicrosoftTeamsUserIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.MicrosoftTeamsUser);
    XCTAssertEqualObjects(identifier.rawId, teamUserPublicCloudScope);
    XCTAssertEqualObjects(((MicrosoftTeamsUserIdentifier *)identifier).userId, @"37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14");
    XCTAssertFalse(((MicrosoftTeamsUserIdentifier *)identifier).isAnonymous);
    XCTAssertEqual(((MicrosoftTeamsUserIdentifier *)identifier).cloudEnviroment, CommunicationCloudEnvironment.Public);
}

-(void)test_createMicrosoftTeamsUserIdentifierDODScope {
    NSString *teamUserDODCloudScope = @"8:dod:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14";
    id<CommunicationIdentifier> identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:teamUserDODCloudScope];
    XCTAssertTrue([identifier isKindOfClass:MicrosoftTeamsUserIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.MicrosoftTeamsUser);
    XCTAssertEqualObjects(identifier.rawId, teamUserDODCloudScope);
    XCTAssertEqualObjects(((MicrosoftTeamsUserIdentifier *)identifier).userId, @"37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14");
    XCTAssertFalse(((MicrosoftTeamsUserIdentifier *)identifier).isAnonymous);
    XCTAssertEqual(((MicrosoftTeamsUserIdentifier *)identifier).cloudEnviroment, CommunicationCloudEnvironment.Dod);
}

-(void)test_createMicrosoftTeamsUserIdentifierGCCHScope {
    NSString *teamUserGCCHCloudScope = @"8:gcch:37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14";
    id<CommunicationIdentifier> identifier = [CommunicationIdentifierFactory createCommunicationIdentifier:teamUserGCCHCloudScope];
    XCTAssertTrue([identifier isKindOfClass:MicrosoftTeamsUserIdentifier.class]);
    XCTAssertEqual(identifier.kind, IdentifierKind.MicrosoftTeamsUser);
    XCTAssertEqualObjects(identifier.rawId, teamUserGCCHCloudScope);
    XCTAssertEqualObjects(((MicrosoftTeamsUserIdentifier *)identifier).userId, @"37691ec4-57fb-4c0f-ae31-32791610cb14_37691ec4-57fb-4c0f-ae31-32791610cb14");
    XCTAssertFalse(((MicrosoftTeamsUserIdentifier *)identifier).isAnonymous);
    XCTAssertEqual(((MicrosoftTeamsUserIdentifier *)identifier).cloudEnviroment, CommunicationCloudEnvironment.Gcch);
}

@end
