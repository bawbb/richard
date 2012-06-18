//
//  Block.m
//  Richard
//
//  Created by Lion User on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Block.h"
#import "GameboardSpace.h"

@interface Block()

-(void)onFrame:(SPEvent *)event;
-(void)animateTo:(float)y;

@end

@implementation Block

@synthesize currentSpace;

- (id)initAtGameboardSpace:(GameboardSpace *) space
{
    if ((self = [super init]))
    {
        // setup and add movieclip child for rotation animation
        mMoveAnimation = [[SPMovieClip alloc] initWithFrames:[Media atlasTexturesWithPrefix:@"BlockStandard_MoveAnimation"] fps:30];
        mMoveAnimation.loop = NO;
        // set pivot in middle so scaling works right
        mMoveAnimation.pivotX = mMoveAnimation.width / 2;
        mMoveAnimation.pivotY = mMoveAnimation.height / 2;
        mMoveAnimation.x = mMoveAnimation.width / 2;
        mMoveAnimation.y = mMoveAnimation.height / 2;
        [mMoveAnimation stop];
        [self addChild:mMoveAnimation];
        
        // Setup initial parameters
        self.x = space.x;
        self.y = space.y - ((space.size * 1.125) - space.size);
        self.width = space.size;
        self.height = space.size * 1.125;
        
        //add on frame event to wait for when main juggler is available.
        [self addEventListener:@selector(onFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
        
        currentSpace = space;
    }
    
    return self;
}

- (void)onFrame:(SPEvent *)event
{
    // we can add to the main juggler now that we got a frame, remove listener
    [self removeEventListener:@selector(onFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    [[SPStage mainStage].juggler addObject:mMoveAnimation];
}

- (void)dealloc
{
    [mMoveAnimation release];
    [super dealloc];
}

- (void)setCurrentSpace:(GameboardSpace *)newCurrentSpace
{
    // set to new space
    currentSpace.occupied = NO;
    [currentSpace autorelease];
    
    newCurrentSpace.occupied = YES;
    
    // animate to new space
    [self animateTo:newCurrentSpace.y - ((newCurrentSpace.size * 1.125) - newCurrentSpace.size)];
    
    currentSpace = [newCurrentSpace retain];
}

- (void)animateTo:(float)y
{
    // Tween movement
    SPTween *moveTween = [SPTween tweenWithTarget:self time:1.0 transition:SP_TRANSITION_EASE_OUT];
    [moveTween animateProperty:@"y" targetValue:y];
    [[SPStage mainStage].juggler addObject:moveTween];
    
    // play BlockMoveAnimation
    mMoveAnimation.currentFrame = 0;
    [mMoveAnimation play];
}

- (void)fallOffEnd
{
    [self animateTo:currentSpace.y + (currentSpace.size * 1.125)];
    
    SPTween *shrinkTween = [SPTween tweenWithTarget:mMoveAnimation time:1.5 transition:SP_TRANSITION_EASE_IN];
    [shrinkTween animateProperty:@"scaleX" targetValue:0.0];
    [shrinkTween animateProperty:@"scaleY" targetValue:0.0];
    [[SPStage mainStage].juggler addObject:shrinkTween];
    
    [[[SPStage mainStage].juggler delayInvocationAtTarget:self byTime:shrinkTween.time] removeFromParent];
    
    //currentSpace.occupied = NO;
    //[currentSpace autorelease];
    self.currentSpace = nil;
}

- (void)kill
{
    SPTween *killTween = [SPTween tweenWithTarget:mMoveAnimation time:0.5 transition:SP_TRANSITION_EASE_OUT];
    [killTween animateProperty:@"alpha" targetValue:0.0];
    [[SPStage mainStage].juggler addObject:killTween];
    
    [[[SPStage mainStage].juggler delayInvocationAtTarget:self byTime:killTween.time] removeFromParent];
    
    //currentSpace.occupied = NO;
    //[currentSpace autorelease];
    self.currentSpace = nil;
}

@end
