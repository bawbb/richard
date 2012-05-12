//
//  MainMenuController.m
//  Richard
//
//  Created by Bobby Vicidomini on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuController.h"
#import "GameController.h"

const int DEFAULT_COLUMNS = 4;
const int DEFAULT_ROWS = 12;

@implementation MainMenuController

@synthesize startButton;
@synthesize rowsLabel;
@synthesize columnsLabel;
@synthesize rowsSlider;
@synthesize columnsSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSLog(@"MainMenuController Initialized");
    }
    return self;
}

- (IBAction)startPressed :(id)sender
{
    NSMutableDictionary *gameConfig = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [NSNumber numberWithInt:(int)columnsSlider.value], @"columns",
                  [NSNumber numberWithInt:(int)rowsSlider.value], @"rows", nil] autorelease];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startGameRequested" object:self userInfo:gameConfig];
}

- (IBAction)columnsSliderChanged:(id)sender
{
    columnsLabel.text = [[NSNumber numberWithInt:(int)round(columnsSlider.value)] stringValue];
}

- (IBAction)rowsSliderChanged:(id)sender
{
    rowsLabel.text = [[NSNumber numberWithInt:(int)round(rowsSlider.value)] stringValue];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup UI objects with default values.
    columnsSlider.value = (float)DEFAULT_COLUMNS;
    rowsSlider.value = (float)DEFAULT_ROWS;
    columnsLabel.text = [[NSNumber numberWithInt:DEFAULT_COLUMNS] stringValue];
    rowsLabel.text = [[NSNumber numberWithInt:DEFAULT_ROWS] stringValue];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
