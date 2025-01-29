---@type LazySpec
return {

  -- == Examples of Adding Plugins ==
  {
    "mfussenegger/nvim-dap-python",
    config = function() require("dap-python").setup "python3.12" end,
  },

  -- cwd = function() return util.root_pattern "pyproject.toml"(vim.fn.getcwd()) end,
}
