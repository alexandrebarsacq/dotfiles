return {
  -- heirline has a line that we remove like that
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts) opts.winbar = nil end,
  },
  -- and we remove the vim tabline
  {
    "AstroNvim/astrocore",
    ---@param ops AstroCoreOpts
    opts = {
      options = {
        opt = {
          showtabline = 0,
        },
      },
    },
  },
}
