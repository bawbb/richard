//
//  Game.h
//  AppScaffold
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>
#import "Gameboard.h"
#import "MainMenuController.h"

@interface Game : SPSprite
{
    @private
    
    // Width and height of game
    float mGameWidth;
    float mGameHeight;
    
    // Current game board
    //Gameboard *mGameboard;
}

- (id)initWithWidth:(float)width height:(float)height;

// startup game with config options passed in from menu
- (void)startWithConfig:(NSMutableDictionary *)gameConfig;

@property (nonatomic, assign) float gameWidth;
@property (nonatomic, assign) float gameHeight;

@end
