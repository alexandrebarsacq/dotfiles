return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

    -- opts.statusline[1] = status.component.file_info {
    --   -- enable the file_icon and disable the highlighting based on filetype
    --   filename = {
    --     fname = function(nr) return vim.fn.getcwd(nr) end,
    --     padding = { left = 1 },
    --   },
    --   { fallback = "Empty" },
    --   -- disable some of the info
    --   filetype = false,
    --   file_read_only = false,
    --   -- add padding
    --   padding = { right = 1 },
    --   -- define the section separator
    --   surround = { separator = "left", condition = false },
    -- }
    -- opts.statusline[1] = status.provider.filename { modify = ":.:h" }
    opts.statusline[1] = status.component.separated_path {
      path_func = status.provider.filename {},
    }
  end,
}
