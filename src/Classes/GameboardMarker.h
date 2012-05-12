//
//  GameboardMarker.h
//  Richard
//
//  Created by Bobby Vicidomini on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMovieClip.h"

@interface GameboardMarker : SPImage
{
    @private
    SPTween *mRotateTween;
}

- (id)initWithSize:(float)size;

@end
