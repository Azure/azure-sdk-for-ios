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

#import <Foundation/Foundation.h>
#import "AzureCommunicationCommon/AzureCommunicationCommon-Swift.h"
#import "CommunicationIdentifierFactory.h"

@implementation CommunicationIdentifierFactory
+ (id<CommunicationIdentifier>)createCommunicationIdentifier: (NSString *) rawId {
    NSString* phoneNumberPrefix = @"4:";
    NSString* teamUserAnonymousPrefix = @"8:teamsvisitor:";
    NSString* teamUserPublicCloudPrefix = @"8:orgid:";
    NSString* teamUserDODCloudPrefix = @"8:dod:";
    NSString* teamUserGCCHCloudPrefix = @"8:gcch:";
    NSString* acsUser = @"8:acs:";
    NSString* spoolUser = @"8:spool:";
    NSString* dodAcsUser = @"8:dod-acs:";
    NSString* gcchAcsUser = @"8:gcch-acs:";
    
    if ([rawId hasPrefix:phoneNumberPrefix]) {
        NSString *formattedPhone = [rawId stringByReplacingOccurrencesOfString:phoneNumberPrefix
                                                                    withString:@""];
        NSString *phoneNumber = [[NSString alloc] initWithFormat:@"+%@", formattedPhone];
        return [[PhoneNumberIdentifier alloc] initWithPhoneNumber:phoneNumber
                                                            rawId:rawId];
    }
    
    NSArray<NSString *> *segments = [rawId componentsSeparatedByString:@":"];
    if (segments.count < 3) {
        return [[UnknownIdentifier alloc] initWithIdentifier:rawId];
    }

    NSString *scope = [[NSString alloc] initWithFormat:@"%@:%@:",
                       [segments objectAtIndex: 0],
                       [segments objectAtIndex: 1]];
    
    NSString *suffix = [[NSString alloc] initWithFormat:@"%@", [rawId stringByReplacingOccurrencesOfString:scope
                                                                                                withString:@""]];
    if ([scope isEqualToString: teamUserAnonymousPrefix]) {
        return [[MicrosoftTeamsUserIdentifier alloc] initWithUserId:suffix
                                                        isAnonymous:true
                                                              rawId:nil
                                                   cloudEnvironment:CommunicationCloudEnvironment.Public];
    } else if ([scope isEqualToString: teamUserPublicCloudPrefix]) {
        return [[MicrosoftTeamsUserIdentifier alloc] initWithUserId:suffix
                                                        isAnonymous:false
                                                              rawId:rawId
                                                   cloudEnvironment:CommunicationCloudEnvironment.Public];
    } else if ([scope isEqualToString: teamUserDODCloudPrefix]) {
        return [[MicrosoftTeamsUserIdentifier alloc] initWithUserId:suffix
                                                        isAnonymous:false
                                                              rawId:rawId
                                                   cloudEnvironment:CommunicationCloudEnvironment.Dod];
    } else if ([scope isEqualToString:teamUserGCCHCloudPrefix]) {
        return [[MicrosoftTeamsUserIdentifier alloc] initWithUserId:suffix
                                                        isAnonymous:false
                                                              rawId:rawId
                                                   cloudEnvironment:CommunicationCloudEnvironment.Gcch];
    } else if ([scope isEqualToString:acsUser] ||
               [scope isEqualToString:spoolUser] ||
               [scope isEqualToString:dodAcsUser] ||
               [scope isEqualToString:gcchAcsUser]) {
        return [[CommunicationUserIdentifier alloc] initWithIdentifier:rawId];
    } else {
        return [[UnknownIdentifier alloc] initWithIdentifier:rawId];
    }
}

@end
