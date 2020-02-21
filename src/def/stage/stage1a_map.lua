return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.3.2",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 80,
  height = 10,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 39,
  nextobjectid = 20,
  backgroundcolor = { 141, 110, 143 },
  properties = {
    ["enableReflections"] = true,
    ["reflectionsOpacity"] = 0.6
  },
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
          id = 15,
          name = "sky",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          image = "../../../res/img/stage/stage1/sky.png",
          properties = {
            ["relativeX"] = "0.45"
          }
        },
        {
          type = "group",
          id = 18,
          name = "bg-city-3",
          visible = true,
          opacity = 1,
          offsetx = 113,
          offsety = -50,
          properties = {
            ["relativeX"] = "0.30"
          },
          layers = {
            {
              type = "imagelayer",
              id = 19,
              name = "city",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              image = "../../../res/img/stage/stage1/background-city-3.png",
              properties = {}
            }
          }
        },
        {
          type = "group",
          id = 17,
          name = "bg-city-2",
          visible = true,
          opacity = 1,
          offsetx = 80,
          offsety = -50,
          properties = {
            ["relativeX"] = "0.25"
          },
          layers = {
            {
              type = "imagelayer",
              id = 20,
              name = "city",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              image = "../../../res/img/stage/stage1/background-city-2.png",
              properties = {}
            }
          }
        },
        {
          type = "group",
          id = 30,
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
              id = 31,
              name = "city",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              image = "../../../res/img/stage/stage1/background-city-1.png",
              properties = {}
            }
          }
        },
        {
          type = "group",
          id = 32,
          name = "bg-building",
          visible = true,
          opacity = 1,
          offsetx = -50,
          offsety = 0,
          properties = {
            ["relativeX"] = "0.10"
          },
          layers = {
            {
              type = "imagelayer",
              id = 33,
              name = "building",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              image = "../../../res/img/stage/stage1/background-building-1.png",
              properties = {}
            }
          }
        },
        {
          type = "group",
          id = 35,
          name = "puddle-overlay",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          properties = {},
          layers = {
            {
              type = "imagelayer",
              id = 37,
              name = "puddle-overlay-2",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              image = "../../../res/img/stage/stage1/stage1a_puddle_overlay_2.png",
              properties = {}
            },
            {
              type = "imagelayer",
              id = 36,
              name = "puddle-overlay-1",
              visible = true,
              opacity = 1,
              offsetx = 0,
              offsety = 0,
              image = "../../../res/img/stage/stage1/stage1a_puddle_overlay_1.png",
              properties = {}
            }
          }
        },
        {
          type = "imagelayer",
          id = 38,
          name = "bg-reflection",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 96,
          image = "../../../res/img/stage/stage1/stage1a_rf.png",
          properties = {
            ["reflect"] = true
          }
        },
        {
          type = "imagelayer",
          id = 9,
          name = "bg",
          visible = true,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          image = "../../../res/img/stage/stage1/stage1a.png",
          properties = {}
        },
        {
          type = "group",
          id = 24,
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
              id = 26,
              name = "barrel3",
              visible = true,
              opacity = 1,
              offsetx = 1812,
              offsety = 191,
              image = "../../../res/img/stage/stage1/burn-barrel-placeholder.png",
              properties = {}
            },
            {
              type = "imagelayer",
              id = 25,
              name = "barrel2",
              visible = true,
              opacity = 1,
              offsetx = 757,
              offsety = 189,
              image = "../../../res/img/stage/stage1/burn-barrel-placeholder.png",
              properties = {}
            },
            {
              type = "imagelayer",
              id = 21,
              name = "barrel1",
              visible = true,
              opacity = 1,
              offsetx = 274,
              offsety = 194,
              image = "../../../res/img/stage/stage1/burn-barrel-placeholder.png",
              properties = {}
            }
          }
        }
      }
    },
    {
      type = "group",
      id = 12,
      name = "foreground",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      layers = {
        {
          type = "imagelayer",
          id = 34,
          name = "bridge-shadow",
          visible = false,
          opacity = 1,
          offsetx = -2,
          offsety = -2,
          image = "../../../res/img/stage/stage1/stage1a_fg_bridge_shadow.png",
          properties = {}
        },
        {
          type = "imagelayer",
          id = 27,
          name = "bridge",
          visible = true,
          opacity = 1,
          offsetx = 260,
          offsety = 0,
          image = "../../../res/img/stage/stage1/stage1a_fg_bridge.png",
          properties = {
            ["relativeX"] = "-0.2"
          }
        },
        {
          type = "imagelayer",
          id = 13,
          name = "fg",
          visible = true,
          opacity = 1,
          offsetx = 200,
          offsety = 0,
          image = "../../../res/img/stage/stage1/stage1a_fg.png",
          properties = {
            ["relativeX"] = "-1.2"
          }
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
            { x = 2560, y = 0 }
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
          x = 0,
          y = 0,
          width = 2560,
          height = 240,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      id = 5,
      name = "player",
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
          y = 256,
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
          y = 280,
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
          id = 15,
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
          id = 16,
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
          id = 17,
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
            ["nextmap"] = "stage1b_map"
          }
        },
        {
          id = 18,
          name = "Trash",
          type = "trashcan",
          shape = "point",
          x = 356,
          y = 256,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 19,
          name = "Trash",
          type = "trashcan",
          shape = "point",
          x = 455,
          y = 298,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["drop"] = "apple",
            ["palette"] = "2"
          }
        }
      }
    },
    {
      type = "group",
      id = 1,
      name = "wave",
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
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 2480,
              y = 280,
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
              id = 11,
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
              id = 12,
              name = "Niko",
              type = "niko",
              shape = "point",
              x = 1808,
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
          id = 3,
          name = "2",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          draworder = "topdown",
          properties = {},
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
