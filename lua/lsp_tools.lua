local M = {}

-- Create one augroup per buffer
-- Based on https://www.reddit.com/r/neovim/comments/u4g6jh/comment/i4vrkqk/?utm_source=share&utm_medium=web2x&context=3
local augroup = function(group, augroup_opts)
    return setmetatable({
        id = vim.api.nvim_create_augroup(
            group,
            vim.tbl_extend('keep', augroup_opts or {}, { clear = true })
        ),
        del = function(self)
            if self.id then
                vim.api.nvim_del_augroup_by_id(self.id)
                self.id = nil
            end
        end,
    }, {
        __call = function(self, callback)
            if self.id then
                callback(function(event, create_opts)
                    create_opts.group = self.id
                    vim.api.nvim_create_autocmd(event, create_opts)
                end, function(clear_opts)
                    clear_opts.group = self.id
                    vim.api.nvim_clear_autocmds(clear_opts)
                end)
            end
        end,
    })
end

function M.on_attach(client, bufnr)
    local LSP_TOOLS_AUGROUP = augroup('LSP_TOOLS_AUGROUP', {})
    LSP_TOOLS_AUGROUP(function(autocmd, clear)
        clear { buffer = bufnr }

        autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
            buffer = bufnr,
            callback = function()
                if client.server_capabilities.codeLensProvider then
                    vim.lsp.codelens.refresh()
                end

                if client.server_capabilities.document_highlight then
                    vim.lsp.buf.document_highlight()
                end
            end,
        })

        autocmd('LspDetach', {
            buffer = bufnr,
            callback = function(opt)
                vim.lsp.codelens.clear(opt.data.client_id, opt.buf)
            end
        })
    end)
end

return M
