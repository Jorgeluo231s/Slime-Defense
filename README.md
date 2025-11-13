# LOVE2D Tower Defense
#### Video Demo:  <URL HERE>
## Description
This is a classic Tower Defense (TD) game built using the LOVE 2D framework and Lua. The player's objective is to defend a path by strategically placing arrow-shooting towers to eliminate waves of enemies before they reach the end. The game ends on wave 10.

The game is built on the tile-based map editor Tiled. Enemies spawn in waves and follow a predefined path. The player earns gold by destroying enemies, which can then be spent to build more towers. If an enemy reaches the end of the path, the player loses a life. The game is lost if the player's lives reach zero, and won if the player survives all 10 waves of enemies.

Core mechanics include an economy system, tower placement, automated tower targeting, and increasing wave difficulty.

## Core Features
**Enemy Waves:** The game features 10 progressively more difficult waves. The `_waves.lua` class manages the system, increasing enemies per wave and changing the spawn delay between them.
###
**Tower Placement:** The player can press 'P' to enter a "placement mode." The game stops and displays an outline of the tower range and size that follows the mouse. The placement outline turns green if the location is valid and red if it's invalid.
###
**Tower & Projectile Logic:** In the file `_tower1.lua`, towers automatically scan for the closest enemy within their 280-pixel range. To prevent all the towers from attacking the same enemy and projectiles disappearing in the air, the targeting AI will only pick an enemy that isn't already targeted by another projectile. Once a target is locked, the tower fires an arrow that tracks the enemy until it hits or the enemy is destroyed.
###
**Economy & Scaling:** The player starts with 5 gold and gains 5 gold per slime defeated. The cost of towers escalates with preset settings (5, 35, 100, 240, and 400 gold), making later placements a higher investment compared to the start.
###
**Game State:** In `_main.lua`, the file manages what are called states. It switches between "alive" and "placing" while in-game and has two other states called "win" and "lose".
###
**Physics & Animation:** The game uses the `_windfield` physics library to handle colliders for enemies and projectiles, treating them as sensors for movement and hit detection. The anim8 library is used to give the slime enemy a simple, 4-frame animation.

## File Structure
This project is organized into a main script, a configuration file, and folders for classes, maps, sprites, and fonts.

### Common Functions in `love` files
#### ***class***:new()
In each class, there is a "new" function that contains the information for each of the stats or features it has, similar to the `_love.load()` function.
#### _love.update()_
Runs every frame and manages all time-related mechanics of the game. It updates all classes and physics. It loops through the enemies table to remove dead/finished enemies. It also handles the logic when you're placing and updates the ghost tower position.
#### _love.draw()_
Renders everything that will be shown to the player, from the map to the enemies to the UI. Each class that is visible will have a draw function.

### _main.lua_
This is the "brain" of the project; it handles all the functions and is what combines all the logic.

#### _love.load()_
This function (within `_main.lua`) initializes the game window and loads all libraries, which include anim8 (animation), windfield (physics), and sti (Tiled map implementation). It loads the map and enemy path, and creates the blueprints for player stats, the spawner, towers, enemies, and their respective tables.
#### _love.update(dt)_
#### _love.draw()_
#### _love.keypressed(key) & love.mousepressed(...)_
Functions that handle keypress input.
#### _isValidPath(tileX,tileY)_
Validates tower placement and checks path tiles and map boundaries. Uses an AABB check to prevent overlapping towers.

### _conf.lua_
Configuration file. Sets the window title to "Tower Defense" and changes the resolution to fit the entire map (1280x768).

### Classes
#### _player.lua_
A simple class that contains the player's stats. It holds the player's gold, lives, tower limit, and the price of each tower.
#### _enemy1.lua_
Defines the "slime" enemy class. It manages the enemy's state, including all its stats, animation, and physics body. It has a `_takeDamage()` function called by projectiles, and a `_loselife()` function called by itself when it reaches the end of the path.
#### _tower1.lua_
Defines the "Arrow tower" class. It manages its own targeting AI, firing cooldown, and its own projectiles.
#### _waves.lua_ 
Defines the enemy wave spawner. It contains a table of all 10 waves with their enemy count and spawn delay. Manages the timer and delay for the waves.

### Maps
_pathOne.tmx_: The Tiled Map Editor source file.

_pathOne.lua_: The exported Lua file that sti loads into the game. It contains the data for all tile layers and object layers.

_tileset.png_: The single 64x64 tileset image used to draw the map.
### Sprites
_tower.png_: The 128x128 sprite for the placed towers.

_arrow1.png_: The 300x300 projectile sprite fired by towers (scaled down in-game).

_slime/_: A folder containing _slime0.png_ through _slime3.png_, the four 32x35 frames for the enemy's walk animation.
### Fonts
_ARCADECLASSIC.TTF_: The custom pixel font used for all text rendered in the game. 

## Design Choices
### Path Finding
At first, I thought about making the enemy know its endpoint and, based on the limits it was given, it should know where to go. I concluded after starting theorizing, that it was way too complex to start with. I opted for a polyline in the Tiled Map Editor. The polyline is the path that the enemy will follow without any problems—a preset path.
### Tower Placement
Using the `_windfield` physics library, enemies and projectiles are sensors.

Enemies were not sensors at the start, but a problem arose when the enemies started to jam and slow down the game. I opted to make them sensors and overlap each other.

Projectiles started as non-sensors at the start, but I quickly noticed how they kept pushing the tower, which changed how I wanted the game to look.
### Targeting
A common problem in tower defense games is "overkill," where all towers waste their shots on the first enemy. In my game at the start, they shot and the shot disappeared if the enemy died before arriving. I solved this problem by making the projectile redirect to the next target if the enemy finished the path or was dead.