-- lua/util/wpgutenberg.lua
--
-- Leichtgewichtiges Highlighting + Autocomplete für WordPress-Block-Kommentare
-- wie <!-- wp:group {"className":"..."} --> in .php / .html Theme-Dateien.
--
-- Warum kein sauberes Treesitter-Injection? Ein HTML-Kommentar ist im
-- Treesitter-Grammar ein einzelnes Blatt ohne Kindknoten, und der JSON-Teil
-- hat variable Länge (Blockname davor ist mal "wp:group", mal
-- "wp:post-title"). Ohne festen Offset lässt sich der JSON-Bereich nicht
-- sauber an einen Sub-Parser übergeben. Deswegen hier ein extmark-basierter
-- Ansatz: robust, funktioniert unabhängig davon ob Treesitter-Highlighting
-- gerade aktiv ist, und braucht keinen eigenen Parser.
--
-- Einbindung: wird über einen InsertEnter-Autocmd in lua/adam/autocmds.lua
-- geladen (require("util.wpgutenberg").setup()), NICHT über lua/plugins/,
-- da lazy.nvim dort Plugin-Specs erwartet, kein beliebiges Modul. Der Umweg
-- über InsertEnter + vim.schedule stellt sicher, dass nvim-cmp/LuaSnip
-- (lazy-geladen über event = "InsertEnter") schon initialisiert sind, wenn
-- hier require("cmp") aufgerufen wird.

local M = {}

local ns = vim.api.nvim_create_namespace("wp_gutenberg_hl")

local BLOCK_NAMES = {
  "wp:group", "wp:column", "wp:columns", "wp:heading", "wp:paragraph",
  "wp:post-title", "wp:post-content", "wp:post-terms", "wp:post-date",
  "wp:post-excerpt", "wp:post-featured-image", "wp:post-author",
  "wp:template-part", "wp:query", "wp:query-pagination", "wp:query-title",
  "wp:post-template", "wp:navigation", "wp:site-title", "wp:site-logo",
  "wp:site-tagline", "wp:image", "wp:buttons", "wp:button", "wp:list",
  "wp:list-item", "wp:separator", "wp:spacer", "wp:cover", "wp:media-text",
  "wp:social-links", "wp:social-link", "wp:html", "wp:shortcode",
  "wp:more", "wp:pattern", "wp:loginout", "wp:archives", "wp:categories",
  "wp:tag-cloud", "wp:search", "wp:comments", "wp:comment-template",
}

-- ---------------------------------------------------------------------
-- 1) Highlighting per extmark
-- ---------------------------------------------------------------------

local function highlight_buffer(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for i, line in ipairs(lines) do
    if line:find("<!%-%- /?wp:") then
      -- Blockname (wp:group, wp:post-title, ...)
      local name_s, name_e = line:find("wp:[%w%-/]+")
      if name_s then
        vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, name_s - 1, {
          end_col = name_e,
          hl_group = "Function",
        })
      end

      -- JSON-Attribut-Keys: "key":
      for key_s, key_e in line:gmatch('()"[%w_]+"%s*:()') do
        vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, key_s - 1, {
          end_col = key_e - 2,
          hl_group = "Identifier",
        })
      end

      -- String-Werte: "wert"
      for val_s, val_e in line:gmatch(':%s*()"[^"]*"()') do
        vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, val_s - 1, {
          end_col = val_e - 1,
          hl_group = "String",
        })
      end

      -- Zahlen/Bool/null-Werte
      for val_s, val_e in line:gmatch(':%s*()[%d%.]+()') do
        vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, val_s - 1, {
          end_col = val_e - 1,
          hl_group = "Number",
        })
      end
      for val_s, val_e in line:gmatch("()true()") do
        vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, val_s - 1, { end_col = val_e - 1, hl_group = "Boolean" })
      end
      for val_s, val_e in line:gmatch("()false()") do
        vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, val_s - 1, { end_col = val_e - 1, hl_group = "Boolean" })
      end
    end
  end
end

-- ---------------------------------------------------------------------
-- 2) Autocomplete: eigene cmp-Source für Blocknamen
-- ---------------------------------------------------------------------

local function setup_cmp_source()
  local ok_cmp, cmp = pcall(require, "cmp")
  if not ok_cmp then
    return
  end

  local source = {}

  function source.new()
    return setmetatable({}, { __index = source })
  end

  function source:is_available()
    local line = vim.api.nvim_get_current_line()
    return line:match("<!%-%-%s*wp:?[%w%-]*$") ~= nil
  end

  function source:get_trigger_characters()
    return { ":", "-" }
  end

  function source:complete(_, callback)
    local items = {}
    for _, name in ipairs(BLOCK_NAMES) do
      table.insert(items, {
        label = name,
        insertText = name .. ' {} /-->',
        kind = cmp.lsp.CompletionItemKind.Snippet,
      })
    end
    callback(items)
  end

  cmp.register_source("wp_blocks", source.new())

  -- Nur für php/html aktivieren, ohne deine restliche cmp-Source-Liste zu
  -- verändern -- filetype-Sources werden zusätzlich zu den globalen genutzt.
  cmp.setup.filetype({ "php", "html" }, {
    sources = cmp.config.sources({
      { name = "wp_blocks" },
    }, cmp.get_config().sources or {}),
  })
end

-- ---------------------------------------------------------------------
-- 3) Optional: LuaSnip-Snippets für ganze Block-Skelette
-- ---------------------------------------------------------------------

local function setup_snippets()
  local ok_ls, ls = pcall(require, "luasnip")
  if not ok_ls then
    return
  end
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node

  local function block_snippet(trigger, name, attrs_placeholder)
    return s(trigger, {
      t("<!-- " .. name .. " {"),
      i(1, attrs_placeholder or ""),
      t("} -->"),
      t({ "", "" }),
      i(0),
      t({ "", "<!-- /" .. name .. " -->" }),
    })
  end

  ls.add_snippets("html", {
    block_snippet("wpgroup", "wp:group", '"layout":{"type":"constrained"}'),
    block_snippet("wptitle", "wp:post-title", '"level":1'),
    block_snippet("wpterms", "wp:post-terms", '"term":"category"'),
    block_snippet("wptemplatepart", "wp:template-part", '"slug":"header","tagName":"header"'),
  })
  ls.add_snippets("php", ls.get_snippets("html") or {})
end

-- ---------------------------------------------------------------------

function M.setup()
  local group = vim.api.nvim_create_augroup("WpGutenbergHighlight", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = group,
    pattern = { "*.php", "*.html" },
    callback = function(args)
      highlight_buffer(args.buf)
    end,
  })

  setup_cmp_source()
  setup_snippets()
end

return M
