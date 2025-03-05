-- My misc options
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {

      -- vim options can be configured here
      options = {
        opt = { -- vim.opt.<key>
          scrolloff = 2, -- keep 2 lines above cursor when scrolling
          ignorecase = true, -- ignore case on search
          smartcase = true, -- but not if I use uppercase
        },
      },
    },
  },
  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " █████   █████   █████   █████  ",
        "██   ██ ██   ██ ██   ██ ██   ██ ",
        "███████ ███████ ███████ ███████ ",
        "██   ██ ██   ██ ██   ██ ██   ██ ",
        "██   ██ ██   ██ ██   ██ ██   ██ ",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      return opts
    end,
  },
}
