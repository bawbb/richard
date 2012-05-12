//
//  Game.m
//  AppScaffold
//

#import "Game.h"
#import "Gameboard.h"
#import "MainMenuController.h"

// --- private interface ---------------------------------------------------------------------------

@interface Game ()

- (void)onResize:(SPResizeEvent *)event;
- (void)onMenuButtonTouched:(id)sender;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation Game

@synthesize gameWidth  = mGameWidth;
@synthesize gameHeight = mGameHeight;

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super init]))
    {
        mGameWidth = width;
        mGameHeight = height;
    }
    return self;
}

- (void)dealloc
{
    // release any resources here
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_RESIZE];
    [mGameboard release];
    [super dealloc];
}

- (void)startWithConfig:(NSMutableDictionary *)gameConfig
{
    NSLog(@"Starting game with config: %@", gameConfig);
    
    // For handling what happens on resize or orientation
    [self addEventListener:@selector(onResize:) atObject:self forType:SP_EVENT_TYPE_RESIZE];
    
    // Add the background image
    SPImage *background = [[SPImage alloc] initWithContentsOfFile:@"background.jpg"];
    [self addChild:background];
    
    // Setup gameBoard with the right columns and rows from game config
    mGameboard = [[Gameboard alloc] init :[[gameConfig valueForKey:@"columns"] intValue] :[[gameConfig valueForKey:@"rows"] intValue]];
    [self addChild:mGameboard];
    
    // add button for going back to menu
    UIButton *menuButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    [menuButton setFrame:CGRectMake( 40, 40, 75, 40)];
    [menuButton setTitle:@"< Back" forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(onMenuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [[SPStage mainStage].nativeView addSubview:menuButton];
    
    [background release];
    [menuButton release];
}

- (void)onMenuButtonTouched:(id)sender
{
    [sender removeFromSuperview];
    [sender removeTarget:self action:@selector(quitHandler:) forControlEvents:UIControlEventTouchUpInside];
    [mGameboard stopBlockTick];
    SPEvent *event = [SPEvent eventWithType:@"openMainMenuRequested" bubbles:YES];
    [self dispatchEvent:event];
}

- (void)onResize:(SPResizeEvent *)event
{
    NSLog(@"new size: %.0fx%.0f (%@)", event.width, event.height, 
          event.isPortrait ? @"portrait" : @"landscape");
}

@end
