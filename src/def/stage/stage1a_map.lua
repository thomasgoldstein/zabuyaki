return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.0",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 80,
  height = 20,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 12,
  nextobjectid = 46,
  properties = {},
  tilesets = {},
  layers = {
    {
      type = "group",
      id = 6,
      name = "background",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "imagelayer",
          id = 8,
          name = "bg",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          image = "../../../res/img/stage/stage1/stage1a.png",
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 5,
      name = "camera",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 7,
          name = "",
          type = "camera",
          shape = "polyline",
          x = 0,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polyline = {
            { x = 0, y = 0 },
            { x = 1024, y = 0 },
            { x = 1664, y = 320 },
            { x = 2560, y = 320 }
          },
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 2,
      name = "collision",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 9,
          name = "",
          type = "wall",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 2560,
          height = 224,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 10,
          name = "",
          type = "wall",
          shape = "rectangle",
          x = 0,
          y = 320,
          width = 1024,
          height = 320,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "",
          type = "wall",
          shape = "polygon",
          x = 1184,
          y = 224,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 640, y = 320 },
            { x = 640, y = 0 }
          },
          properties = {}
        },
        {
          id = 13,
          name = "",
          type = "wall",
          shape = "rectangle",
          x = 1824,
          y = 224,
          width = 736,
          height = 320,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 15,
          name = "",
          type = "wall",
          shape = "polygon",
          x = 1024,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 640, y = 320 },
            { x = 0, y = 320 }
          },
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 1,
      name = "player",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 1,
          name = "1",
          type = "player",
          shape = "point",
          x = 48,
          y = 256,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "2",
          type = "player",
          shape = "point",
          x = 32,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "3",
          type = "player",
          shape = "point",
          x = 16,
          y = 304,
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
      id = 8,
      name = "global",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 27,
          name = "Trash Can",
          type = "trashcan",
          shape = "point",
          x = 544,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 28,
          name = "Sign",
          type = "sign",
          shape = "point",
          x = 1472,
          y = 384,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 29,
          name = "Trash Can",
          type = "trashcan",
          shape = "point",
          x = 1888,
          y = 560,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["drop"] = "apple"
          }
        }
      }
    },
    {
      type = "group",
      id = 7,
      name = "batch",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "objectgroup",
          id = 11,
          name = "4",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
          objects = {
            {
              id = 34,
              name = "4",
              type = "batch",
              shape = "rectangle",
              x = 1920,
              y = 0,
              width = 640,
              height = 640,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 40,
              name = "Zeena",
              type = "zeena",
              shape = "point",
              x = 2176,
              y = 608,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 41,
              name = "Beatnick",
              type = "beatnick",
              shape = "point",
              x = 2272,
              y = 576,
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
          id = 10,
          name = "3",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
          objects = {
            {
              id = 32,
              name = "3",
              type = "batch",
              shape = "rectangle",
              x = 1280,
              y = 0,
              width = 640,
              height = 640,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 36,
              name = "Sveta",
              type = "sveta",
              shape = "point",
              x = 1632,
              y = 512,
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
          id = 9,
          name = "2",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
          objects = {
            {
              id = 31,
              name = "2",
              type = "batch",
              shape = "rectangle",
              x = 640,
              y = 0,
              width = 640,
              height = 640,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 35,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 960,
              y = 288,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 42,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 256,
              y = 248,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 43,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 216,
              y = 288,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 44,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 1024,
              y = 256,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 45,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 840,
              y = 272,
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
          id = 3,
          name = "1",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
          objects = {
            {
              id = 11,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 224,
              y = 256,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 30,
              name = "1",
              type = "batch",
              shape = "rectangle",
              x = 0,
              y = 0,
              width = 640,
              height = 640,
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
