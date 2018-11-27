return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.1",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 80,
  height = 20,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 13,
  nextobjectid = 58,
  backgroundcolor = { 0, 0, 255 },
  properties = {
    ["nextmap"] = "stage1b_map"
  },
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
          type = "",
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
          type = "",
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
          type = "",
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
          type = "",
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
          type = "",
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
          type = "",
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
          type = "",
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
          type = "",
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
        },
        {
          id = 46,
          name = "ev1players",
          type = "event",
          shape = "rectangle",
          x = 318.667,
          y = 225.333,
          width = 34.6667,
          height = 45,
          rotation = 0,
          visible = true,
          properties = {
            ["animation"] = "run",
            ["duration"] = "2",
            ["face"] = "-1",
            ["go"] = "ev1goPlayers",
            ["move"] = "players"
          }
        },
        {
          id = 49,
          name = "ev1goPlayers",
          type = "event",
          shape = "point",
          x = 262.5,
          y = 250.5,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 50,
          name = "ev1one",
          type = "event",
          shape = "rectangle",
          x = 332.667,
          y = 272.5,
          width = 34.6667,
          height = 45,
          rotation = 0,
          visible = true,
          properties = {
            ["animation"] = "walk",
            ["duration"] = "3",
            ["go"] = "ev1goPlayer",
            ["move"] = "player"
          }
        },
        {
          id = 51,
          name = "ev1goPlayer",
          type = "event",
          shape = "point",
          x = 435.5,
          y = 300,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 54,
          name = "eventExitDoor",
          type = "event",
          shape = "rectangle",
          x = 384.545,
          y = 211.939,
          width = 30.6667,
          height = 17.3333,
          rotation = 0,
          visible = true,
          properties = {
            ["duration"] = "5",
            ["fadeout"] = "",
            ["go"] = "evExitDoorPos",
            ["nextevent"] = "eventExitDoorBack"
          }
        },
        {
          id = 55,
          name = "evExitDoorPos",
          type = "event",
          shape = "point",
          x = 398.788,
          y = 215.152,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 56,
          name = "eventExitDoorBack",
          type = "event",
          shape = "rectangle",
          x = 384.364,
          y = 142.485,
          width = 30.6667,
          height = 17.3333,
          rotation = 0,
          visible = true,
          properties = {
            ["duration"] = "2",
            ["fadein"] = "",
            ["go"] = "evExitDoorPos2"
          }
        },
        {
          id = 57,
          name = "evExitDoorPos2",
          type = "event",
          shape = "point",
          x = 399.697,
          y = 228.788,
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
          properties = {
            ["music"] = "zaburap"
          },
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
          properties = {
            ["music"] = "stage1"
          },
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
