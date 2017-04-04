# Editing Zabuyaki with Tiled #
Download Tiled [Tiled Map Editor](http://www.mapeditor.org) or [GitHub](https://github.com/bjorn/tiled)

## Stages naming ##
Default stage name template: StageX_data.tmx

## Export stages to Zabuyaki ##
Use File/Export as... stageX_data.lua 

## Creating a new file ##
Press Ctrl + N. Set the orientation to Orthogonal. LAyer format to CSV and Tile order to Left Up.

Zabuyaki uses no tile layer. But you can set tile size to use it as a grid for aligning images and objects.

Then press Ok. Now you should delete default Tile Layer.

## Collision objects (walls) ##
Go to the layers tab. Create "Object layer". Rename it to "collision".
Only the first "collision" layer will be used. All the rest object layers named "collision" will be ignored. 

Now you can add collision objects into the game.
Name them properly. Try to use different names for repeating pieces.

Zabuyaki accepts 1 type of the objects: "wall". On adding an object you should fill in its type property with "wall".

You can setup Tiled to show different types of the objects with different colours. Use menu View / Object types editor to set the colours. They are kept for a local user/PC only.
 
To select / edit certain objects go to he "Objects" tab (at the right) and expand the collision layer list.

## Background images ##
Every BG image goes into its own layer. Go to the Layers tab. Create Image layer.

Name bg images for your easy editing.
 
Set property Visible to false if you don't want to see this image in the game. You can toggle it later.
  
e.g. I use a big stage picture as a template. You can vary its transparency level.
It is good for positioning. But this property value is ignored in Zabuyaki.

## Stage BG color ##
Soon

## Define enemy batches ##
Not implemented yet

## Define enemy withing a batch ##
Not implemented yet

## Define Y coordinate camera posotioning ##
Not implemented yet

## In-Game drawing order ##
The BG images are drawn starting from the very last item in the list back to the top.

10 -> 9 -> 8 ... -> 1

Use it to arrange items.

## Controls ##
Use Ctrl + Up/Down to move current object/layer up/down withing the list.

Middle mouse key / Wheel to pan the whole level.

Ctrl + Wheel up/down to zoom in/out.

Hold Shift key on drawing an object to keep proportions.

[Tiled Keyboard Shortcuts](https://github.com/bjorn/tiled/wiki/Keyboard-Shortcuts)