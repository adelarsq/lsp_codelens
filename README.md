# lsp_tools

Provide some tools for a better Neovim experience with LSP.

# Features

- [x] codelens
- [x] document highlight

## Installing

Install with you favorite plugin manager then on the on_attach method call:

```lua
require('lsp_tools').on_attach(client, bufnr)
```
