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
  nextlayerid = 26,
  nextobjectid = 84,
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
      id = 25,
      name = "permanent",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 82,
          name = "PTR.CAN",
          type = "trashcan",
          shape = "point",
          x = 67.3333,
          y = 514,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 83,
          name = "PTR.CAN2",
          type = "trashcan",
          shape = "point",
          x = 124.667,
          y = 526.667,
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
      id = 19,
      name = "batch",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "objectgroup",
          id = 24,
          name = "4",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
          objects = {
            {
              id = 62,
              name = "4",
              type = "batch",
              shape = "rectangle",
              x = 1489.39,
              y = 32.7576,
              width = 2087.88,
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
          id = 23,
          name = "3",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
          objects = {
            {
              id = 64,
              name = "3",
              type = "batch",
              shape = "rectangle",
              x = 933.333,
              y = 49.4848,
              width = 600,
              height = 598,
              rotation = 0,
              visible = true,
              properties = {
                ["delay"] = "0"
              }
            },
            {
              id = 80,
              name = "Satoff",
              type = "satoff",
              shape = "point",
              x = 1286,
              y = 514.666,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "3"
              }
            },
            {
              id = 81,
              name = "Sveta",
              type = "sveta",
              shape = "point",
              x = 1404,
              y = 502,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "3",
                ["state"] = "intro"
              }
            }
          }
        },
        {
          type = "objectgroup",
          id = 22,
          name = "2",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
          objects = {
            {
              id = 63,
              name = "2",
              type = "batch",
              shape = "rectangle",
              x = 430.303,
              y = 45.8485,
              width = 600,
              height = 678,
              rotation = 0,
              visible = true,
              properties = {
                ["delay"] = "0"
              }
            },
            {
              id = 73,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 528,
              y = 468,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "2",
                ["delay"] = "0",
                ["flip"] = true,
                ["palette"] = "2",
                ["state"] = "intro"
              }
            },
            {
              id = 74,
              name = "Beatnick",
              type = "beatnick",
              shape = "point",
              x = 692.667,
              y = 498.667,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "2"
              }
            },
            {
              id = 75,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 614,
              y = 492,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "2"
              }
            },
            {
              id = 76,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 638,
              y = 473.333,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "2",
                ["state"] = "stand"
              }
            },
            {
              id = 77,
              name = "Zeena",
              type = "zeena",
              shape = "point",
              x = 700,
              y = 504.667,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "2",
                ["delay"] = "5",
                ["drop"] = "apple",
                ["state"] = "walk"
              }
            },
            {
              id = 78,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 512,
              y = 520,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "2",
                ["palette"] = "4"
              }
            },
            {
              id = 79,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 556,
              y = 500,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "2",
                ["palette"] = "1"
              }
            }
          }
        },
        {
          type = "objectgroup",
          id = 21,
          name = "1",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
          objects = {
            {
              id = 61,
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
              id = 65,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 260,
              y = 480,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "1",
                ["delay"] = "0",
                ["state"] = "intro2"
              }
            },
            {
              id = 66,
              name = "Sveta",
              type = "sveta",
              shape = "point",
              x = 208,
              y = 472,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "1"
              }
            },
            {
              id = 67,
              name = "Zeena",
              type = "zeena",
              shape = "point",
              x = 256,
              y = 524,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "1",
                ["drop"] = "apple",
                ["state"] = "stand"
              }
            },
            {
              id = 68,
              name = "Stop Sign",
              type = "sign",
              shape = "point",
              x = 232,
              y = 460,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["drop"] = "apple"
              }
            },
            {
              id = 69,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 300,
              y = 500,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["batch"] = "1",
                ["palette"] = "3",
                ["state"] = "intro2"
              }
            },
            {
              id = 70,
              name = "Trash Can",
              type = "trashcan",
              shape = "point",
              x = 328,
              y = 528,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["drop"] = "chicken",
                ["palette"] = "0"
              }
            },
            {
              id = 71,
              name = "Trash Can",
              type = "trashcan",
              shape = "point",
              x = 152,
              y = 492,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["drop"] = "",
                ["palette"] = "0"
              }
            },
            {
              id = 72,
              name = "Trash Can",
              type = "trashcan",
              shape = "point",
              x = 100,
              y = 492,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["drop"] = "apple",
                ["palette"] = "0"
              }
            }
          }
        }
      }
    }
  }
}
