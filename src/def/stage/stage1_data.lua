return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.18.2",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 140,
  height = 70,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 11,
  properties = {},
  tilesets = {},
  layers = {
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
          id = 4,
          name = "bottom road 2",
          type = "wall",
          shape = "rectangle",
          x = -13,
          y = 546,
          width = 1848,
          height = 94,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "top road 1",
          type = "wall",
          shape = "rectangle",
          x = 5,
          y = 358,
          width = 1818.91,
          height = 101,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "bottom road 2",
          type = "wall",
          shape = "rectangle",
          x = 2205.27,
          y = 368,
          width = 1777,
          height = 98,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "top road 2",
          type = "wall",
          shape = "rectangle",
          x = 2186,
          y = 180,
          width = 1794,
          height = 100,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 9,
          name = "upper diag road",
          type = "wall",
          shape = "polygon",
          x = 1822.5,
          y = 458.5,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -4, y = -289 },
            { x = 363, y = -288 },
            { x = 365, y = -180 }
          },
          properties = {}
        },
        {
          id = 10,
          name = "bott diag road",
          type = "wall",
          shape = "polygon",
          x = 1834.18,
          y = 547.409,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0.1875, y = -1.1875 },
            { x = 371.497, y = -179.5 },
            { x = 370.995, y = 93 },
            { x = -1.00269, y = 93 }
          },
          properties = {}
        }
      }
    },
    {
      type = "imagelayer",
      name = "bg template",
      visible = true,
      opacity = 0.6,
      offsetx = 0,
      offsety = 0,
      image = "../../../../ZabuTiled/stage.png",
      properties = {}
    }
  }
}
