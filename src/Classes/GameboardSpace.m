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

@synthesize resident;
@synthesize size;
@synthesize marked = mMarked;

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
    }
    
    mMarked = marked;
}

@end
