return {
  version = "1.4",
  luaversion = "5.1",
  tiledversion = "1.4.3",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 80,
  height = 10,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 38,
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
      properties = {},
      layers = {
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/sky.png",
          id = 2,
          name = "sky",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          properties = {
            ["relativeX"] = "0.45"
          }
        },
        {
          type = "group",
          id = 3,
          name = "bg-city-3",
          visible = true,
          opacity = 1,
          offsetx = 113,
          offsety = 0,
          properties = {
            ["relativeX"] = "0.30"
          },
          layers = {
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/background-city-3.png",
              id = 4,
              name = "city",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              properties = {}
            }
          }
        },
        {
          type = "group",
          id = 5,
          name = "bg-city-2",
          visible = true,
          opacity = 1,
          offsetx = 80,
          offsety = 0,
          properties = {
            ["relativeX"] = "0.25"
          },
          layers = {
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/background-city-2.png",
              id = 6,
              name = "city",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              properties = {}
            }
          }
        },
        {
          type = "group",
          id = 7,
          name = "bg-city-1",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          properties = {
            ["relativeX"] = "0.20"
          },
          layers = {
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/background-city-1.png",
              id = 8,
              name = "city",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              properties = {}
            }
          }
        },
        {
          type = "group",
          id = 9,
          name = "bg-building",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          properties = {
            ["relativeX"] = "0.05"
          },
          layers = {
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/background-building-2.png",
              id = 10,
              name = "building-2",
              visible = true,
              opacity = 1,
              offsetx = -26,
              offsety = 0,
              properties = {}
            },
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/background-building-1.png",
              id = 11,
              name = "building-1",
              visible = true,
              opacity = 1,
              offsetx = -9,
              offsety = 0,
              properties = {}
            }
          }
        },
        {
          type = "group",
          id = 12,
          name = "puddle-overlay",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          properties = {},
          layers = {
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/stage1-1_puddle_overlay_2.png",
              id = 13,
              name = "puddle-overlay-2",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              properties = {}
            },
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/stage1-1_puddle_overlay_1.png",
              id = 14,
              name = "puddle-overlay-1",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              properties = {}
            }
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1_rf.png",
          id = 15,
          name = "bg-reflection",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 96,
          properties = {
            ["reflect"] = true
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1.png",
          id = 16,
          name = "bg",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
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
              offsetx = 1812,
              offsety = 191,
              properties = {}
            },
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/burn-barrel-placeholder.png",
              id = 19,
              name = "barrel2",
              visible = true,
              opacity = 1,
              offsetx = 757,
              offsety = 189,
              properties = {}
            },
            {
              type = "imagelayer",
              image = "../../../res/img/stage/stage1/burn-barrel-placeholder.png",
              id = 20,
              name = "barrel1",
              visible = true,
              opacity = 1,
              offsetx = 274,
              offsety = 194,
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
      properties = {},
      layers = {
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1_fg_bridge_shadow.png",
          id = 22,
          name = "bridge-shadow",
          visible = false,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          properties = {}
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1_fg_bridge.png",
          id = 23,
          name = "bridge",
          visible = true,
          opacity = 1,
          offsetx = 260,
          offsety = 0,
          properties = {
            ["relativeX"] = "-0.2"
          }
        },
        {
          type = "imagelayer",
          image = "../../../res/img/stage/stage1/stage1-1_fg.png",
          id = 24,
          name = "fg",
          visible = true,
          opacity = 1,
          offsetx = 200,
          offsety = 0,
          properties = {
            ["relativeX"] = "-0.8"
          }
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 25,
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
            { x = 2560, y = 0 }
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
      properties = {},
      objects = {
        {
          id = 5,
          name = "1",
          type = "",
          shape = "point",
          x = 48,
          y = 256,
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
          y = 280,
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
          y = 304,
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
      id = 28,
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
          x = 2480,
          y = 184,
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
          x = 2584,
          y = 280,
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
          x = 368,
          y = 248,
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
          x = 392,
          y = 248,
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
          x = 176,
          y = 240,
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
    },
    {
      type = "group",
      id = 29,
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
          id = 30,
          name = "4",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
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
              x = 1920,
              y = 0,
              width = 640,
              height = 320,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 14,
              name = "Beatnik",
              type = "beatnik",
              shape = "point",
              x = 2440,
              y = 272,
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
              x = 2424,
              y = 248,
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
              x = 2456,
              y = 304,
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
          properties = {
            ["maxActiveEnemies"] = 4
          },
          objects = {
            {
              id = 17,
              name = "3",
              type = "wave",
              shape = "rectangle",
              x = 1280,
              y = 0,
              width = 640,
              height = 320,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 18,
              name = "Booze",
              type = "hooch",
              shape = "point",
              x = 1528,
              y = 272,
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
              x = 1568,
              y = 248,
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
              x = 1592,
              y = 296,
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
              x = 1664,
              y = 272,
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
              x = 1312,
              y = 272,
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
              x = 1520,
              y = 272,
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
              x = 1760,
              y = 288,
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
              x = 1808,
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
          properties = {
            ["maxActiveEnemies"] = 4
          },
          objects = {
            {
              id = 26,
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
              id = 27,
              name = "Zeena",
              type = "zeena",
              shape = "point",
              x = 728,
              y = 272,
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
              x = 784,
              y = 288,
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
              x = 656,
              y = 272,
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
              x = 896,
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
              id = 31,
              name = "Nitsa",
              type = "zeena",
              shape = "point",
              x = 680,
              y = 256,
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
              x = 928,
              y = 272,
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
              x = 960,
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
              id = 34,
              name = "Vasily",
              type = "niko",
              shape = "point",
              x = 704,
              y = 272,
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
              x = 992,
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
              id = 36,
              name = "Vadim",
              type = "niko",
              shape = "point",
              x = 1024,
              y = 288,
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
              x = 0,
              y = 0,
              width = 640,
              height = 320,
              rotation = 0,
              visible = true,
              properties = {}
            },
            {
              id = 38,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 288,
              y = 280,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "squat",
                ["flip"] = true,
                ["palette"] = "blue"
              }
            },
            {
              id = 39,
              name = "Sergey",
              type = "gopper",
              shape = "point",
              x = 248,
              y = 256,
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
              id = 40,
              name = "Gopper",
              type = "gopper",
              shape = "point",
              x = 208,
              y = 280,
              width = 0,
              height = 0,
              rotation = 0,
              visible = true,
              properties = {
                ["animation"] = "squat",
                ["palette"] = "blue"
              }
            },
            {
              id = 41,
              name = "Dima",
              type = "gopper",
              shape = "point",
              x = 416,
              y = 256,
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
              x = -32,
              y = 272,
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
              x = 480,
              y = 288,
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
              x = -72,
              y = 296,
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
              x = 576,
              y = 280,
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
      type = "group",
      id = 34,
      name = "collision",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
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
          properties = {},
          objects = {
            {
              id = 2,
              name = "",
              type = "",
              shape = "rectangle",
              x = -128,
              y = 0,
              width = 2816,
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
              x = 2688,
              y = 0,
              width = 64,
              height = 320,
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
