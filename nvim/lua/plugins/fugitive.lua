return {
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git);
    vim.keymap.set("n", "<leader>gca", ":Git add .| :Git commit -m");
  end
}
