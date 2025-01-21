-- Files shall be savec at any occasion possible. Undo and git make not saving not reasonable.
-- Swapfiles shall thus be made useless.
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        -- first key is the augroup name
        autosave = {
          -- the value is a list of autocommands to create
          {
            -- event is added here as a string or a list-like table of events
            event = { "FocusLost", "BufLeave" },
            pattern = "*",
            desc = "Autosave on focus lost",
            callback = function() vim.cmd "silent! wall" end,
          },
          {
            event = { "FocusGained", "BufEnter" },
            pattern = "*",
            desc = "Check and reload files automatically that may have been changed outside of VIM",
            callback = function() vim.cmd "checktime" end,
          },
        },
      },

      -- vim options can be configured here
      options = {
        opt = { -- vim.opt.<key>
          -- relativenumber = true, -- sets vim.opt.relativenumber
          -- number = true, -- sets vim.opt.number
          -- spell = false, -- sets vim.opt.spell
          -- signcolumn = "yes", -- sets vim.opt.signcolumn to yes
          -- wrap = false, -- sets vim.opt.wrap
          -- scrolloff = 2, -- keep 2 lines above cursor when scrolling
          -- ignorecase = true, -- ignore case on search
          -- smartcase = true, -- but not if I use uppercase
          autowrite = true, -- autosave
          autowriteall = true, -- autosave
          swapfile = false, -- we autosave (see also autcmds)
        },
      },
    },
  },
}
