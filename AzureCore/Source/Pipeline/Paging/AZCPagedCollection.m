//
//  AZCPagedCollection.m
//  AzureCore
//
//  Created by Travis Prescott on 9/16/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZCPagedCollection.h"

@implementation AZCPagedCollection: NSObject

NSArray *_items;
NSString *_nextLink;

-(id)initWithItems:(NSArray *)items withNextLink:(nullable NSString *)nextLink {
    _items = items;
    _nextLink = nextLink;
    return self;
}

- (NSObject *)getNextItem {
    // TODO: Implement
    return nil;
}

- (NSArray *)getNextPage {
    // TODO: Implement
    return nil;
}

- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained * _Nonnull)buffer count:(NSUInteger)len {
    return [_items countByEnumeratingWithState:state objects:buffer count:len];
}

@end
