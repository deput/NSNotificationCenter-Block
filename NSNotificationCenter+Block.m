//
//  NSNotificationCenter+Block.m
//  RW
//
//  Created by deput on 2/8/16.
//  Copyright © 2016 rw. All rights reserved.
//

#import "NSNotificationCenter+Block.h"

@interface NotificationBlockToken : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) BOOL autoRemove;
@property(nonatomic, copy) NotificationBlock block;
@property(nonatomic, retain) id object;
@end

@implementation NotificationBlockToken

+ (instancetype)tokenFromName:(NSString *)name autoRemove:(BOOL)autoRemove block:(NotificationBlock)block object:(id)object {
    NotificationBlockToken *token = [NotificationBlockToken new];
    token.autoRemove = autoRemove;
    token.name = name;
    token.block = block;
    token.object = object;
    return token;
}
@end

static NSMutableDictionary<NSString *, NSMutableArray<NotificationBlockToken *> *> *dict;

@implementation NSNotificationCenter (Block)
- (void)addBlockObserver:(NotificationBlock)block name:(NSString *)aName object:(id)anObject {
    [self addBlockObserver:block name:aName object:aName autoRemove:NO];
}

- (void)addBlockObserver:(NotificationBlock)block name:(NSString *)aName object:(id)anObject autoRemove:(BOOL)flag; {
    dispatch_async(dispatch_get_main_queue(), ^{

        if (dict == nil) {
            dict = @{}.mutableCopy;
        }
        if (dict[aName].count == 0) {
            [self addObserver:self selector:@selector(rw_handleNotification:) name:aName object:nil];
        }
        if (dict[aName] == nil) {
            dict[aName] = @[].mutableCopy;
        }
        __block BOOL createANew = YES;
        [dict[aName] enumerateObjectsUsingBlock:^(NotificationBlockToken *_Nonnull token, NSUInteger idx, BOOL *_Nonnull stop) {
            if (token.block == block) {
                *stop = YES;
                createANew = NO;
                token.autoRemove = flag;
                token.object = anObject;
            }
        }];
        if (createANew) {
            [dict[aName] addObject:[NotificationBlockToken tokenFromName:aName autoRemove:flag block:block object:anObject]];
        }
    });
}

- (void)removeAllBlockObserversByName:(NSString *)aName {
    [self removeBlockObserver:nil name:aName object:nil];
}

- (void)removeBlockObserver:(NotificationBlock)block name:(NSString *)aName object:(id)anObject {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!block) {
            [dict[aName] removeAllObjects];
        } else {
            NSMutableArray<NotificationBlockToken *> *tokens = dict[aName];
            NSMutableArray *tokensToRemove = @[].mutableCopy;
            [tokens enumerateObjectsUsingBlock:^(NotificationBlockToken *_Nonnull token, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([token.name isEqualToString:aName] &&
                        (token.object == nil || token.object == anObject)) {
                    [tokensToRemove addObject:token];
                }
            }];
            [dict[aName] removeObjectsInArray:tokensToRemove];
        }
        if (!block || dict[aName].count == 0) {
            [self removeObserver:self name:aName object:nil];
        }
    });
}

- (void)rw_handleNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *tokensToRemove = @[].mutableCopy;
        [dict[[notification name]] enumerateObjectsUsingBlock:^(NotificationBlockToken *_Nonnull token, NSUInteger idx, BOOL *_Nonnull stop) {
            if (token.object == nil || token.object == notification.object) {
                token.block(notification);
                if (token.autoRemove) {
                    [tokensToRemove addObject:token];
                }
            }
        }];
        [dict[notification.name] removeObjectsInArray:tokensToRemove];
        if (dict[notification.name].count == 0) {
            [self removeObserver:self name:notification.name object:nil];
        }
    });
}
@end
