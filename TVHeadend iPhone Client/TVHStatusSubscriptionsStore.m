//
//  TVHStatusSubscriptionsStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHStatusSubscriptionsStore.h"
#import "TVHJsonClient.h"

@interface TVHStatusSubscriptionsStore()
@property (nonatomic, strong) NSArray *subscriptions;
@property (nonatomic, weak) id <TVHStatusSubscriptionsDelegate> delegate;
@end

@implementation TVHStatusSubscriptionsStore
@synthesize subscriptions = _subscriptions;
@synthesize delegate = _delegate;

- (id) init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSubscriptionNotification:)
                                                 name:@"subscriptionsNotificationClassReceived"
                                               object:nil];
    
    return self;
}

- (void) dealloc {
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) receiveSubscriptionNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"subscriptionsNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        [self.subscriptions enumerateObjectsUsingBlock:^(TVHStatusSubscription* obj, NSUInteger idx, BOOL *stop) {
            
            if ( obj.id == [[message objectForKey:@"id"] intValue] ) {
                [obj updateValuesFromDictionary:message];
            }
        }];
        [self.delegate didLoadStatusSubscriptions];
    }
}

+ (id)sharedInstance {
    static TVHStatusSubscriptionsStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHStatusSubscriptionsStore alloc] init];
    });
    
    return __sharedInstance;
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:error];
    if( error ) {
        if ([self.delegate respondsToSelector:@selector(didErrorStatusSubscriptionsStore:)]) {
            [self.delegate didErrorStatusSubscriptionsStore:error];
        }
        return ;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *subscriptions = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHStatusSubscription *subscription = [[TVHStatusSubscription alloc] init];
        [subscription updateValuesFromDictionary:obj];
        
        [subscriptions addObject:subscription];
    }];
    
    self.subscriptions = [subscriptions copy];
    
#if DEBUG
    NSLog(@"[Loaded Subscription]: %d", [self.subscriptions count]);
#endif
}

- (void)fetchStatusSubscriptions {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    [httpClient getPath:@"/subscriptions" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        [self.delegate didLoadStatusSubscriptions];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingTagStore:)]) {
            [self.delegate didErrorStatusSubscriptionsStore:error];
        }
#if DEBUG
        NSLog(@"[TagList HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
    
}

- (TVHStatusSubscription *) objectAtIndex:(int) row {
    return [self.subscriptions objectAtIndex:row];
}

- (int) count {
    return [self.subscriptions count];
}


- (void)setDelegate:(id <TVHStatusSubscriptionsDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

@end
