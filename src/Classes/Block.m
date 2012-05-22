//  
//  Block.m
//  Richard
//
//  Created by Bobby Vicidomini on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Block.h"
#import "GameboardSpace.h"

@interface Block()

-(void)onFrame:(SPEvent *)event;

@end

@implementation Block

@synthesize currentSpace = mCurrentSpace;

- (id)initAtSpace:(GameboardSpace *)space
{
    if ((self = [super init]))
    {
        // setup and add movieclip child for rotation animation
        blockMovie = [[SPMovieClip alloc] initWithFrames:[Media atlasTexturesWithPrefix:@"BlockStandard_MoveAnimation"] fps:30];
        blockMovie.loop = NO;
        blockMovie.pivotX = blockMovie.width / 2;
        blockMovie.pivotY = blockMovie.height / 2;
        blockMovie.x = blockMovie.width / 2;
        blockMovie.y = blockMovie.height / 2;
        [blockMovie stop];
        [self addChild:blockMovie];
        
        // Setup initial parameters
        self.x = space.x;
        self.y = space.y - ((space.size * 1.125) - space.size);
        self.width = space.size;
        self.height = space.size * 1.125;
        mCurrentSpace = space;
        
        //add on frame event to wait for when main juggler is available.
        [self addEventListener:@selector(onFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    }
    
    return self;
}

- (void)onFrame:(SPEvent *)event
{
    // we can add to the main juggler now that we got a frame, remove listener
    [self removeEventListener:@selector(onFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    [[SPStage mainStage].juggler addObject:blockMovie];
}

- (void)dealloc
{
    [blockMovie release];
    [super dealloc];
}

-(GameboardSpace *)currentSpace
{
    return mCurrentSpace;
}

- (void)setCurrentSpace:(GameboardSpace *)currentSpace
{
    // Moving to new space
    mCurrentSpace.resident = nil;
    mCurrentSpace = currentSpace;
    mCurrentSpace.resident = self;
    
    // Tween movement
    SPTween *moveTween = [SPTween tweenWithTarget:self time:1.0 transition:SP_TRANSITION_EASE_OUT];
    [moveTween animateProperty:@"y" targetValue:mCurrentSpace.y - ((mCurrentSpace.size * 1.125) - mCurrentSpace.size)];
    [[SPStage mainStage].juggler addObject:moveTween];
    
    blockMovie.currentFrame = 0;
    [blockMovie play];
    
    if (mCurrentSpace.marked)
        self.alpha = 0.75;
    else
        self.alpha = 1.0;
}

- (void)fallOffAndDie
{
    mCurrentSpace.resident = nil;
    
    SPTween *scaleTween = [SPTween tweenWithTarget:[self childAtIndex:0] time:2.0 transition:SP_TRANSITION_EASE_IN];
    [scaleTween animateProperty:@"scaleX" targetValue:0];
    [scaleTween animateProperty:@"scaleY" targetValue:0];
    [scaleTween animateProperty:@"alpha" targetValue:0.0];
    [[SPStage mainStage].juggler addObject:scaleTween];
    
    SPTween *yTween = [SPTween tweenWithTarget:self time:1.0 transition:SP_TRANSITION_EASE_OUT];
    [yTween animateProperty:@"y" targetValue:self.y + self.height];
    [[SPStage mainStage].juggler addObject:yTween];
    
    // delayed call for removal
    [[[SPStage mainStage].juggler delayInvocationAtTarget:self.parent byTime:scaleTween.time] removeChild:self];
    
    blockMovie.currentFrame = 0;
    [blockMovie play];
}

- (void)kill
{
    mCurrentSpace.resident = nil;
    
    [self.parent setIndex:self.parent.numChildren - 1 ofChild:self];
    
    SPTween *scaleTween = [SPTween tweenWithTarget:[self childAtIndex:0] time:0.5 transition:SP_TRANSITION_EASE_OUT_IN];
    [scaleTween animateProperty:@"scaleX" targetValue:1.25];
    [scaleTween animateProperty:@"scaleY" targetValue:1.25];
    [scaleTween animateProperty:@"alpha" targetValue:0.0];
    [[SPStage mainStage].juggler addObject:scaleTween];
    
    // delayed call for removal
    [[[SPStage mainStage].juggler delayInvocationAtTarget:self.parent byTime:scaleTween.time] removeChild:self];
}

@end
