//
//  GameboardSpace.m
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameboardSpace.h"

@implementation GameboardSpace

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithPositionAndSize :(float)size :(float)x :(float)y
{
    if ((self = [super init]))
    {
        [self initWithTexture:[Media atlasTexture: @"GameboardSpace"]];
        self.x = x;
        self.y = y;
        self.width = size;
        self.height = size;
        mMarked = NO;
    }
    return self;
}

- (BOOL)marked
{
    return mMarked;
}

- (void)setMarked :(BOOL)marked
{
    if (marked != mMarked)
    {
        if (marked)
        {
            [Media playSound:@"sound.caf"];
            self.texture = [Media atlasTexture: @"GameboardSpaceMarked"];
        }
        else
            self.texture = [Media atlasTexture: @"GameboardSpace"];
    }
    
    mMarked = marked;
}

@end
