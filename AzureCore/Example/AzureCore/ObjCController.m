//
//  ObjCController.m
//  AzureCore_Example
//
//  Created by Travis Prescott on 8/22/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

@import AzureCore;

#import "AzureCore_Example-Swift.h"
#import "ObjCController.h"


@implementation ObjCController

+ (void)test {
    HttpHeader *header = [[HttpHeader alloc] initWithHeader:HttpHeaderTypeUserAgent value:@"Blargamuffin"];
    NSLog(@"%@", header);
}

@end
