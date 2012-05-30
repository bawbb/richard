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

@synthesize size;
@synthesize marked = mMarked;
@synthesize resident = mResident;
@synthesize reachable = mReachable;
@synthesize occupied;

- (id)initWithPositionAndSize :(float)initsize :(float)x :(float)y
{
    if ((self = [super initWithTexture:[Media atlasTexture: @"GameboardSpace"]]))
    {
        // Setup initial parameters
        self.x = x;
        self.y = y;
        self.width = initsize;
        self.height = initsize;
        self.size = initsize;
        mMarked = NO;
        self.reachable = NO;
        mResident = nil;
    }
    
    return self;
}

- (BOOL)marked
{
    return mMarked;
}

- (void)setMarked :(BOOL)marked
{
    // If value changed
    if (marked != mMarked)
    {
        if (marked)
        {
            // Mark this space, play sound
            [Media playSound:@"sound.caf"];
            self.texture = [Media atlasTexture: @"GameboardSpace_Marked"];
        }
        else // Unmark the space
            self.texture = [Media atlasTexture: @"GameboardSpace"];
        
        mMarked = marked;
    }
}

- (BOOL) occupied
{
    if (mResident == nil)
        return NO;
    else
        return YES;
}

- (Block *)resident
{
    return mResident;
}

- (void)setResident:(Block *)resident
{
    if (resident != nil)
        mResident = [resident retain];
    else
    {
        [mResident release];
        mResident = nil;
    }
}

- (BOOL)reachable
{
    return mReachable;
}

- (void)setReachable:(BOOL)reachable
{
    if (reachable != mReachable)
    {
        if (reachable)
        {
            self.color = 0xFFDDDD;
        }
        else
        {
            self.color = 0xFFFFFF;
        }
        
        mReachable = reachable;
    }
}

@end
