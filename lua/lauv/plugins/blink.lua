return {
  "saghen/blink.cmp",
  -- optional: provides snippets for the snippet source
  -- cond = false,
  dependencies = "rafamadriz/friendly-snippets",
  event = { "InsertEnter", "CmdlineEnter" },
  -- use a release tag to download pre-built binaries
  version = "*",
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "super-tab"
    },
    appearance = {
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },
    completion = {
      menu = {
        border = "rounded",
        -- draw = {
        -- columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
        -- },
      },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      min_keyword_length = function(ctx)
        -- only applies when typing a command, doesn't apply to arguments
        if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
          return 2
        end
        return 0
      end,
    },
  },
  opts_extend = { "sources.default" },
}
