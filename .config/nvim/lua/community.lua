-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.cpp" },
  -- { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.recipes.heirline-clock-statusline" },

  -- vim sneak ++ (use 's')
  { import = "astrocommunity.motion.leap-nvim" },

  { import = "astrocommunity.scrolling.neoscroll-nvim" },
  { import = "astrocommunity.git.gitgraph-nvim" },

  -- diffview for git stuff
  { import = "astrocommunity.git.diffview-nvim" },

  { import = "astrocommunity.syntax.vim-easy-align" }, -- Easyalign *,
  -- { import = "astrocommunity.debugging.persistent-breakpoint-nvim" },
  --
  -- -- shows the variable content inline, while debugging
  { import = "astrocommunity.debugging.nvim-dap-virtual-text" },

  { import = "astrocommunity.motion.grapple-nvim" },

  { import = "astrocommunity.diagnostics.tiny-inline-diagnostic-nvim" },

  -- { import = "astrocommunity.nvim-dap-repl-highlights" },
  -- TODO
  -- { import = "astrocommunity.nvim-chansaiw" },
  -- { import = "astrocommunity.workflow.hardtime-nvim" },
  -- import/override with your plugins folder
}
