# difi.nvim

A lightweight, pixel-perfect integration of [difi](https://github.com/oug-t/difi) for Neovim.
It allows you to view diffs directly in your buffer with visual-mode-like highlighting and smart indentation handling.

## Features

- **Smart Diffing:** Ignores empty lines and fixes "moved code" noise using histogram diffing.
- **Visual Mode Style:** Uses transparent backgrounds (Green/Red) that blend with your theme.
- **Auto-Integration:** Automatically opens the correct diff target when launching from the `difi` CLI.
- **Interactive:** Keep or discard changes by simply deleting the diff markers.

## Requirements

- **Neovim 0.8+**
- **Git**
- [difi](https://github.com/oug-t/difi) (Optional, but recommended for the full CLI workflow)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "oug-t/difi.nvim",
  event = "VeryLazy",
  config = function()
    -- Optional: Keymap to toggle the diff view manually
    vim.keymap.set("n", "<leader>gd", ":Difi<CR>", { desc = "Toggle Difi" })
  end
}
```
