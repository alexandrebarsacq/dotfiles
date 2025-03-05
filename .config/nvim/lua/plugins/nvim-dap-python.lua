---@type LazySpec
return {
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      -- override existing confs to set cwd and env to project root so
      -- that a project where i run files in a hierarchy,
      -- the imports of other files of the project,
      -- relative to project root, are handled correctly
      local nvim_lsp = require "lspconfig"
      require("dap-python").setup "python3.12"

      local function get_project_root() return nvim_lsp.util.root_pattern ".git"(vim.fn.getcwd()) end

      local function update_config(config)
        ---@cast config table  -- Override strict type checking
        config.cwd = get_project_root
        config.env = { PYTHONPATH = get_project_root }
      end

      local dap = require "dap"
      if dap.configurations.python then
        for _, config in ipairs(dap.configurations.python) do
          update_config(config)
        end
      end

      -- custom conf, subject to change depending on my daily needs
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "My custom launch configuration",
        program = "/home/alexandre/code/dsp-outils/dspy/sensor_characterization/verify_hr_perfo_req.py",
        cwd = function() return nvim_lsp.util.root_pattern ".git"(vim.fn.getcwd()) end,
        env = {
          PYTHONPATH = function() return nvim_lsp.util.root_pattern ".git"(vim.fn.getcwd()) end,
        },
        -- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
      })
    end,
  },
}
