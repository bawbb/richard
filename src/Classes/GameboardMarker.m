//
//  GameboardMarker.m
//  Richard
//
//  Created by Bobby Vicidomini on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameboardMarker.h"

@interface GameboardMarker()

- (void)onAdded:(SPEvent *)event;
- (void)onRemoved:(SPEvent *)event;

@end

@implementation GameboardMarker

- (id)initWithSize:(float)size
{
    if ((self = [super initWithTexture:[Media atlasTexture:@"GameboardSpace_Marker"]]))
    {
        [self addEventListener:@selector(onAdded:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
        [self addEventListener:@selector(onRemoved:) atObject:self forType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
        
        self.pivotX = self.width / 2;
        self.pivotY = self.height / 2;
        self.scaleX = size / self.width;
        self.scaleY = size / self.height;
        
        self.touchable = NO;
        
        mRotateTween = [[SPTween tweenWithTarget:self time:3.0 transition:SP_TRANSITION_LINEAR] retain];
        self.rotation = 0;
        [mRotateTween animateProperty:@"rotation" targetValue:360 * (PI / 180)];
        mRotateTween.loop = SPLoopTypeRepeat;
        
    }
    
    return self;
}

- (void)dealloc
{
    [mRotateTween release];
    [super dealloc];
}

- (void)onAdded:(SPEvent *)event
{
    NSLog(@"Marker added");
    [[SPStage mainStage].juggler addObject:mRotateTween];
}

- (void)onRemoved:(SPEvent *)event
{
    NSLog(@"Marker removed");
    [[SPStage mainStage].juggler removeObject:mRotateTween];
}

@end
