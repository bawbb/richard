//
//  Block.h
//  Richard
//
//  Created by Lion User on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class GameboardSpace;

@interface Block : SPSprite
{
    @private
    SPMovieClip *mMoveAnimation;
}

@property(nonatomic, retain) GameboardSpace *currentSpace;

- (id)initAtGameboardSpace:(GameboardSpace *) space;
- (void)fallOffEnd;
- (void)kill;

@end
