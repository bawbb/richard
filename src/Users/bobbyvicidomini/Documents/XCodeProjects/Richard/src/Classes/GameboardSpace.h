//
//  GameboardSpace.h
//  Richard
//
//  Created by Bobby Vicidomini on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPImage.h"

@interface GameboardSpace : SPImage
{
    @private
    
    BOOL mMarked;
}

- (id)initWithPositionAndSize :(float)size :(float)x :(float)y;

@property (nonatomic, assign) BOOL marked;

@end
