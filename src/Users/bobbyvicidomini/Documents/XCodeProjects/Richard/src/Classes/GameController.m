//
//  GameController.m
//  AppScaffold
//

#import <OpenGLES/ES1/gl.h>
#import "GameController.h"


@interface GameController ()

- (UIInterfaceOrientation)initialInterfaceOrientation;

@end


@implementation GameController

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {
        float gameWidth  = width;
        float gameHeight = height;
        
        // if we start up in landscape mode, width and height are swapped.
        UIInterfaceOrientation orientation = [self initialInterfaceOrientation];
        if (UIInterfaceOrientationIsLandscape(orientation)) SP_SWAP(gameWidth, gameHeight, float);
        
        mGame = [[Game alloc] initWithWidth:gameWidth height:gameHeight];
        
        mGame.pivotX = gameWidth  / 2;
        mGame.pivotY = gameHeight / 2;
        
        mGame.x = width  / 2;
        mGame.y = height / 2;
        
        [self rotateToInterfaceOrientation:orientation animationTime:0];
        [self addChild:mGame];
    }
    
    return self;
}

- (void)dealloc
{
    [mGame release];
    [super dealloc];
}

- (UIInterfaceOrientation)initialInterfaceOrientation
{
    // In an iPhone app, the 'statusBarOrientation' has the correct value on Startup; 
    // unfortunately, that's not the case for an iPad app (for whatever reason). Thus, we read the
    // value from the app's plist file.
    
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *initialOrientation = [bundleInfo objectForKey:@"UIInterfaceOrientation"];
    if (initialOrientation)
    {
        if ([initialOrientation isEqualToString:@"UIInterfaceOrientationPortrait"])
            return UIInterfaceOrientationPortrait;
        else if ([initialOrientation isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"])
            return UIInterfaceOrientationPortraitUpsideDown;
        else if ([initialOrientation isEqualToString:@"UIInterfaceOrientationLandscapeLeft"])
            return UIInterfaceOrientationLandscapeLeft;
        else
            return UIInterfaceOrientationLandscapeRight;
    }
    else 
    {
        return [[UIApplication sharedApplication] statusBarOrientation];
    }
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                       animationTime:(double)animationTime
{
    float angles[] = {0.0f, 0.0f, -PI, PI_HALF, -PI_HALF};
    
    float oldAngle = mGame.rotation;
    float newAngle = angles[(int)interfaceOrientation];
    
    // make sure that rotation is always carried out via the minimal angle
    while (oldAngle - newAngle >  PI) newAngle += TWO_PI;
    while (oldAngle - newAngle < -PI) newAngle -= TWO_PI;

    // rotate game
    if (animationTime)
    {
        SPTween *tween = [SPTween tweenWithTarget:mGame time:animationTime
                                       transition:SP_TRANSITION_EASE_IN_OUT];
        [tween animateProperty:@"rotation" targetValue:newAngle];
        [[SPStage mainStage].juggler removeObjectsWithTarget:mGame];
        [[SPStage mainStage].juggler addObject:tween];
    }
    else 
    {
        mGame.rotation = newAngle;
    }
    
    // inform all display objects about the new game size
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(interfaceOrientation);
    float newWidth  = isPortrait ? MIN(mGame.gameWidth, mGame.gameHeight) : 
                                   MAX(mGame.gameWidth, mGame.gameHeight);
    float newHeight = isPortrait ? MAX(mGame.gameWidth, mGame.gameHeight) :
                                   MIN(mGame.gameWidth, mGame.gameHeight);
    
    if (newWidth != mGame.gameWidth)
    {
        mGame.gameWidth  = newWidth;
        mGame.gameHeight = newHeight;
        
        SPEvent *resizeEvent = [[SPResizeEvent alloc] initWithType:SP_EVENT_TYPE_RESIZE
                                width:newWidth height:newHeight animationTime:animationTime];
        [mGame broadcastEvent:resizeEvent];
        [resizeEvent release];
    }
}

// Enable this method for the simplest possible universal app support: it will display a black
// border around the iPhone (640x960) game when it is started on the iPad (768x1024); no need to 
// modify any coordinates. 
/*
- (void)render:(SPRenderSupport *)support
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        glEnable(GL_SCISSOR_TEST);
        glScissor(64, 32, 640, 960);
        [super render:support];
        glDisable(GL_SCISSOR_TEST);
    }
    else 
        [super render:support];
}
*/

@end
