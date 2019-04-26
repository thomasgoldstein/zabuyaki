# Editing Zabuyaki with Tiled #
Download Tiled [Tiled Map Editor](http://www.mapeditor.org) or [GitHub](https://github.com/bjorn/tiled)
Version 1.2.1

## Stages naming ##
Default stage name template: **stageX_map.tmx**

## Map size ##
Set and update the map size. It is used to set "walls" around the area.
Use menu **Map / Map Properties**/ to see the list of properties.
Use tiles width and height as a grid. The final map size is calculated from tiles size and the map size in tiles. 

## Export stages to Zabuyaki ##
Use menu **File / Export as...** **stageX_map.lua** to _\src\def\stage\_ .
Where N is the stage number.

## Creating a new file ##
Press **Ctrl + N**. Set the _orientation_ to **Orthogonal**. _Layer format_ to **CSV** and _Tile order_ to **Left Up**.

Zabuyaki uses no tile layers. But you can set the _tile size_ to use it as a grid for aligning images and objects.

Then press **Ok**. Now you should delete default **Tile Layer**.

## Collision objects (walls) ##
Go to the layers tab. Create **Object layer**. Rename it to "collision".
Only the first "collision" layer will be used. All the rest object layers named "collision" will be ignored. 

Now you can add collision objects into the game.
The collision objects names optional.

To select / edit certain objects go to the **Objects** tab (at the right) and expand 
the collision layer list.

> Hint: Use menu **View / Object Types Editor** to set the colour of the walls (e.g. blue).

> Hint: To pixel-wise positioning use the property window at the left. You can use up/down arrows near the coordinates properties 

## Vertical Camera Positioning ##
Go to the layers tab. Create **Object layer**. Rename it to "camera".
Only the first "camera" object layer and the 1st polyline object will be used.

Select "Polyline" drawing tool and draw the line with some segments.
This polyline sets the bottom of the center of the camera view window (320x240 pixels).
The polyline should be longer than the width of the stage.

Horizontal parts of the polyline fix vertical camera position. Descending and ascending parts make
the camera follow the path.

> Hint: Use menu **View / Object Types Editor** to set the colour of the camera object (e.g. red).

> Hint: Hold SPACE key while drawing with the left mouse button pressed to pan the stage.

## Background images ##
Every BG image goes into its own layer. Go to the **Layers tab**. Create **Image layer**.

Name bg images for your easy editing.
 
Set property Visible to false if you don't want to see this image in the game. You can toggle it later.
  
e.g. I use a big stage picture as a template. You can vary its transparency level.
It is good for positioning. But this property value is ignored in Zabuyaki.

Hint: You can duplicate layers. They would keep its properties and the image reference. Just move it and rename.
  
## Background image file format ##
Supported image formats: **PNG, JPEG, TGA,** and **BMP**.

Use PNG 8-bit with indexed transparency. Leave 2 transparent pixels at every side of the image. They are cropped automatically. 

## Stage BG color ##
Use menu **Map / Map Properties** to see the **Background color** map property. 
Expand the property and edit R G B and Alpha(transparency) entries.

## Optional stage characters' shadows height and angle ##
Use menu **Map / Map Properties** to see the **Background color** map property. 
Add **shadowHeight** and **shadowAngle** float properties into **Custom Properties**.  

Defaults: shadowAngle 0.2, shadowHeight 0.3.

Recommended scoop: shadowAngle Range -1 .. 1, shadowHeight 0.2 .. 1.

## Define the batch area width ##
Add a rectangle object to set the batch area. You should set its type to "batch". 
> Hint: The height of the batch shape is ignored.

## Define events ##
All the events should be created in "global" **Object group**. Every event should have type "event". The events can be activated and used once. 
There are 3 allowed event shapes: **Rectangle**, **Ellipse** and **Point**.
> **Rectangle** and **Ellipse** events activate on collision with a player. **Point** shaped event can be called by name only.
> **Polygon** shape is not supported. 

Custom Properties:
* go (Point name) <- move player(s) to the map point. 
* gox (X) <- move player(s) by X pixels. Use negative number to move players left. Yo cannot use both 'go' and 'gox' in the same event.
* goy (Y) <- move player(s) by Y pixels. Use negative number to move players up. You can use both 'goy' and 'gox' in the same event to move players diagonally.
* togox (X) & togoy (Y) <- The same as gox/goy, but players are instantly teleported to the x+togox, y+togoy point and return to their original position. It is used in the enter map events.
* duration (seconds) <- duration of the movement. 1 second if missing.
* face ( 1 / -1 ) <- Face player(s)'s face to the set direction. If missing the facing is set automatically.
* move ("player"/"players") <- Whom to move either the 1st collided player or all the alive players. On missing the property "players" type is used. 
* ignorestate <- Apply the movement to players despite on their current states. (This property is ignored now). 
* disabled <- Disable event. It cannot be run.
* notouch <- This event can be called by the name only. 
* animation (animation name) <- Set sprite animation before the movement. On missing the property "walk" animation is used.
* z (positive number) <- Set final player(s) z coordinate. Can be used to emulate flying / climbing / falling.  
* nextevent (event name) <- start this event next (it is called as if it was collided with a player). Such chained events might be located out of the walkable area. Also you can call predefined events.
* nextmap (map name) <- Override map property 'nextmap' with (map name). It can be used for forking to a secret map.

We will add other rectangle event triggers of other types in this group later.

## Predefined events ##
* nextmap <- Load next map. The next map is set in the map properties. Override it with an event's 'nextmap' (map name) property.   

## Define enemy batches ##
Go to the layers tab. Create **Group layer**. Rename it to "batch".
Now add **Object layers** as batches into the **Group layer** "batch".
 
Every batch should be named. You can alter its Color property to colour its units on the Tiled screen.
Give simple names to your batches, such as 1 2 3 4 etc.

The left and the right sides of the batch are used as the horizontal positions the players stoppers.

Custom properties for each batch **Object layer**:
* spawnDelay <- delay before all its enemy appearance in seconds (float numbers are fine, too). This property is optional.
* music <- start playing a new BGM by alias. All the music aliases are defined in 'preload_bgm.lua'. This property is optional.
* onStart (event name) <- call event at the batch init (before its enemy spawn because the whole spawn can be delayed and an every enemy spawn can be delayed, too).
* onEnter (event name) <- call event on the last player crossing the left bound of the batch.
* onLeave (event name) <- call event on the last player crossing the right bound of the batch.
* onComplete (event name) <- call event (name) on the last batch enemy death. 

Hint: Every batch event should be defined as a global event somewhere at the stage. Keep it away from the walking areas to prevent starting on a player collision.  

## Add enemy units to a batch ##
Go to the layers tab. Select any **Object layer** within "batch" **Group layer**. 

Now you can add enemy units or stage objects into the game.
Every unit should have these properties
* Name <- enemy's name
* Type <- sign, trashcan, gopper, niko, sveta, zeena, beatnik or satoff

Enemy unit's x,y coords equal to coords of the shape center. Only "Point" shape is supported.

> Hint: You can setup Tiled to show different types of the objects with different colours. 
) Use menu **View / Object Types Editor** to set the colours. These settings are kept locally in Tiled cache.

## Optional units properties ##
Optional properties:
* spawnDelay <- delay before unit's appearance in seconds (float numbers are fine, too)
* z <- start z coordinate(height)
* state <- units state on spawn: intro (If set then the animation is set to 'intro' else the stand state is used).
* animation <- any sprite animation name that should override defaults.
* target <- select a player to attack first ("close", "far", "weak", "healthy", "slow" or "fast").
* palette <- select unit's coloring number (shaders). 1 - default.
* wakingRange <- distance in pixels to the closest player to wake up from the 'intro' state (100px by default).  
* delayedWakingRange <- the 2nd distance in pixels to the closest player to wake up from the 'intro' state (150px by default).
* wakingDelay <- unit starts acting if the delay is over and a player is within 'delayedWakingRange'.
* flip <- turn units face to the left  
* drop <- which loot to drop. It can be one **apple**, **chicken** or **beef**

## Define global units ## 
A unit without **batch** is called global. It is spawned on the stage loading.
They are added into the root **Object layers** named "global".

Every unit should contain these properties
* Name <- enemy's name
* Type <- sign, trashcan, gopper, niko, sveta, zeena, beatnik or satoff
> Hint: These units do not lock you within a batch area. You can spare their liver and go to the next batch area.

## Define players start positions ## 
3 "Point" objects should be added into the root of **Object layers** named "player".
Only first 3 objects are used. The rest objects are ignored.
Th naming doesn't matter.

## Define next stage map file name ## 
Use menu **Map / Map Properties**/ to see the list of properties.
Expand "Custom Properties" group. Click "+" button at the bottom to
add "nextmap"(string) property.
If the property is not present then the default map name "stage1a_map" is used.
Do not add neither path nor extension to the to the map name.

There are predefined map names for special cases:
* ending <- End the game and show "ending" movie.     
* to be added     
 
## In-Game drawing order ##
The BG images are drawn starting from the very last item in the list back to the top.

10 -> 9 -> 8 ... -> 1

How to move image layers up/down
 * Use menu **Layer / Raise Layer / Lower Layer** 
 * Use buttons at the bottom of the layers window
 * Use **Ctrl+Shift+Up / Down** hot keys
## Controls ##
Use Ctrl + Up/Down to move current object/layer up/down withing the list.

Middle mouse key / Wheel to pan the whole level.

Ctrl + Wheel up/down to zoom in/out.

Hold Shift key on drawing an object to keep proportions.

[Tiled Keyboard Shortcuts](https://github.com/bjorn/tiled/wiki/Keyboard-Shortcuts)