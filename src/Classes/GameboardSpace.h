//
//  GameboardSpace.h
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPImage.h"

@interface GameboardSpace : SPImage
{
    @private
}

- (id)initWithPositionAndSize :(float)size :(float)x :(float)y;

// Has the player marked this?
@property (nonatomic, assign) BOOL marked;

// square size of block
@property (nonatomic, assign) float size;

@end
