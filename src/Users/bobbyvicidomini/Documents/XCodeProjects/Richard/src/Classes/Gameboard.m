//
//  Gameboard.m
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "Gameboard.h"

const float PADDING = 25;

@interface Gameboard ()

- (void)setup;
- (void)markSpace :(GameboardSpace *)space;
- (void)onTouch :(SPTouchEvent *)event;
- (void)onFrame :(SPEvent *)event;
- (void)onAdded :(SPEvent *)event;

@end

@implementation Gameboard

- (id)init :(int)columns :(int)rows
{
    if ((self = [super init]))
    {
        mColumns = columns;
        mRows = rows;
        mSpaces = [NSMutableArray array];
        mFingerDragging = NO;
        [self addEventListener :@selector(onAdded:) atObject :self forType :SP_EVENT_TYPE_ADDED_TO_STAGE];
    }
    return self;
}

- (void)dealloc
{
    [self removeEventListenersAtObject :self forType :SP_EVENT_TYPE_TOUCH];
    [mFlickControl release];
    [mCurrentSpace release];
    [mSpaces release];
    [super dealloc];
}

- (void)setup
{
    float deviceWidth = self.stage.width;
    float deviceHeight = self.stage.height;
    float boardWidth = deviceWidth - (PADDING * 2);
    
    mSpaceSize = boardWidth / mColumns;
    
    self.x = PADDING;
    self.y = PADDING;
    
    for (int r = 0; r <= mRows; r++)
    {
        for (int c = 0; c < mColumns; c++)
        {
            if (r < mRows)
            {
                GameboardSpace *space = [[GameboardSpace alloc] initWithPositionAndSize :mSpaceSize :c * mSpaceSize :r * mSpaceSize];
                [mSpaces addObject :space];
                [self addChild :space];
                [space release];
            }
            else
            {
                NSString *imgSelector;
                if (c == 0)
                    imgSelector = @"GameboardBottomLeft";
                else if (c == mColumns - 1)
                    imgSelector = @"GameboardBottomRight";
                else
                    imgSelector = @"GameboardBottomMid";
                
                SPImage *backgroundImage = [[SPImage alloc] initWithTexture :[Media atlasTexture :imgSelector]];
                backgroundImage.x = c * mSpaceSize;
                backgroundImage.y = r * mSpaceSize;
                backgroundImage.width = mSpaceSize;
                backgroundImage.height = mSpaceSize;
                [self addChild :backgroundImage];
                
                [backgroundImage release];
                [imgSelector release];
            }
        }
    }
    
    mFlickControl = [FlickDynamics flickDynamicsWithViewportWidth :deviceWidth viewportHeight :deviceHeight - PADDING scrollBoundsLeft :0 scrollBoundsTop :-(self.height + mSpaceSize) + deviceHeight scrollBoundsRight: deviceWidth scrollBoundsBottom :deviceHeight animationRate: 1.0f / 30.0f];
    mFlickControl.currentScrollTop = PADDING;
    
    [self addEventListener :@selector(onTouch:) atObject :self forType :SP_EVENT_TYPE_TOUCH];
}

- (void)onAdded :(SPEvent *)event
{
    [self setup];
}

- (void)onTouch :(SPTouchEvent *)event
{
    NSArray *touches = [event.touches allObjects];
    
    if (touches.count < 1)
        return;
    
    SPTouch *touch = [touches objectAtIndex :0];
    SPPoint *currentPos = [touch locationInSpace :self.stage].invert;
     
    if (touch.phase == SPTouchPhaseBegan)
    {
        [mFlickControl startTouchAtX :currentPos.x y:currentPos.y];
    }
    else if (touch.phase == SPTouchPhaseMoved)
    {
        if (fabs((touch.previousGlobalY) - touch.globalY) > 0 && !mFingerDragging)
        {
            mFingerDragging = YES;
            [self addEventListener :@selector(onFrame:) atObject :self forType :SP_EVENT_TYPE_ENTER_FRAME];
        }
        
        [mFlickControl moveTouchAtX :currentPos.x y:currentPos.y];
    }
    else if (touch.phase == SPTouchPhaseEnded)
    {
        if ([event.target isKindOfClass :[GameboardSpace class]] && !mFingerDragging)
            [self markSpace :((GameboardSpace *)event.target)];
        
        [mFlickControl endTouchAtX :currentPos.x y :currentPos.y];
        mFingerDragging = NO;
    }
}

- (void)onFrame :(SPEnterFrameEvent *)event
{
    [mFlickControl animate];
    
    float scrollY = mFlickControl.currentScrollTop;
    float dist = scrollY - self.y;
    
    if (fabs(dist) < 0.1 && !mFingerDragging)
    {
        self.y = scrollY;
        [self removeEventListenersAtObject :self forType :SP_EVENT_TYPE_ENTER_FRAME];
    }
    else
    {
        self.y += dist;
    }
}

- (void)markSpace :(GameboardSpace *)space
{
    if (mCurrentSpace != space)
    {
        if (mCurrentSpace)
            mCurrentSpace.marked = NO;
        
        mCurrentSpace = space;
        mCurrentSpace.marked = YES;
    }
}

@end
