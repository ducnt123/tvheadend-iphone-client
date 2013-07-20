//
//  TVHConfigNameStore.h
//  TvhClient
//
//  Created by zipleen on 7/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHConfigName.h"

@class TVHServer;

@interface TVHConfigNameStore : NSObject
@property (nonatomic, weak) TVHServer *tvhServer;

- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchConfigNames;
@end
