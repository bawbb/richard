//
//  Gameboard.h
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPSprite.h"
#import "GameboardSpace.h"
#import "FlickDynamics.h"

@interface Gameboard : SPSprite
{
    @private
    
    // Columns and rows in Gameboard
    int mColumns;
    int mRows;
    
    // Size of each space in Gameboard
    float mSpaceSize;
    
    // Collection of "enemy" blocks and spaces on Gameboard
    NSMutableArray *mBlocks;
    NSMutableArray *mSpaces;
    
    // Current space player has marked
    GameboardSpace *mCurrentSpace;
    
    // Used to check when player intention is to move gameboard or mark space
    BOOL mFingerDragging;
    
    // YES if gameboard is taller than screen
    BOOL mScrollingNeeded;
    
    // Calculates Gameboard movement animation
    FlickDynamics *mFlickControl;
}

- (id)init :(int)columns :(int)rows;

@end
