-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.recipes.heirline-clock-statusline" },
  { import = "astrocommunity.motion.leap-nvim" },
  { import = "astrocommunity.scrolling.neoscroll-nvim" },
  -- { import = "astrocommunity.workflow.hardtime-nvim" },
  -- import/override with your plugins folder
}
