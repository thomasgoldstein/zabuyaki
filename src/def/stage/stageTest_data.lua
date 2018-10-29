return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.0",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 140,
  height = 70,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 19,
  nextobjectid = 61,
  backgroundcolor = { 231, 207, 157 },
  properties = {},
  tilesets = {},
  layers = {
    {
      type = "group",
      id = 1,
      name = "background",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "imagelayer",
          id = 2,
          name = "road0",
          visible = true,
          opacity = 1,
          offsetx = 12,
          offsety = 430,
          image = "../../../res/img/stage/stage1/road1.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 3,
          name = "road1",
          visible = true,
          opacity = 1,
          offsetx = -348,
          offsety = 430,
          image = "../../../res/img/stage/stage1/road1.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 4,
          name = "road2",
          visible = true,
          opacity = 1,
          offsetx = 372,
          offsety = 430,
          image = "../../../res/img/stage/stage1/road1.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 5,
          name = "road3",
          visible = true,
          opacity = 1,
          offsetx = 732,
          offsety = 430,
          image = "../../../res/img/stage/stage1/road1.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 6,
          name = "road4",
          visible = true,
          opacity = 1,
          offsetx = 1092,
          offsety = 430,
          image = "../../../res/img/stage/stage1/road1.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 7,
          name = "road5",
          visible = true,
          opacity = 1,
          offsetx = 1452,
          offsety = 430,
          image = "../../../res/img/stage/stage1/road1.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 8,
          name = "diag road",
          visible = true,
          opacity = 1,
          offsetx = 1812,
          offsety = 251,
          image = "../../../res/img/stage/stage1/road2.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 9,
          name = "building3",
          visible = true,
          opacity = 1,
          offsetx = 870,
          offsety = 69,
          image = "../../../res/img/stage/stage1/building1.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 10,
          name = "building4",
          visible = true,
          opacity = 1,
          offsetx = 1315,
          offsety = 69,
          image = "../../../res/img/stage/stage1/building2.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 11,
          name = "building2",
          visible = true,
          opacity = 1,
          offsetx = 425,
          offsety = 69,
          image = "../../../res/img/stage/stage1/building2.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 12,
          name = "building1",
          visible = true,
          opacity = 1,
          offsetx = -20,
          offsety = 69,
          image = "../../../res/img/stage/stage1/building1.png",
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 13,
      name = "camera",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 11,
          name = "vert pos of camera",
          type = "camera",
          shape = "polyline",
          x = -4,
          y = 551,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polyline = {
            { x = 0, y = 0 },
            { x = 1830, y = 0 },
            { x = 2208, y = -180 },
            { x = 4034, y = -180 }
          },
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 14,
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
          name = "bottom road 1",
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
      type = "objectgroup",
      id = 15,
      name = "batch",
      visible = true,
      opacity = 0.18,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 12,
          name = "1",
          type = "batch",
          shape = "rectangle",
          x = -62.6667,
          y = 69.3333,
          width = 500,
          height = 621.333,
          rotation = 0,
          visible = true,
          properties = {
            ["delay"] = "0"
          }
        },
        {
          id = 14,
          name = "2",
          type = "batch",
          shape = "rectangle",
          x = 400,
          y = 34,
          width = 600,
          height = 678,
          rotation = 0,
          visible = true,
          properties = {
            ["delay"] = "0"
          }
        },
        {
          id = 15,
          name = "3",
          type = "batch",
          shape = "rectangle",
          x = 900,
          y = 64,
          width = 600,
          height = 598,
          rotation = 0,
          visible = true,
          properties = {
            ["delay"] = "0"
          }
        },
        {
          id = 16,
          name = "4",
          type = "batch",
          shape = "rectangle",
          x = 1440,
          y = 22,
          width = 2700,
          height = 686,
          rotation = 0,
          visible = true,
          properties = {
            ["delay"] = "0"
          }
        }
      }
    },
    {
      type = "objectgroup",
      id = 16,
      name = "unit",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 17,
          name = "Gopper",
          type = "unit",
          shape = "point",
          x = 528,
          y = 468,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "2",
            ["class"] = "gopper",
            ["delay"] = "0",
            ["flip"] = true,
            ["palette"] = "2",
            ["state"] = "intro"
          }
        },
        {
          id = 22,
          name = "Niko",
          type = "unit",
          shape = "point",
          x = 260,
          y = 480,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "1",
            ["class"] = "niko",
            ["delay"] = "0",
            ["state"] = "intro2"
          }
        },
        {
          id = 23,
          name = "Sveta",
          type = "unit",
          shape = "point",
          x = 208,
          y = 472,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "1",
            ["class"] = "sveta"
          }
        },
        {
          id = 25,
          name = "Zeena",
          type = "unit",
          shape = "point",
          x = 256,
          y = 524,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "1",
            ["class"] = "zeena",
            ["drop"] = "apple",
            ["state"] = "stand"
          }
        },
        {
          id = 26,
          name = "Beatnick",
          type = "unit",
          shape = "point",
          x = 692.667,
          y = 498.667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "2",
            ["class"] = "beatnick"
          }
        },
        {
          id = 27,
          name = "Satoff",
          type = "unit",
          shape = "point",
          x = 1247.33,
          y = 505.333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "3",
            ["class"] = "satoff"
          }
        },
        {
          id = 28,
          name = "Gopper",
          type = "unit",
          shape = "point",
          x = 614,
          y = 492,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "2",
            ["class"] = "niko"
          }
        },
        {
          id = 29,
          name = "Niko",
          type = "unit",
          shape = "point",
          x = 638,
          y = 473.333,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "2",
            ["class"] = "niko",
            ["state"] = "stand"
          }
        },
        {
          id = 30,
          name = "Zeena",
          type = "unit",
          shape = "point",
          x = 700,
          y = 504.667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "2",
            ["class"] = "zeena",
            ["delay"] = "5",
            ["drop"] = "apple",
            ["state"] = "walk"
          }
        },
        {
          id = 31,
          name = "Sveta",
          type = "unit",
          shape = "point",
          x = 1365.33,
          y = 492.667,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "3",
            ["class"] = "sveta",
            ["state"] = "intro"
          }
        },
        {
          id = 32,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 80,
          y = 496,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "chicken",
            ["palette"] = "0"
          }
        },
        {
          id = 33,
          name = "Stop Sign",
          type = "unit",
          shape = "point",
          x = 232,
          y = 460,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "sign",
            ["drop"] = "apple"
          }
        },
        {
          id = 39,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 80,
          y = 460,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "beef",
            ["flip"] = true
          }
        },
        {
          id = 40,
          name = "Gopper",
          type = "unit",
          shape = "point",
          x = 300,
          y = 500,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "1",
            ["class"] = "gopper",
            ["palette"] = "3",
            ["state"] = "intro2"
          }
        },
        {
          id = 41,
          name = "Gopper",
          type = "unit",
          shape = "point",
          x = 512,
          y = 520,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "2",
            ["class"] = "gopper",
            ["palette"] = "4"
          }
        },
        {
          id = 42,
          name = "Gopper",
          type = "unit",
          shape = "point",
          x = 556,
          y = 500,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["batch"] = "2",
            ["class"] = "gopper",
            ["palette"] = "1"
          }
        },
        {
          id = 50,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 128,
          y = 460,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "bat"
          }
        },
        {
          id = 52,
          name = "Stop Sign2",
          type = "unit",
          shape = "point",
          x = 80,
          y = 528,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "sign",
            ["drop"] = "apple"
          }
        },
        {
          id = 53,
          name = "Stop Sign4",
          type = "unit",
          shape = "point",
          x = 172,
          y = 540,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "sign",
            ["drop"] = ""
          }
        },
        {
          id = 54,
          name = "Stop Sign3",
          type = "unit",
          shape = "point",
          x = 272,
          y = 516,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "sign",
            ["drop"] = "apple"
          }
        },
        {
          id = 55,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 176,
          y = 460,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "chicken",
            ["palette"] = "0"
          }
        },
        {
          id = 56,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 128,
          y = 528,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "",
            ["palette"] = "0"
          }
        },
        {
          id = 57,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 168,
          y = 500,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "",
            ["palette"] = "0"
          }
        },
        {
          id = 58,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 232,
          y = 504,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "apple",
            ["palette"] = "0"
          }
        },
        {
          id = 59,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 132,
          y = 492,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "apple",
            ["palette"] = "0"
          }
        },
        {
          id = 60,
          name = "Trash Can",
          type = "unit",
          shape = "point",
          x = 204,
          y = 516,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["class"] = "trashcan",
            ["drop"] = "",
            ["palette"] = "0"
          }
        }
      }
    },
    {
      type = "objectgroup",
      id = 17,
      name = "player",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 43,
          name = "1",
          type = "player",
          shape = "point",
          x = 50.5,
          y = 462.5,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["state"] = "walk"
          }
        },
        {
          id = 44,
          name = "3",
          type = "player",
          shape = "point",
          x = 10,
          y = 503.25,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["state"] = "walk"
          }
        },
        {
          id = 45,
          name = "2",
          type = "player",
          shape = "point",
          x = 31.75,
          y = 481.75,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["state"] = "walk"
          }
        }
      }
    },
    {
      type = "objectgroup",
      id = 18,
      name = "trash",
      visible = true,
      opacity = 0.11,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {}
    }
  }
}
