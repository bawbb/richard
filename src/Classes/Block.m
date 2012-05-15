//  THE BLOCK!!!
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

- (id)initAtSpace:(GameboardSpace *)space
{
    if ((self = [super init]))
    {
        // add block's image, set pivot to center
        // (for scalling effects) and re center image
        /*SPImage *blockImage = [[SPImage alloc] initWithTexture:[Media atlasTexture: @"BlockStandard_Idle"]];
        blockImage.pivotX = blockImage.width / 2;
        blockImage.pivotY = blockImage.height / 2;
        blockImage.x = blockImage.width / 2;
        blockImage.y = blockImage.height / 2;
        [self addChild:blockImage];
        [blockImage release];*/
        
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
        space.resident = self;
        [self addEventListener:@selector(onFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    }
    
    return self;
}

- (void)onFrame:(SPEvent *)event
{
    [self removeEventListener:@selector(onFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    [[SPStage mainStage].juggler addObject:blockMovie];
}

- (void)dealloc
{
    NSLog(@"Block dealloc");
    [blockMovie release];
    [super dealloc];
}

- (GameboardSpace *)currentSpace
{
    return mCurrentSpace;
}

- (void)setCurrentSpace:(GameboardSpace *)currentSpace
{
    // TODO: animate this action
    
    // Leaving current space
    mCurrentSpace.resident = nil;
    
    // Moving to new space
    mCurrentSpace = currentSpace;
    mCurrentSpace.resident = self;
    
    // Tween movement
    SPTween *moveTween = [SPTween tweenWithTarget:self time:0.5 transition:SP_TRANSITION_EASE_OUT];
    moveTween.delay = [SPUtils randomFloat] * 0.1;
    [moveTween animateProperty:@"y" targetValue:mCurrentSpace.y - ((mCurrentSpace.size * 1.125) - mCurrentSpace.size)];
    [[SPStage mainStage].juggler addObject:moveTween];
    
    blockMovie.currentFrame = [SPUtils randomIntBetweenMin:0 andMax:3];
    [blockMovie play];
}

- (void)fallOffAndDie
{
    SPTween *scaleTween = [SPTween tweenWithTarget:[self childAtIndex:0] time:1.0 transition:SP_TRANSITION_EASE_OUT_IN];
    [scaleTween animateProperty:@"scaleX" targetValue:0];
    [scaleTween animateProperty:@"scaleY" targetValue:0];
    //[scaleTween animateProperty:@"alpha" targetValue:0.0];
    [[SPStage mainStage].juggler addObject:scaleTween];
    
    SPTween *yTween = [SPTween tweenWithTarget:self time:0.5 transition:SP_TRANSITION_EASE_OUT];
    [yTween animateProperty:@"y" targetValue:self.y + self.height];
    [[SPStage mainStage].juggler addObject:yTween];
    
    // delayed call for removal
    [[[SPStage mainStage].juggler delayInvocationAtTarget:self.parent byTime:scaleTween.time] removeChild:self];
    
    blockMovie.currentFrame = 0;
    [blockMovie play];
}

- (void)kill
{
    [self.parent setIndex:self.parent.numChildren - 1 ofChild:self];
    
    SPTween *scaleTween = [SPTween tweenWithTarget:[self childAtIndex:0] time:1.0 transition:SP_TRANSITION_EASE_OUT_IN];
    [scaleTween animateProperty:@"scaleX" targetValue:1.25];
    [scaleTween animateProperty:@"scaleY" targetValue:1.25];
    [scaleTween animateProperty:@"alpha" targetValue:0.0];
    [[SPStage mainStage].juggler addObject:scaleTween];
    
    // delayed call for removal
    [[[SPStage mainStage].juggler delayInvocationAtTarget:self.parent byTime:scaleTween.time] removeChild:self];
}

@end
