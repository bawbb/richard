//
//  ViewController.m
//  ViewControllerTest
//

#import <UIKit/UIDevice.h>

#import "ViewController.h"
#import "GameController.h"

@implementation ViewController

- (id)initWithSparrowView:(SPView *)sparrowView
{
    if ((self = [super init]))
    {
        mSparrowView = [sparrowView retain];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self selector:@selector(onApplicationDidBecomeActive:) 
                   name:UIApplicationDidBecomeActiveNotification object:nil];
        [nc addObserver:self selector:@selector(onApplicationWillResignActive:) 
                   name:UIApplicationWillResignActiveNotification object:nil];
        
        UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(120, 20, 0, 0)];
        [stepper addTarget:self action:@selector(stepperPressed:) forControlEvents:UIControlEventValueChanged];
        
        // Set min and max
        [stepper setMinimumValue:0];
        [stepper setMaximumValue:99];
        
        // Value wraps around from minimum to maximum
        [stepper setWraps:NO];
        
        // If continuos (default), changes are sent for each change in stepper,
        // otherwise, change event occurs once user lets up on button
        [stepper setContinuous:NO];
        
        // To change the increment value for each step
        // (default is 1)
        [stepper setStepValue:10];
        
        [self.view addSubview :stepper];
        [stepper release];
    }
        
    return self;
}

- (id)init
{
    [NSException raise:SP_EXC_INVALID_OPERATION format:@"ViewController requires Sparrow View"];
    return nil;
}

- (void)dealloc
{
    [mSparrowView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];   
    
    [super didReceiveMemoryWarning];
}

#pragma mark - view lifecycle

- (void)loadView
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.view = [[[SPOverlayView alloc] initWithFrame:screenBounds] autorelease];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSArray *supportedOrientations = 
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    
    return ((interfaceOrientation == UIInterfaceOrientationPortrait &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationPortrait"]) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeLeft &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"]) ||
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationPortraitUpsideDown"]) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight &&
             [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"]));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    // rotate Sparrow content
    GameController *gameController = (GameController *)mSparrowView.stage;
    [gameController rotateToInterfaceOrientation:interfaceOrientation
                                   animationTime:duration];
}

#pragma mark - notifications

- (void)onApplicationDidBecomeActive:(NSNotification *)notification
{
    [mSparrowView start];
}

- (void)onApplicationWillResignActive:(NSNotification *)notification
{
    [mSparrowView stop];
}

@end
