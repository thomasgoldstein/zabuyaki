return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.18.2",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 160,
  height = 70,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 4,
  properties = {},
  tilesets = {
    {
      name = "coll",
      firstgid = 1,
      tilewidth = 74,
      tileheight = 218,
      spacing = 0,
      margin = 0,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 2,
      tiles = {
        {
          id = 0,
          image = "../Zabuyaki/res/img/misc/ui.png",
          width = 35,
          height = 43
        },
        {
          id = 1,
          image = "../Zabuyaki/res/img/misc/portraits.png",
          width = 74,
          height = 218
        }
      }
    }
  },
  layers = {
    {
      type = "imagelayer",
      name = "bg image",
      visible = false,
      opacity = 1,
      offsetx = 3,
      offsety = -3,
      image = "stage.png",
      properties = {}
    },
    {
      type = "imagelayer",
      name = "road1",
      visible = true,
      opacity = 1,
      offsetx = 51,
      offsety = 427,
      image = "stage1/road.png",
      properties = {}
    },
    {
      type = "imagelayer",
      name = "building 1",
      visible = true,
      opacity = 1,
      offsetx = -16,
      offsety = 64,
      image = "stage1/building1.png",
      properties = {}
    },
    {
      type = "objectgroup",
      name = "collision",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 1,
          name = "bottom road 1",
          type = "wall",
          shape = "rectangle",
          x = 19,
          y = 545,
          width = 730,
          height = 98,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "som1",
          type = "wall",
          shape = "polygon",
          x = 1823,
          y = 459,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -5, y = -277 },
            { x = 362, y = -275 },
            { x = 359, y = -174 }
          },
          properties = {}
        },
        {
          id = 3,
          name = "some2",
          type = "wall",
          shape = "polygon",
          x = 1837,
          y = 544,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 370, y = -178 },
            { x = 372, y = 87 },
            { x = -3, y = 87 }
          },
          properties = {}
        }
      }
    },
    {
      type = "tilelayer",
      name = "Слой тайлов 1",
      x = 0,
      y = 0,
      width = 160,
      height = 70,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJztzjEBAAAEADD0D80jA8eWYBEAAAAAAACsvA7AqOsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbzVrWgAE"
    },
    {
      type = "tilelayer",
      name = "batch",
      x = 0,
      y = 0,
      width = 160,
      height = 70,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["n"] = "1"
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJztzkERAAAEADD0Dy2CJ3e2BIsAAAAAAAAArqvtAAA8kdsBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABg0YSIABA=="
    }
  }
}
