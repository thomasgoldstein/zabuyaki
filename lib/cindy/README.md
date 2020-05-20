# cindy
True Colors for LÖVE 11

cindy adds functions to LÖVE 11.x that accept/return colors in the [0-255] range instead of the newly introduced
[0.0-1.0] range.

In love.graphics:
- `clearBytes`
- `getColorBytes`, `setColorBytes`
- `getBackgroundColorBytes`, `setBackgroundColorBytes`
- `getColorMaskBytes`, `setColorMaskBytes`

In ImageData:
- `getPixelBytes`, `setPixelBytes`
- `mapPixelBytes`

In ParticleSystem:
- `setColorsBytes`, `getColorsBytes`

In SpriteBatch:
- `getColorBytes`, `setColorBytes`

In Shader:
- `sendColorBytes`

These functions behave the same as their built-in counterparts, except for the different value range. Note that calling them has additional runtime costs in comparison to the original functions.

To replace all original functions, call `cindy.applyPatch()` at the start of the program: `require('cindy').applyPatch()`. This effectively restores the pre-11.0 behavior.
