//
//  GameController.m
//  AppScaffold
//

#import <OpenGLES/ES1/gl.h>
#import "GameController.h"
#import "MainMenuController.h"



@interface GameController ()

- (UIInterfaceOrientation)initialInterfaceOrientation;
- (void)firstFrameHandler:(SPEnterFrameEvent *)event;
- (void)gameQuitHandler:(SPEvent *)event;
- (void)openMainMenu;
- (void)startGameWithConfig:(NSMutableDictionary *)gameConfig;

@end

@implementation GameController

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {
        mGameWidth = width;
        mGameHeight = height;
        
        // Starts up the sound engine
        [SPAudioEngine start];
        
        // The Application contains a very handy "Media" class which loads your texture atlas
        // and all available sound files automatically. Extend this class as you need it --
        // that way, you will be able to access your textures and sounds throughout your 
        // application, without duplicating any resources.
        
        [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
        [Media initSound];      // loads all your sounds    -> see Media.h/Media.m    
        
        // if we start up in landscape mode, width and height are swapped.
        UIInterfaceOrientation orientation = [self initialInterfaceOrientation];
        if (UIInterfaceOrientationIsLandscape(orientation)) SP_SWAP(mGameWidth, mGameHeight, float);
        
        // Handle orientation rotation if needed
        [self rotateToInterfaceOrientation:orientation animationTime:0];
        
        // This onFrame Handler is here just for the first frame, to garantee all SPStage objects return correct values (kinda a sparrow bug i've found).
        [self addEventListener :@selector(firstFrameHandler:) atObject :self forType:SP_EVENT_TYPE_ENTER_FRAME];
        
        // If we don't set the stage color to white, we will see a black flicker on startup from the addFrame handler above, which waits one frame.
        self.color = 0xffffff;
    }
    
    return self;
}


- (void)firstFrameHandler:(SPEnterFrameEvent *)event
{
    // Remove on first frame
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    
    // Open up the main menu
    [self openMainMenu];
}

- (void)openMainMenu
{
    // no main menu allocated yet, do so
    if (mMainMenu == nil)
    {
        mMainMenu = [[[MainMenuController alloc] initWithNibName:@"MainMenuController" bundle:nil] retain];
        
        // Attach handler for when starting the game is requested
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGameWithConfig:) name:@"startGameRequested" object:nil];
    }
    
    // Attach it to sparrow's native view (which sits on top of it's game view)
    [self.nativeView addSubview:mMainMenu.view];
}

- (void) startGameWithConfig:(NSNotification *)notification
{
    [mMainMenu.view removeFromSuperview];
    
    // Allocate and setup new game,
    // pass in game config from menu that requested game start.
    mGame = [[[Game alloc] initWithWidth:mGameWidth height:mGameHeight] retain];
    [mGame addEventListener:@selector(gameQuitHandler:) atObject:self
                    forType:@"openMainMenuRequested"];
    [mGame startWithConfig :(NSMutableDictionary *)[notification userInfo]];
    [self addChild:mGame];
}

- (void)gameQuitHandler:(SPEvent *)event
{
    NSLog(@"gameQuitHandler");
    
    // release and remove game
    [mGame removeEventListenersAtObject:self forType:@"openMainMenuRequested"];
    [self removeChild:mGame];
    [mGame release];
    mGame = nil;
    
    // open the (already existing, just hidden) main menu
    [self openMainMenu];
}

- (void)dealloc
{
    [mMainMenu release];
    [mSparrowView release];
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
