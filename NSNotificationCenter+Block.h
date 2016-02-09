//
//  NSNotificationCenter+Block.h
//  RW
//
//  Created by deput on 2/8/16.
//  Copyright © 2016 rw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NotificationBlock )(NSNotification *notification);

@interface NSNotificationCenter (Block)
- (void)addBlockObserver:(NotificationBlock)block name:(NSString *)aName object:(id)anObject;

- (void)addBlockObserver:(NotificationBlock)block name:(NSString *)aName object:(id)anObject autoRemove:(BOOL)flag;

- (void)removeBlockObserver:(NotificationBlock)block name:(NSString *)aName object:(id)anObject;

- (void)removeAllBlockObserversByName:(NSString *)aName;
@end
