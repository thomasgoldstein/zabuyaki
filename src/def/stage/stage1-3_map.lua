return {
  version = "1.4",
  luaversion = "5.1",
  tiledversion = "1.4.3",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 54,
  height = 20,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 19,
  nextobjectid = 38,
  backgroundcolor = { 0, 85, 0 },
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
          image = "../../../res/img/stage/stage1/stage1-3_bg_2.png",
          id = 17,
          name = "bg2",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          properties = {
            ["relativeX"] = "0.35"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-3_bg_1.png",
          id = 18,
          name = "bg1",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          properties = {
            ["relativeX"] = "0.15"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-3.png",
          id = 2,
          name = "bg",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          properties = {}
        }
      }
    },
    {
      type = "group",
      id = 3,
      name = "foreground",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {}
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 8,
      name = "camera",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      objects = {
        {
          id = 1,
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
            { x = 384, y = 0 },
            { x = 680, y = 144 },
            { x = 1728, y = 144 }
          },
          properties = {}
        },
        {
          id = 37,
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
            { x = 384, y = 0 },
            { x = 680, y = 144 },
            { x = 1728, y = 144 }
          },
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 9,
      name = "collision",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      objects = {
        {
          id = 4,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1860,
          y = 0,
          width = 64,
          height = 648,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "",
          type = "",
          shape = "rectangle",
          x = -128,
          y = 0,
          width = 1988,
          height = 240,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "",
          shape = "rectangle",
          x = -192,
          y = 0,
          width = 64,
          height = 648,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 10,
      name = "players",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      objects = {
        {
          id = 5,
          name = "1",
          type = "",
          shape = "point",
          x = 64,
          y = 288,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 6,
          name = "2",
          type = "",
          shape = "point",
          x = 40,
          y = 288,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        },
        {
          id = 7,
          name = "3",
          type = "",
          shape = "point",
          x = 16,
          y = 288,
          width = 0,
          height = 0,
          rotation = 0,
          visible = false,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 11,
      name = "global",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      objects = {
        {
          id = 8,
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
          id = 9,
          name = "leaveMap",
          type = "event",
          shape = "point",
          x = 1752,
          y = 344,
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
          id = 10,
          name = "exit",
          type = "event",
          shape = "point",
          x = 1752,
          y = 432,
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
      id = 12,
      name = "waves",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "objectgroup",
          draworder = "topdown",
          id = 13,
          name = "3",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          properties = {
            ["maxActiveEnemies"] = 5,
            ["music"] = "zaburap",
            ["onComplete"] = "leaveMap"
          },
          objects = {
            {
              id = 11,
              name = "3",
              type = "wave",
              shape = "rectangle",
              x = 960,
              y = 0,
              width = 768,
              height = 640,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 16,
              name = "Satoff",
              type = "satoff",
              shape = "point",
              x = 1368,
              y = 408,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["palette"] = "blue"
              }
            }
          }
        },
        {
          type = "objectgroup",
          draworder = "topdown",
          id = 14,
          name = "2",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          properties = {
            ["maxActiveEnemies"] = 4
          },
          objects = {
            {
              id = 26,
              name = "2",
              type = "wave",
              shape = "rectangle",
              x = 480,
              y = 0,
              width = 480,
              height = 640,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 18,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 752,
              y = 424,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            }
          }
        },
        {
          type = "objectgroup",
          draworder = "topdown",
          id = 15,
          name = "1",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          properties = {
            ["maxActiveEnemies"] = 3,
            ["music"] = "stage1",
            ["onStart"] = "enterMap"
          },
          objects = {
            {
              id = 27,
              name = "1",
              type = "wave",
              shape = "rectangle",
              x = 0,
              y = 0,
              width = 480,
              height = 640,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 28,
              name = "Maksim",
              type = "gopper",
              shape = "point",
              x = 288,
              y = 248,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "black",
                ["spawnDelay"] = 2
              }
            }
          }
        }
      }
    }
  }
}
