//
//  TVHLogStore.m
//  TvhClient
//
//  Created by zipleen on 09/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHLogStore.h"

@interface TVHLogStore()
@property (nonatomic, strong) NSMutableArray *logLines;
@property (nonatomic, weak) id <TVHLogDelegate> delegate;
@end

@implementation TVHLogStore

+ (id)sharedInstance {
    static TVHLogStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHLogStore alloc] init];
    });
    
    return __sharedInstance;
}

- (id) init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDebugLogNotification:)
                                                 name:@"logmessageNotificationClassReceived"
                                               object:nil];

    
    return self;
}

- (void) dealloc {
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) receiveDebugLogNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"logmessageNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        NSString *log = [message objectForKey:@"logtxt"];
        [self.logLines addObject:log];
        [self.delegate didLoadLog];
    }
}

- (NSString *) objectAtIndex:(int) row {
    return [self.logLines objectAtIndex:row];
}

- (int) count {
    return [self.logLines count];
}

- (void)setDelegate:(id <TVHLogDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}
@end