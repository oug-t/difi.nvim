<a id="readme-top"></a>
<h1 align="center">difi.nvim</h1>
<p align="center"><em>The official Neovim companion for <a href="https://github.com/oug-t/difi">difi</a>.</em></p>

<p align="center">
  <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" />
  <img src="https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white" />
  <img src="https://img.shields.io/github/license/oug-t/difi.nvim?style=for-the-badge&color=2e3440" />
</p>

<p align="center">
  <img src= "https://github.com/user-attachments/assets/2cecb580-fe35-47ae-886b-8315226d122b" alt="difi_demo" />
</p>

## Features

- 🚀 **Auto-Open:** Seamlessly jumps from the CLI to the exact line in your editor.
- 👁️ **Visual Diffs:** GitHub-style inline highlighting—no cramped split views.
- 🛠️ **Interactive:** Confirm or reject changes by simply editing the buffer text.
- 🔗 **Synced:** Automatically respects your CLI diff target (e.g., `main` or `HEAD~1`).
- 🧹 **Smart Filtering:** Uses histogram diffing to reduce noise and whitespace clutter.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "oug-t/difi.nvim",
    event = "VeryLazy",
    keys = {
        -- Context-aware: Syncs with CLI target (e.g. main) or defaults to HEAD
        { "<leader>df", ":Difi<CR>", desc = "Toggle Difi" },
    },
},
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

### 1. The CLI Workflow (Recommended)
This plugin shines when paired with the **[difi CLI tool](https://github.com/oug-t/difi)**.

1. Run `difi` (or `difi main`) in your terminal.
2. Navigate to a file and press **`e`**.
3. Neovim opens the file with the diff overlay already active, scrolled to the exact line you were viewing.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### 2. Manual Usage
You can also use it standalone inside Neovim:

- **`:Difi`** — Toggle diff against `HEAD`.
- **`:Difi main`** — Toggle diff against the `main` branch.
- **`:Difi HEAD~1`** — Compare against the previous commit.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Interactive Review Guide

`difi.nvim` turns your buffer into an editable diff. You confirm or reject changes by simply editing the text.

| Action | How to do it | Result |
| :--- | :--- | :--- |
| **Accept Addition** | Do nothing | The `+` marker is stripped, keeping the green line. |
| **Reject Addition** | Delete the line (`dd`) | The new code is removed completely. |
| **Confirm Deletion** | Do nothing | The red line (starting with `-`) disappears. |
| **Restore Deletion** | Delete the `-` marker | The text is kept and the line becomes normal code. |
| **Fix a Typo** | Edit the text directly | Your changes are saved as the new version. |

When you are done, run `:Difi` (or your toggle keymap) again. The plugin will clean up the markers and leave you with the final file state.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Configuration

The plugin works out of the box with zero configuration. However, you can check the health of the integration at any time:

```vim
:DifiHealth
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License
- MIT

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<p align="center"> Made with ❤️ by <a href="https://github.com/oug-t">oug-t</a> </p>
