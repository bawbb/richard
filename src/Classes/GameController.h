//
//  GameController.h
//  AppScaffold
//

#import "SPStage.h"
#import "Game.h"
#import "MainMenuController.h"

@interface GameController : SPStage
{
  @private
    float mGameWidth;
    float mGameHeight;
    SPView *mSparrowView;
    MainMenuController *mMainMenu;
    Game *mGame;
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                       animationTime:(double)time;

@end
