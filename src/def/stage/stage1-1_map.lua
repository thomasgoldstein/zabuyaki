return {
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "1.7.0",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 176,
  height = 15,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 39,
  nextobjectid = 53,
  backgroundcolor = { 105, 105, 105 },
  properties = {
    ["enableReflections"] = true,
    ["reflectionsOpacity"] = 0.6
  },
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
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      layers = {
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1/sky.png",
          id = 2,
          name = "sky",
          visible = true,
          opacity = 1,
          offsetx = 29,
          offsety = -3,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["relativeX"] = "-0.45"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1/background-city.png",
          id = 8,
          name = "cityLandscape",
          visible = true,
          opacity = 1,
          offsetx = 29,
          offsety = -3,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["relativeX"] = "-0.25"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1/trees.png",
          id = 38,
          name = "trees",
          visible = true,
          opacity = 1,
          offsetx = 29,
          offsety = -3,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["relativeX"] = "-0.1"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1/main.png",
          id = 16,
          name = "main",
          visible = true,
          opacity = 1,
          offsetx = -3,
          offsety = -3,
          parallaxx = 1,
          parallaxy = 1,
          properties = {}
        },
        {
          type = "group",
          id = 17,
          name = "burn-barrels",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["animate"] = "burn-barrel 1 0.11 2 0.11 3 0.11 4 0.11"
          },
          layers = {
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/burn-barrel-placeholder.png",
              id = 18,
              name = "barrel3",
              visible = true,
              opacity = 1,
              offsetx = 1972,
              offsety = 111,
              parallaxx = 1,
              parallaxy = 1,
              properties = {}
            },
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/burn-barrel-placeholder.png",
              id = 19,
              name = "barrel2",
              visible = true,
              opacity = 1,
              offsetx = 917,
              offsety = 109,
              parallaxx = 1,
              parallaxy = 1,
              properties = {}
            },
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/burn-barrel-placeholder.png",
              id = 20,
              name = "barrel1",
              visible = true,
              opacity = 1,
              offsetx = 434,
              offsety = 109,
              parallaxx = 1,
              parallaxy = 1,
              properties = {}
            }
          }
        }
      }
    },
    {
      type = "group",
      id = 21,
      name = "foreground",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      layers = {
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1/bridge-foreground.png",
          id = 23,
          name = "bridge-foreground",
          visible = true,
          opacity = 1,
          offsetx = 291,
          offsety = -3,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["relativeX"] = "0.2"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1/foreground.png",
          id = 24,
          name = "foreground",
          visible = false,
          opacity = 1,
          offsetx = 328,
          offsety = -80,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["relativeX"] = "0.8"
          }
        }
      }
    },
    {
      type = "group",
      id = 34,
      name = "collision",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      layers = {
        {
          type = "objectgroup",
          draworder = "topdown",
          id = 26,
          name = "collision",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          parallaxx = 1,
          parallaxy = 1,
          properties = {},
          objects = {
            {
              id = 2,
              name = "",
              type = "",
              shape = "rectangle",
              x = -128,
              y = 0,
              width = 3072,
              height = 160,
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
              height = 240,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 4,
              name = "",
              type = "",
              shape = "rectangle",
              x = 2944,
              y = 0,
              width = 64,
              height = 240,
              rotation = 0,
              visible = true,
              properties = {}
            }
          }
        }
      }
    },
    {
      type = "group",
      id = 29,
      name = "waves",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      layers = {
        {
          type = "objectgroup",
          draworder = "topdown",
          id = 30,
          name = "4",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["maxActiveEnemies"] = 5,
            ["onComplete"] = "leaveMap"
          },
          objects = {
            {
              id = 13,
              name = "4",
              type = "wave",
              shape = "rectangle",
              x = 2080,
              y = 0,
              width = 736,
              height = 240,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 14,
              name = "Beatnik",
              type = "beatnik",
              shape = "point",
              x = 2600,
              y = 192,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["flip"] = true,
                ["waitCamera"] = true
              }
            },
            {
              id = 15,
              name = "Igor",
              type = "niko",
              shape = "point",
              x = 2584,
              y = 168,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "dance",
                ["flip"] = true,
                ["palette"] = "blue",
                ["waitCamera"] = true
              }
            },
            {
              id = 16,
              name = "Grichka",
              type = "gopper",
              shape = "point",
              x = 2616,
              y = 224,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "dance",
                ["flip"] = true,
                ["palette"] = "blue",
                ["waitCamera"] = true
              }
            }
          }
        },
        {
          type = "objectgroup",
          draworder = "topdown",
          id = 31,
          name = "3",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["maxActiveEnemies"] = 4
          },
          objects = {
            {
              id = 17,
              name = "3",
              type = "wave",
              shape = "rectangle",
              x = 1440,
              y = 0,
              width = 640,
              height = 240,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 18,
              name = "Booze",
              type = "hooch",
              shape = "point",
              x = 1688,
              y = 192,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["flip"] = true
              }
            },
            {
              id = 19,
              name = "Mila",
              type = "zeena",
              shape = "point",
              x = 1728,
              y = 168,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "squat",
                ["flip"] = true,
                ["palette"] = "blackred"
              }
            },
            {
              id = 20,
              name = "Alex",
              type = "gopper",
              shape = "point",
              x = 1752,
              y = 216,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "squat",
                ["flip"] = true,
                ["palette"] = "black"
              }
            },
            {
              id = 21,
              name = "Mikha",
              type = "gopper",
              shape = "point",
              x = 1824,
              y = 192,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "red",
                ["spawnDelay"] = 3
              }
            },
            {
              id = 22,
              name = "Boyara",
              type = "hooch",
              shape = "point",
              x = 1472,
              y = 192,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "left",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 23,
              name = "Bogdan",
              type = "gopper",
              shape = "point",
              x = 1680,
              y = 192,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "fall",
                ["flip"] = true,
                ["palette"] = "blue",
                ["spawnDelay"] = 2,
                ["z"] = 600
              }
            },
            {
              id = 24,
              name = "Anna",
              type = "zeena",
              shape = "point",
              x = 1920,
              y = 208,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "pink",
                ["spawnDelay"] = 2
              }
            },
            {
              id = 25,
              name = "Alexey",
              type = "niko",
              shape = "point",
              x = 1968,
              y = 176,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "green",
                ["spawnDelay"] = 2
              }
            }
          }
        },
        {
          type = "objectgroup",
          draworder = "topdown",
          id = 32,
          name = "2",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["maxActiveEnemies"] = 4
          },
          objects = {
            {
              id = 26,
              name = "2",
              type = "wave",
              shape = "rectangle",
              x = 800,
              y = 0,
              width = 640,
              height = 240,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 27,
              name = "Zeena",
              type = "zeena",
              shape = "point",
              x = 888,
              y = 192,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "squat",
                ["flip"] = true,
                ["palette"] = "pink"
              }
            },
            {
              id = 28,
              name = "Vik",
              type = "niko",
              shape = "point",
              x = 944,
              y = 208,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["flip"] = true,
                ["palette"] = "black"
              }
            },
            {
              id = 29,
              name = "Ivan",
              type = "gopper",
              shape = "point",
              x = 816,
              y = 192,
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
              id = 30,
              name = "Vlad",
              type = "gopper",
              shape = "point",
              x = 1056,
              y = 176,
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
              id = 31,
              name = "Nitsa",
              type = "zeena",
              shape = "point",
              x = 840,
              y = 176,
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
              id = 32,
              name = "Andrei",
              type = "gopper",
              shape = "point",
              x = 1088,
              y = 192,
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
              id = 33,
              name = "Maksim",
              type = "gopper",
              shape = "point",
              x = 1120,
              y = 208,
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
              id = 34,
              name = "Vasily",
              type = "niko",
              shape = "point",
              x = 864,
              y = 192,
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
              name = "Reta",
              type = "zeena",
              shape = "point",
              x = 1152,
              y = 192,
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
              id = 36,
              name = "Vadim",
              type = "niko",
              shape = "point",
              x = 1184,
              y = 208,
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
        },
        {
          type = "objectgroup",
          draworder = "topdown",
          id = 33,
          name = "1",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          parallaxx = 1,
          parallaxy = 1,
          properties = {
            ["maxActiveEnemies"] = 3,
            ["music"] = "stage1",
            ["onStart"] = "enterMap"
          },
          objects = {
            {
              id = 37,
              name = "1",
              type = "wave",
              shape = "rectangle",
              x = 352,
              y = 0,
              width = 448,
              height = 240,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 38,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 456,
              y = 200,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "squat",
                ["delayedWakeRange"] = 0,
                ["flip"] = true,
                ["palette"] = "blue",
                ["wakeRange"] = 0
              }
            },
            {
              id = 39,
              name = "Sergey",
              type = "gopper",
              shape = "point",
              x = 416,
              y = 176,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "squat",
                ["delayedWakeRange"] = 0,
                ["flip"] = true,
                ["palette"] = "black",
                ["wakeRange"] = 0
              }
            },
            {
              id = 40,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 376,
              y = 200,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "squat",
                ["delayedWakeRange"] = 0,
                ["palette"] = "blue",
                ["wakeRange"] = 0
              }
            },
            {
              id = 41,
              name = "Dima",
              type = "gopper",
              shape = "point",
              x = 576,
              y = 176,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["appearFrom"] = "right",
                ["palette"] = "black",
                ["spawnDelay"] = 3
              }
            },
            {
              id = 42,
              name = "Pavel",
              type = "gopper",
              shape = "point",
              x = 128,
              y = 192,
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
              id = 43,
              name = "Pyotr",
              type = "niko",
              shape = "point",
              x = 640,
              y = 208,
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
              id = 44,
              name = "Boris",
              type = "gopper",
              shape = "point",
              x = 88,
              y = 216,
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
              id = 45,
              name = "Hooch",
              type = "hooch",
              shape = "point",
              x = 736,
              y = 200,
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
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 25,
      name = "bottomLine",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 1,
          name = "",
          type = "",
          shape = "polyline",
          x = -128,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polyline = {
            { x = 0, y = 0 },
            { x = 2944, y = 0 }
          },
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 27,
      name = "players",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 5,
          name = "1",
          type = "",
          shape = "point",
          x = 48,
          y = 176,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "2",
          type = "",
          shape = "point",
          x = 32,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "3",
          type = "",
          shape = "point",
          x = 16,
          y = 224,
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
      draworder = "topdown",
      id = 28,
      name = "global",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 8,
          name = "enterMap",
          type = "event",
          shape = "point",
          x = 16,
          y = 112,
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
          x = 2800,
          y = 112,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["animation"] = "stand",
            ["duration"] = "2",
            ["gox"] = "0",
            ["nextevent"] = "exit"
          }
        },
        {
          id = 10,
          name = "exit",
          type = "event",
          shape = "point",
          x = 2736,
          y = 192,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["go"] = "exit",
            ["nextevent"] = "nextmap",
            ["nextmap"] = "stage1-2_map"
          }
        },
        {
          id = 11,
          name = "Trash",
          type = "trashcan",
          shape = "point",
          x = 528,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["drop"] = "chicken",
            ["minPlayerCount"] = 2
          }
        },
        {
          id = 12,
          name = "Trash",
          type = "trashcan",
          shape = "point",
          x = 552,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["drop"] = "apple",
            ["palette"] = 2
          }
        },
        {
          id = 46,
          name = "Sign",
          type = "sign",
          shape = "point",
          x = 336,
          y = 160,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["drop"] = "apple",
            ["palette"] = 2
          }
        }
      }
    }
  }
}
