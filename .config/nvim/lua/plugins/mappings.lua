-- TODO ??? -@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {

    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- mappings for for my azerty life
        ["²"] = { "`", remap = true, silent = true },
        ["ç"] = { "[", remap = true, silent = true },
        ["à"] = { "]", remap = true, silent = true },
        ["µ"] = { "#", remap = true, silent = true },
        -- [<Leader>
        -- ["ç"] = "p",

        -- TODO assess
        -- map ù <C-^>
        -- nmap <A-p> :pu<CR>
        -- :tnoremap <A-h> <C-\><C-N><C-w>h
        -- :tnoremap <A-j> <C-\><C-N><C-w>j
        -- :tnoremap <A-k> <C-\><C-N><C-w>k
        -- :tnoremap <A-l> <C-\><C-N><C-w>l
        -- :inoremap <A-h> <C-\><C-N><C-w>h
        -- :inoremap <A-j> <C-\><C-N><C-w>j
        -- :inoremap <A-k> <C-\><C-N><C-w>k
        -- :inoremap <A-l> <C-\><C-N><C-w>l
        -- :nnoremap <A-h> <C-w>h
        -- :nnoremap <A-j> <C-w>j
        -- :nnoremap <A-k> <C-w>k
        -- :nnoremap <A-l> <C-w>l
        -- nnoremap <leader>j :bp<CR>
        -- nnoremap <leader>k :bn<CR>
        --
        -- ""Search buffers with FZF
        -- nmap <leader>, :Buffers<CR>
        -- ""Search Files with FZF
        -- nmap <leader>f :Files<CR>
        -- "" Grep files with ripgrep and fzf
        -- nmap <leader>g :Rg<CR>
        --
        -- nnoremap <Leader>x :Rg <C-R><C-W><CR>

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },
        ["<Leader>x"] = { function() require("telescope.builtin").grep_string() end, desc = "Find word under cursor" },
        ["<Leader>,"] = { function() require("telescope.builtin").buffers() end, desc = "Find buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      o = {

        ["²"] = { "`", remap = true, silent = true },
        ["ç"] = { "[", remap = true, silent = true },
        ["à"] = { "]", remap = true, silent = true },
        ["µ"] = { "#", remap = true, silent = true },
      },
      x = {
        ["²"] = { "`", remap = true, silent = true },
        ["ç"] = { "[", remap = true, silent = true },
        ["à"] = { "]", remap = true, silent = true },
        ["µ"] = { "#", remap = true, silent = true },
      },
    },
  },
}
