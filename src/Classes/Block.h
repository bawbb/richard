//
//  Block.h
//  Richard
//
//  Created by Bobby Vicidomini on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSprite.h"

@class GameboardSpace;

@interface Block : SPSprite
{
    @private
    GameboardSpace *mCurrentSpace;
    SPMovieClip *blockMovie;
}

- (id)initAtSpace:(GameboardSpace *)space;

// called when no more room to tick down
- (void)fallOffAndDie;

// called when player executes space under block
- (void)kill;

// current space on Gameboard where i reside
@property (nonatomic, assign) GameboardSpace *currentSpace;

@end
