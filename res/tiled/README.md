# Editing Zabuyaki with Tiled #
Download Tiled [Tiled Map Editor](http://www.mapeditor.org) or [GitHub](https://github.com/bjorn/tiled)
Version 1.1.5+

## Stages naming ##
Default stage name template: **StageX_data.tmx**

## Export stages to Zabuyaki ##
Use menu **File / Export as...** **stageN_data.lua** to _\src\def\stage\_ .
Where N is the stage number.

## Creating a new file ##
Press **Ctrl + N**. Set the _orientation_ to **Orthogonal**. _Layer format_ to **CSV** and _Tile order_ to **Left Up**.

Zabuyaki uses no tile layers. But you can set the _tile size_ to use it as a grid for aligning images and objects.

Then press **Ok**. Now you should delete default **Tile Layer**.

## Collision objects (walls) ##
Go to the layers tab. Create **Object layer**. Rename it to "collision".
Only the first "collision" layer will be used. All the rest object layers named "collision" will be ignored. 

Now you can add collision objects into the game.
Name them properly. Try to use different names for repeating pieces.

Zabuyaki accepts 1 type of the objects: "wall". On adding an object you should fill in its type property with "wall".

You can setup Tiled to show different types of the objects with different colours. 
Use menu **View / Object Types Editor** to set the colours. They are kept for a local user/PC only.
 
To select / edit certain objects go to the **Objects** tab (at the right) and expand 
the collision layer list.

> Hint: Use menu **View / Object Types Editor** to set the colour of the walls (e.g. blue).

> Hint: To pixel-wise positioning use the property window at the left. You can use up/down arrows near the coordinates properties 

## Vertical Camera Positioning ##
Go to the layers tab. Create **Object layer**. Rename it to "camera".
Only the first "camera" layer and the 1st "camera" ензу object will be used.
All the rest object layers and objects named "camera" will be ignored. 

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

## Define enemy batches ##
Go to the layers tab. Create **Object layer**. Rename it to "batch".
Only the first "batch" layer will be used. All the rest object layers named "batch" will be ignored. 

Now you can add enemy batches into the game.
 
Every batch should contain these properties
* Name <- Every enemy on the stage has a property **batch** with his batch name. 
           Use simple batch naming, such as 1 2 3 4 etc.
* Type <- **batch**

Custom properties:
* delay <- delay before all its enemy appearance in seconds (float numbers are fine, too). This property is optional.
 
The left and the right sides of the batch are used as the horizontal positions the players stoppers.

> Hint: The height of the batch shape is ignored. 

## Define enemy units to a batch ##
Go to the layers tab. Create **Object layer**. Rename it to "unit".
Only the first "unit" layer will be used. All the rest object layers named "unit" will be ignored. 

Now you can add enemy into the game.
Every enemy should contain these properties
* Name <- enemy's name
* Type <- **"unit"**

Custom properties:
* batch <- enemy batch name. Usually a number
* class <- Gopper, Niko, Sveta, Zeena, Beatnick or Satoff  

The unit without **batch** property is called permanent. It is spawed on loading the stage.

Enemy unit's x,y coords equal to coords of the shape center. You can use any shapes: Oval, Rectangle. 
> Hint: The size of the shape is ignored.

## Optional units properties ##
Optional properties:
* delay <- delay before its appearance in seconds (float numbers are fine, too)
* state <- units state on spawn: intro, stand, walk (aim to players)
* palette <- select unit's coloring number (shaders). 1 - default.
* flip <- turn units face to the left  
* drop <- which loot to drop. It can be one **apple**, **chicken** or **beef** 

## In-Game drawing order ##
The BG images are drawn starting from the very last item in the list back to the top.

10 -> 9 -> 8 ... -> 1

How to move image layers up/down
 * Use menu **Layer / Rize Layer / Lower Layer** 
 * Use buttons at the bottom of the layers window
 * Use **Ctrl+Shift+Up / Down** hot keys
## Controls ##
Use Ctrl + Up/Down to move current object/layer up/down withing the list.

Middle mouse key / Wheel to pan the whole level.

Ctrl + Wheel up/down to zoom in/out.

Hold Shift key on drawing an object to keep proportions.

[Tiled Keyboard Shortcuts](https://github.com/bjorn/tiled/wiki/Keyboard-Shortcuts)