//
//  Gameboard.h
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSprite.h"
#import "Game.h"
#import "GameboardSpace.h"
#import "FlickDynamics.h"

@interface Gameboard : SPSprite
{
    @private
    
    int mColumns;
    int mRows;
    float mSpaceSize;
    NSMutableArray *mSpaces;
    GameboardSpace *mCurrentSpace;
    BOOL mFingerDragging;
    FlickDynamics *mFlickControl;
    
}

- (id)init :(int)columns :(int)rows;

@end
