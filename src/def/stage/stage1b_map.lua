return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.2.1",
  orientation = "orthogonal",
  renderorder = "left-up",
  width = 40,
  height = 10,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 10,
  nextobjectid = 15,
  backgroundcolor = { 0, 85, 0 },
  properties = {
    ["nextmap"] = "ending"
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
          id = 9,
          name = "bg",
          visible = true,
          opacity = 1,
          offsetx = 0,
          offsety = 0,
          image = "../../../res/img/stage/stage1/stage1b.png",
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
          x = 0,
          y = 0,
          width = 1280,
          height = 224,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 14,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 320,
          width = 90,
          height = 122,
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
          x = 59.3333,
          y = 362.667,
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
          x = 43.3333,
          y = 386.667,
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
          x = 27.3333,
          y = 410.667,
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
          name = "enterTheMap",
          type = "event",
          shape = "rectangle",
          x = 100,
          y = 368,
          width = 38,
          height = 29.3333,
          rotation = 0,
          visible = true,
          properties = {
            ["goy"] = "-100"
          }
        }
      }
    },
    {
      type = "group",
      id = 1,
      name = "batch",
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
          properties = {},
          objects = {
            {
              id = 2,
              name = "2",
              type = "batch",
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
            ["onStart"] = "enterTheMap"
          },
          objects = {
            {
              id = 1,
              name = "1",
              type = "batch",
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
