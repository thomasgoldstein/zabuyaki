sh_replace_3_colors = [[
        extern vec4 colors[3];
        extern vec4 newColors[3];
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        if (pixel == colors[0])
            return newColors[0];
        if (pixel == colors[1])
            return newColors[1];
        if (pixel == colors[2])
            return newColors[2];
        return pixel;
    }    ]]

--usage:
--local sh_player2 = love.graphics.newShader(sh_replace_3_colors)
--sh_player2:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
--sh_player2:sendColor("newColors", {77,111,158, 255},  {49,73,130, 255},  {28,42,73, 255})

sh_replace_4_colors = [[
        extern vec4 colors[4];
        extern vec4 newColors[4];
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
        if (pixel == colors[0])
            return newColors[0];
        if (pixel == colors[1])
            return newColors[1];
        if (pixel == colors[2])
            return newColors[2];
        if (pixel == colors[3])
            return newColors[3];
        return pixel;
    }    ]]

sh_noise = love.graphics.newShader([[
extern float factor = 1;
extern float addPercent = 0.1;
extern float clamp = 0.85;

// from http://www.ozone3d.net/blogs/lab/20110427/glsl-random-generator/
float rand(vec2 n)
    {
        return 0.5 + 0.5 * fract(sin(dot(n.xy, vec2(12.9898, 78.233))) * 43758.5453);
    }

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
{
    float grey = 1 * rand(tc * factor);
    float clampedGrey = max(grey, clamp);
    vec4 noise = vec4(grey, grey, grey, 1);
    vec4 clampedNoise = vec4(clampedGrey, clampedGrey, clampedGrey, 1);
    return (Texel(tex, tc) * clampedNoise * (1 - addPercent) + noise * addPercent) * color;
}   ]])

sh_screen = love.graphics.newShader([[
        vec4 effect(vec4 colour, Image image, vec2 local, vec2 screen)
        {
            // red and green scale with proportion of screen coordinates
            vec4 screen_colour = vec4(screen.x / 512.0,
                                      screen.y / 512.0,
                                      0.0,
                                      1.0);

            return screen_colour;
        }
    ]])

sh_texture = love.graphics.newShader([[
        vec4 effect(vec4 colour, Image image, vec2 local, vec2 screen)
        {
            // red and green components scale with texture coordinates
            vec4 coord_colour = vec4(local.x, local.y, 0.0, 1.0);
            // use the appropriate pixel from the texture
            vec4 image_colour = Texel(image, local);
            // mix the two colours equally
            return mix(coord_colour, image_colour, 0.5);
        }
    ]])

sh_outline = love.graphics.newShader([[vec4 resultCol;
extern number stepSize;
number alpha;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
    {
        // get color of pixels:
alpha = texture2D( texture, texturePos + vec2(0,-stepSize)).a;
alpha -= texture2D( texture, texturePos + vec2(0,stepSize) ).a;

// calculate resulting color
resultCol = vec4( 1.0f, 1.0f, 1.0f, 0.5f*alpha );
// return color for current pixel
return resultCol;
}
]])

--sh_outline:send( "stepSize",{1/640,1/480} )