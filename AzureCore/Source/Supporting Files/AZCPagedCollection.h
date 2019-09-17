//
//  AZCPagedCollection.h
//  AzureCore
//
//  Created by Travis Prescott on 9/16/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AZCPagedCollection : NSObject<NSFastEnumeration>

-(id)initWithItems:(NSArray *)items withNextLink:(nullable NSString *)nextLink;
-(NSObject *)getNextItem;
-(NSArray *)getNextPage;

@end

NS_ASSUME_NONNULL_END
