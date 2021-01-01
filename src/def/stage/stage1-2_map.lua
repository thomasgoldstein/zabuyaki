return {
  version = "1.4",
  luaversion = "5.1",
  tiledversion = "1.4.3",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 45,
  height = 10,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 16,
  nextobjectid = 36,
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
          image = "../../../res/img/stage/stage1/stage1-2.png",
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
      layers = {
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-2_fg_2-foreground lights 2.png",
          id = 4,
          name = "fg-3",
          visible = true,
          opacity = 1,
          offsetx = 200,
          offsety = 18,
          properties = {
            ["relativeX"] = "-0.8"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-2_fg_2-foreground lights 1.png",
          id = 5,
          name = "fg-2",
          visible = true,
          opacity = 1,
          offsetx = 200,
          offsety = 18,
          properties = {
            ["relativeX"] = "-0.8"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-2_fg_1.png",
          id = 6,
          name = "fg-1",
          visible = true,
          opacity = 1,
          offsetx = 200,
          offsety = -2,
          properties = {
            ["relativeX"] = "-0.5"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-2_fg.png",
          id = 7,
          name = "fg",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          properties = {}
        }
      }
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
            { x = 1280, y = 0 }
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
          id = 2,
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
          id = 3,
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
          id = 4,
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
          x = 48,
          y = 265,
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
          x = 32,
          y = 285,
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
          y = 305,
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
          x = 1408,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["animation"] = "stand",
            ["duration"] = 2,
            ["gox"] = 0,
            ["nextevent"] = "exit"
          }
        },
        {
          id = 10,
          name = "exit",
          type = "event",
          shape = "point",
          x = 1464,
          y = 256,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["go"] = "exit",
            ["nextevent"] = "nextmap",
            ["nextmap"] = "stage1-3_map"
          }
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
              width = 480,
              height = 320,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 12,
              name = "Booze",
              type = "hooch",
              shape = "point",
              x = 1232,
              y = 288,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 13,
              name = "Hooch",
              type = "hooch",
              shape = "point",
              x = 1288,
              y = 280,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 14,
              name = "Inga",
              type = "sveta",
              shape = "point",
              x = 1320,
              y = 264,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 15,
              name = "Zeena",
              type = "zeena",
              shape = "point",
              x = 1360,
              y = 304,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "blackred",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 16,
              name = "Satoff",
              type = "satoff",
              shape = "point",
              x = 1400,
              y = 272,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["spawnDelay"] = 2
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
              id = 17,
              name = "Sveta",
              type = "sveta",
              shape = "point",
              x = 768,
              y = 272,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 18,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 816,
              y = 256,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 19,
              name = "Bogdan",
              type = "gopper",
              shape = "point",
              x = 856,
              y = 296,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 20,
              name = "Alexey",
              type = "niko",
              shape = "point",
              x = 504,
              y = 264,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "left",
                ["palette"] = "green",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 21,
              name = "Dima",
              type = "niko",
              shape = "point",
              x = 888,
              y = 256,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["color"] = "black",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 22,
              name = "Alex",
              type = "gopper",
              shape = "point",
              x = 536,
              y = 296,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "left",
                ["palette"] = "black",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 23,
              name = "Anna",
              type = "zeena",
              shape = "point",
              x = 568,
              y = 256,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "left",
                ["palette"] = "pink",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 24,
              name = "Reta",
              type = "zeena",
              shape = "point",
              x = 600,
              y = 288,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 25,
              name = "Nitsa",
              type = "zeena",
              shape = "point",
              x = 928,
              y = 304,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "black",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 26,
              name = "2",
              type = "wave",
              shape = "rectangle",
              x = 480,
              y = 0,
              width = 480,
              height = 320,
              rotation = 0,
              visible = true,
              properties = {}
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
              height = 320,
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
            },
            {
              id = 29,
              name = "Pavel",
              type = "gopper",
              shape = "point",
              x = 320,
              y = 304,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 30,
              name = "Vadim",
              type = "niko",
              shape = "point",
              x = 352,
              y = 280,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "red",
                ["spawnDelay"] = 1
              }
            },
            {
              id = 31,
              name = "Sergey",
              type = "gopper",
              shape = "point",
              x = 384,
              y = 312,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "black",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 32,
              name = "Pyotr",
              type = "niko",
              shape = "point",
              x = 400,
              y = 248,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "red",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 33,
              name = "Ivan",
              type = "gopper",
              shape = "point",
              x = 440,
              y = 256,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "green",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 34,
              name = "Vasily",
              type = "niko",
              shape = "point",
              x = 24,
              y = 248,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "left",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 35,
              name = "Vlad",
              type = "gopper",
              shape = "point",
              x = 56,
              y = 288,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "left",
                ["palette"] = "blue",
                ["spawnDelay"] = 2
              }
            }
          }
        }
      }
    }
  }
}
