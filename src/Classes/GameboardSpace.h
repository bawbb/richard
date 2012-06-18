//
//  GameboardSpace.h
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface GameboardSpace : SPImage

- (id)initWithPositionAndSize :(float)size :(float)x :(float)y;

// Has the player marked this?
@property (nonatomic, assign) BOOL marked;

// square size of block
@property (nonatomic, assign) float size;

@property (nonatomic, assign) BOOL occupied;

// is the space reachable by player?
@property (nonatomic, assign) BOOL reachable;

@end
