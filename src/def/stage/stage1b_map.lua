return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.3.3",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 44,
  height = 10,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 12,
  nextobjectid = 21,
  backgroundcolor = { 0, 85, 0 },
  properties = {},
  tilesets = {},
  layers = {
    {
      type = "group",
      id = 8,
      name = "background",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "imagelayer",
          id = 9,
          name = "bg",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          image = "../../../res/img/stage/stage1/stage1b.png",
          properties = {}
        }
      }
    },
    {
      type = "group",
      id = 10,
      name = "foreground",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "imagelayer",
          id = 11,
          name = "fg",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          image = "../../../res/img/stage/stage1/stage1b_fg.png",
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 7,
      name = "camera",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 6,
          name = "",
          type = "",
          shape = "polyline",
          x = 0,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polyline = {
            { x = 0, y = 0 },
            { x = 1280, y = 0 }
          },
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 6,
      name = "collision",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 8,
          name = "",
          type = "",
          shape = "rectangle",
          x = -128,
          y = 0,
          width = 1664,
          height = 240,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 17,
          name = "",
          type = "",
          shape = "rectangle",
          x = -192,
          y = 0,
          width = 64,
          height = 320,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 20,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1536,
          y = 0,
          width = 64,
          height = 320,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 5,
      name = "players",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 3,
          name = "1",
          type = "",
          shape = "point",
          x = 48,
          y = 265,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "2",
          type = "",
          shape = "point",
          x = 32,
          y = 285,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "3",
          type = "",
          shape = "point",
          x = 16,
          y = 305,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 4,
      name = "global",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 12,
          name = "enterMap",
          type = "event",
          shape = "point",
          x = 16,
          y = 192,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["togox"] = "-100"
          }
        },
        {
          id = 15,
          name = "leaveMap",
          type = "event",
          shape = "point",
          x = 1135.33,
          y = 189.334,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["go"] = "exit",
            ["nextevent"] = "nextmap",
            ["nextmap"] = "ending"
          }
        },
        {
          id = 16,
          name = "exit",
          type = "event",
          shape = "point",
          x = 1136,
          y = 242.667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "group",
      id = 1,
      name = "waves",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "objectgroup",
          id = 3,
          name = "2",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {
            ["onComplete"] = "leaveMap"
          },
          objects = {
            {
              id = 2,
              name = "2",
              type = "wave",
              shape = "rectangle",
              x = 640,
              y = 0,
              width = 640,
              height = 320,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 10,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 1184,
              y = 256,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {}
            }
          }
        },
        {
          type = "objectgroup",
          id = 2,
          name = "1",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {
            ["music"] = "stage1",
            ["onStart"] = "enterMap"
          },
          objects = {
            {
              id = 1,
              name = "1",
              type = "wave",
              shape = "rectangle",
              x = 0,
              y = 0,
              width = 640,
              height = 320,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 9,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 544,
              y = 256,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {}
            }
          }
        }
      }
    }
  }
}
