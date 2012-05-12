richard
=======

ios tile based puzzle game

you'll have to download the sparrow framework here:
http://gamua.com/sparrow/

doesn't matter where you keep the framework. i just keep mine in Documents/SparrowFramework

Then you'll have to follow just the first 2 steps on their getting started page to configure Xcode here:

http://gamua.com/sparrow/first-steps/

the first step configures a constant link name called SPARROW_SRC to your sparrows source location. mine would be Documents/SparrowFramework/sparrow/src. yours could be different. 

the second setup sets up the API documentation web link so Xcode can download all the code hinting/helping/autofilling or whatever.

after that you should just be able to checkout from this git hub link and and inside the src folder you should be able to just open up Richard.xcodeproj and build

(…i think)