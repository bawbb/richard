//
//  GameboardSpace.h
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPImage.h"

@class Block;

@interface GameboardSpace : SPImage
{
    @private
    
    BOOL mMarked;
}

- (id)initWithPositionAndSize :(float)size :(float)x :(float)y;

// Has the player marked this?
@property (nonatomic, assign) BOOL marked;

// is there an "enemy" block on this space currently?
@property (nonatomic, assign) Block *resident;

// square size of block
@property (nonatomic, assign) float size;

@end
