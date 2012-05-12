//
//  MainMenuController.h
//  Richard
//
//  Created by Bobby Vicidomini on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UILabel *columnsLabel;
@property (nonatomic, retain) IBOutlet UILabel *rowsLabel;
@property (nonatomic, retain) IBOutlet UISlider *columnsSlider;
@property (nonatomic, retain) IBOutlet UISlider *rowsSlider;

- (IBAction)startPressed :(id)sender;
- (IBAction)columnsSliderChanged :(id)sender;
- (IBAction)rowsSliderChanged :(id)sender;

@end
