-- Disable lsp log
vim.lsp.log.set_level("off")

local function keymap_on_attach(bufnr)
  --
  -- Mappings
  --
  -- Nvim creates the following default LSP mappings:
  --  * K in NORMAL maps to vim.lsp.buf.hover()
  --  * grr in NORMAL maps to vim.lsp.buf.references()
  --  * gri in NORMAL maps to vim.lsp.buf.implementation()
  --  * grt in NORMAL maps to vim.lsp.buf.type_definition()
  --  * gO in NORMAL maps to vim.lsp.buf.document_symbol()
  --  * grn in NORMAL maps to vim.lsp.buf.rename()
  --  * gra in NORMAL and VISUAL maps to vim.lsp.buf.code_action()
  --  * <C-s> in INSERT and SELECT maps to vim.lsp.buf.signature_help()
  --  * an and in in VISUAL maps to outer and inner incremental selections, respectively, using
  --  vim.lsp.buf.selection_range()
  -- Also, the following default diagnostic mappings are creataed:
  --  * ]d and [d: jump to the next or previous diagnostic
  --  * ]D and [D: jump to the last or first diagnostic
  --  * <C-w>d and <C-w><C-d> map to vim.diagnostic.open_float()

  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, nowait = true })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
  -- Code actions for the current line.
  -- In order to get the code actions only for the cursor position, the diagnostics overlap the
  -- cursor position could be passed as part of the parameter to vim.lsp.buf.code_action(). However,
  -- currently the code action function doesn't offer a way to extract per client diagnostics, i.e.,
  -- all the diagnostics at the cursor position will be sent to each server.
  --
  -- TODO: modify this keymap to only get the code actions for the current cursor position after the
  -- API is fixed.
  vim.keymap.set({ "n", "x" }, "<Leader>ca", vim.lsp.buf.code_action, opts)

  -- Diagnostics
  vim.keymap.set("n", "go", vim.diagnostic.open_float, opts)
  -- vim.keymap.set("n", "[d", function() -- previous
  --   vim.diagnostic.jump({ count = -vim.v.count1 })
  -- end, opts)
  -- vim.keymap.set("n", "]d", function() -- next
  --   vim.diagnostic.jump({ count = vim.v.count1 })
  -- end, opts)
  -- vim.keymap.set("n", "[D", function() -- first
  --   vim.diagnostic.jump({ -9999, wrap = false })
  -- end)
  -- vim.keymap.set("n", "]D", function() -- last
  --   vim.diagnostic.jump({ 9999, wrap = false })
  -- end)
  vim.keymap.set("n", "[e", function() -- previous error
    vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR })
  end, opts)
  vim.keymap.set("n", "]e", function() -- next error
    vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR })
  end, opts)
end

local function capabilities_on_attach(client, bufnr)
  if client:supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true)
    -- Toggle inlay_hint
    vim.keymap.set("n", "\\ih", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { buffer = bufnr })
  end

  if client:supports_method("textDocument/codeLens") then
    vim.lsp.codelens.enable()
    -- Toggle codelens
    vim.keymap.set("n", "\\cl", function()
      vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled())
    end, { buffer = bufnr })
  end

  if vim.fn.has('nvim-0.12') == 1 and client:supports_method('textDocument/documentColor') then
    vim.lsp.document_color.enable(true, { bufnr = bufnr }, { style = 'virtual' })
  end

  -- Document highlight
  if client:supports_method("textDocument/documentHighlight") then
    local document_highlight_group = vim.api.nvim_create_augroup("lauv.lsp.document_highlight", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
      group = document_highlight_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
      group = document_highlight_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.clear_references()
      end,
    })
  end
end

-- Set keymap for LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      keymap_on_attach(bufnr)
      capabilities_on_attach(client, bufnr)
    end
  end,
})

-- Enable LSP servers
local lsp_configs = {}
for _, v in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  local name = vim.fn.fnamemodify(v, ":t:r")
  lsp_configs[name] = true
end

vim.lsp.enable(vim.tbl_keys(lsp_configs))
