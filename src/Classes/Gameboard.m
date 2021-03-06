//
//  Gameboard.m
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Gameboard.h"
#import "GameboardSpace.h"
#import "FlickDynamics.h"
#import "Block.h"

const int PADDING = 25; // Padding for around edge of gameboard
const double BLOCK_TICK_TIME = 4.0; // Time inbetween blocks tick down

@interface Gameboard ()

- (void)setup;
- (void)markSpace :(GameboardSpace *)space;
- (void)onTouch :(SPTouchEvent *)event;
- (void)onFrame :(SPEvent *)event;
- (void)onAdded :(SPEvent *)event;
- (void)onRemoved :(SPEvent *)event;
- (void)updateSpacesWithinReach;
- (void)markAndcheckSurroundingSpacesforReach:(int)index;
- (void)checkBlockTick;

@end

@implementation Gameboard

- (id)init :(int)columns :(int)rows
{
    if ((self = [super init]))
    {
        mColumns = columns;
        mRows = rows;
        mFingerDragging = NO;
        
        // Wait for me to be added to parent to setup
        [self addEventListener :@selector(onAdded:) atObject :self forType :SP_EVENT_TYPE_ADDED_TO_STAGE];
        [self addEventListener:@selector(onRemoved:) atObject:self forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeEventListenersAtObject :self forType :SP_EVENT_TYPE_TOUCH];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [mFlickControl release];
    [mCurrentSpace release];
    [mSpaces release];
    [mBlocks release];
    [super dealloc];
}

- (void)onAdded :(SPEvent *)event
{
    // I'm added, set me up
    [self setup];
}

- (void)onRemoved :(SPEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkBlockTick) object:nil];
}

- (void)setup
{
    float deviceWidth = self.stage.width;
    float deviceHeight = self.stage.height;
    
    // pad in the gameboard size so some of the background shows.
    float boardWidth = deviceWidth - (PADDING * 2);
    
    mSpaceSize = boardWidth / mColumns;
    
    self.x = PADDING;
    self.y = PADDING;
    
    // loop through rows and columns, adding GameboardSpaces
    mSpaces = [[NSMutableArray array] retain];
    for (int r = 0; r <= mRows; r++)
    {
        for (int c = 0; c < mColumns; c++)
        {
            // If not last row add regular space
            if (r < mRows)
            {
                GameboardSpace *space = [[GameboardSpace alloc] initWithPositionAndSize :mSpaceSize :c * mSpaceSize :r * mSpaceSize];
                [mSpaces addObject :space];
                [self addChild :space];
                
                // uncomment this stuff to add a textfield on
                // each block for some debuging or whatever
                //SPTextField *spaceLabel = [[SPTextField alloc] initWithText:[NSString stringWithFormat:@"%i", mSpaces.count - 1]];
                //spaceLabel.x = space.x - (mSpaceSize / 2);
                //spaceLabel.y = space.y - (mSpaceSize / 2);
                //spaceLabel.touchable = NO;
                //[self addChild:spaceLabel];
                
                [space release];
                //[spaceLabel release];
            }
            // last row, so add end cap images
            else
            {
                NSString *imgSelector;
                BOOL flip = NO;
                
                // decide if we are at begining/mid/end
                if (c == 0)
                    imgSelector = @"GameboardEdge_End";
                else if (c == mColumns - 1)
                {
                    imgSelector = @"GameboardEdge_End";
                    flip = YES;
                }
                else
                    imgSelector = @"GameboardEdge_Mid";
                
                SPImage *endCapImage = [[SPImage alloc] initWithTexture :[Media atlasTexture :imgSelector]];
                endCapImage.x = c * mSpaceSize;
                endCapImage.y = r * mSpaceSize;
                endCapImage.width = mSpaceSize;
                endCapImage.height = mSpaceSize;
                
                //if end, reverse me
                if (flip)
                {
                    endCapImage.width = -mSpaceSize;
                    endCapImage.x += endCapImage.width;
                }
                
                [self addChild :endCapImage];
                
                [endCapImage release];
                [imgSelector release];
            }
        }
    }
    
    mBlocks = [[NSMutableArray array] retain];
    // TODO: add level blocks
    for (int i = 0; i < mColumns * 2; i++)
    {
        Block *block = [[Block alloc] initAtGameboardSpace:[mSpaces objectAtIndex:i]];
        [self addChild:block];
        [mBlocks addObject:block];
        [block release];
    }
    
    [self updateSpacesWithinReach];
    [self performSelector:@selector(checkBlockTick) withObject:nil afterDelay:BLOCK_TICK_TIME];
    
    // is the gameboard large enough to need to scroll?
    mScrollingNeeded = self.height > self.stage.height ? YES : NO;
    
    // FlickDynamics for moving gameboard up and down on touch.
    // I'm still very iffy about retaining this,
    // i think it has leak potential but couldnt get to work otherwise
    mFlickControl = [[FlickDynamics flickDynamicsWithViewportWidth :deviceWidth viewportHeight :deviceHeight - PADDING scrollBoundsLeft :0 scrollBoundsTop :-(self.height + mSpaceSize) + deviceHeight scrollBoundsRight: deviceWidth scrollBoundsBottom :deviceHeight animationRate: 1.0f / [SPStage mainStage].frameRate ] retain];
    mFlickControl.currentScrollTop = PADDING;
    [self addEventListener :@selector(onTouch:) atObject :self forType :SP_EVENT_TYPE_TOUCH];
}

- (void)onTouch :(SPTouchEvent *)event
{
    NSArray *touches = [event.touches allObjects];
    
    // no valid touches, do nothing
    if (touches.count < 1)
        return;
    
    // get first touch
    SPTouch *touch = [touches objectAtIndex :0];
    // invert so drag feels right (drag up, gameboard goes negative)
    SPPoint *currentPos = [touch locationInSpace :self.stage].invert;
    
    // set potential drag
    if (touch.phase == SPTouchPhaseBegan)
    {
        [mFlickControl startTouchAtX :currentPos.x y:currentPos.y];
    }
    // is dragging, check how much
    else if (touch.phase == SPTouchPhaseMoved && mScrollingNeeded)
    {
        // if drag has moved and finger is not already dragging
        if (fabs((touch.previousGlobalY) - touch.globalY) > 0 && !mFingerDragging)
        {
            // set figer to be dragging and added frame listener to animate gameboard movement
            mFingerDragging = YES;
            [self addEventListener :@selector(onFrame:) atObject :self forType :SP_EVENT_TYPE_ENTER_FRAME];
        }
        
        [mFlickControl moveTouchAtX :currentPos.x y:currentPos.y];
    }
    else if (touch.phase == SPTouchPhaseEnded)
    {
        // if it player touched a space and wasnt trying to move board, mark the space
        if (!mFingerDragging && [event.target isKindOfClass:[SPImage class]])
        {
            SPImage *t = (SPImage *)event.target;
            
            // if is space and reachable
            if ([t isKindOfClass :[GameboardSpace class]])
            {
                GameboardSpace *space = (GameboardSpace *)t;
                
                if (space.reachable)
                    [self markSpace :space];
            }
            
            // if player touched block and mark was under block
            // kill the block cause player wanted to kill it
            else if ([t.parent isKindOfClass:[Block class]])
            {
                Block *block = (Block *)t.parent;
                
                if(block.currentSpace.marked)
                {
                    NSLog(@"Killing block: %@", block);
                    
                    [block kill];
                    [mBlocks removeObject:block];
                    mCurrentSpace.marked = NO;
                    mCurrentSpace = nil;
                    
                    [self updateSpacesWithinReach];
                }
            }
        }
        
        [mFlickControl endTouchAtX :currentPos.x y :currentPos.y];
        mFingerDragging = NO;
    }
}

- (void)onFrame :(SPEnterFrameEvent *)event
{
    // animated the values for flickdynamics
    [mFlickControl animate];
    
    float scrollY = mFlickControl.currentScrollTop;
    float dist = scrollY - self.y;
    
    // if distance required to animate is insignificant and finger no longer drags
    if (fabs(dist) < 0.1 && !mFingerDragging)
    {
        // finish animation and remove frame listener
        self.y = scrollY;
        [self removeEventListenersAtObject :self forType :SP_EVENT_TYPE_ENTER_FRAME];
    }
    else
    {
        // continue to animate on prediction course of flick
        self.y += dist;
    }
}

- (void)markSpace :(GameboardSpace *)space
{
    // space isnt same as already marked
    if (mCurrentSpace != space)
    {
        // if there is already a marked space un mark it
        if (mCurrentSpace)
            mCurrentSpace.marked = NO;
        
        // mark touched space
        mCurrentSpace = space;
        mCurrentSpace.marked = YES;
    }
}

- (void)checkBlockTick
{
    // Blocks still left?
    if (mBlocks.count > 0)
    {
        // reverse enumeration, since the blocks move down.
        // other wise we'll be setting the current space ahead to
        // a space we haven't checked yet.
        for (int i = mBlocks.count - 1; i >= 0; i--)
        {
            // set currentspace of block to one row ahead of it's now currentspace
            Block *block = [mBlocks objectAtIndex:i];
            int nextIndex = [mSpaces indexOfObject:block.currentSpace] + mColumns;
            
            if (nextIndex < mSpaces.count)
            {
                block.currentSpace = [mSpaces objectAtIndex:nextIndex];
            }
            else
            {
                [mBlocks removeObject:block];
                [block fallOffEnd];
            }
        }
        
        [self performSelector:@selector(checkBlockTick) withObject:nil afterDelay:BLOCK_TICK_TIME];
        
        NSLog(@"Tick: %i blocks left.", mBlocks.count);
        
        [self updateSpacesWithinReach];
    }
    else
    {
        // All blocks gone, next stage.
        NSLog(@"Next Stage");
    }
}

- (id) retain
{
    // Break here to see who is retaining me.
    return [super retain];
}

- (void)updateSpacesWithinReach
{
    // set all spaces to unreachable so we can proceed with setting them reachable
    for (GameboardSpace *space in mSpaces)
    {
        space.reachable = NO;
    }
    
    // start calculated where the reachable spaces are
    // starting with the first space that doesnt have a resident
    int firstIndexWithoutResident = mSpaces.count - 1;
    
    while (((GameboardSpace *)[mSpaces objectAtIndex:firstIndexWithoutResident]).occupied)
        firstIndexWithoutResident--;
    
    [self markAndcheckSurroundingSpacesforReach:firstIndexWithoutResident];
}

- (void)markAndcheckSurroundingSpacesforReach:(int)index
{
    // if out of range, return
    if (index < 0 || index > mSpaces.count - 1)
        return;
    
    GameboardSpace *space = [mSpaces objectAtIndex:index];
    
    // mark reachable if no block is resident and not already marked
    // then recurrsively call for north east south and west
    if (!space.occupied && !space.reachable)
    {
        space.reachable = YES;
        
        [self markAndcheckSurroundingSpacesforReach:index - mColumns];
        [self markAndcheckSurroundingSpacesforReach:index + 1];
        [self markAndcheckSurroundingSpacesforReach:index + mColumns];
        [self markAndcheckSurroundingSpacesforReach:index - 1];
    }
}

@end
