-- CmdAtom (:h CmdAtom) powered repeat.

---@class lauv.repeat.Action
---@field keys string Keysequence replayed by ";".
---@field opposite string Keysequence replayed by ",".
---@field remap boolean Replay `keys` as new input, resolving mappings ('m').

-- "[X" / "]X" commands whose opposite is not the plain prefix flip.
-- See ":h [[", ":h ][", ":h [{", ":h [(".
local opposite_pair = {
  ['[['] = ']]',
  [']]'] = '[[',
  ['[]'] = '][',
  [']['] = '[]',
  ['[{'] = ']}',
  [']}'] = '[{',
  ['[('] = '])',
  ['])'] = '[(',
  gt = 'gT',
  gT = 'gt',
}

-- Plain direction flip: "]c" -> "[c", "]q" -> "[q", "f," -> "F,".
local opposite_prefix = {
  ['['] = ']',
  [']'] = '[',
  f = 'F',
  F = 'f',
  t = 'T',
  T = 't',
}

--- CmdAtom carries the count of the action in `lhs`/`keys` ("3]c"). Drop it:
--- ";" and "," repeat with the count the user gives *them* (":h ;").
---@param keys string
---@param count integer?
---@return string
local function strip_count(keys, count)
  local prefix = (count or 0) > 0 and tostring(count) or ''
  if prefix ~= '' and keys:sub(1, #prefix) == prefix then
    return keys:sub(#prefix + 1)
  end
  return keys
end

--- Character search motions. Operators carry the whole motion in `cmd`
--- ("df," => cmd = "f,"); plain motions keep the operand in `cmdarg`
--- ("f," => cmd = "f", cmdarg = ","). Vim's ";" and "," repeat the search
--- itself, so the operator and the original count are dropped.
---@param atom vim.event.cmdatom.data
---@return string? motion, string? char
local function char_search(atom)
  local motion, char = (atom.cmd or ''):match('^([fFtT])(.*)$')
  if not motion then
    return
  end

  char = char ~= '' and char or atom.cmdarg
  if not char or char == '' then
    return
  end
  return motion, char
end

---@param atom vim.event.cmdatom.data
---@return lauv.repeat.Action?
local function parse_action(atom)
  local motion, char = char_search(atom)
  if motion then
    return {
      keys = motion .. char,
      opposite = opposite_prefix[motion] .. char,
      remap = false,
    }
  end

  -- `lhs` and not `keys` is the source of truth for the direction: default
  -- mappings like "]b", "]q" or "]a" are Lua callbacks, so they have neither
  -- `keys` nor `cmd` and only the user input says what the opposite is.
  local body = strip_count(atom.lhs, atom.count)
  local pair = opposite_pair[body:sub(1, 2)]
  local opposite = pair or opposite_prefix[body:sub(1, 1)]
  if not opposite then
    return
  end

  return {
    -- `keys == ''` is unreplayable; feed it as is, like the official example.
    keys = atom.keys and strip_count(atom.keys, atom.count) or body,
    opposite = opposite .. body:sub(pair and 3 or 2),
    remap = atom.keys == nil,
  }
end

local last_action ---@type lauv.repeat.Action?
local last_edit ---@type vim.event.cmdatom.data?

local augroup = vim.api.nvim_create_augroup('lauvvim_repeat', { clear = true })

vim.api.nvim_create_autocmd('CmdAtom', {
  desc = 'Remember the last edit and the last repeatable action',
  group = augroup,
  callback = function(ev)
    local atom = ev.data

    -- Only `undoseq` and `changed` are trustworthy here: CmdAtom is deferred,
    -- so reading `undotree()` would see a buffer that is already ahead of this
    -- atom and misclassify a new edit as an undo/redo. It would also rebuild
    -- the whole undo tree on every keystroke.
    local seen = vim.b[ev.buf].maxseq or 0
    local is_redo_or_undo = atom.changed and (atom.undoseq or 0) <= seen
    vim.b[ev.buf].maxseq = math.max(seen, atom.undoseq or 0)

    -- An action can change the buffer too ("df,"), so this is not exclusive
    -- with the edit tracking below.
    local act = parse_action(atom)
    if act then
      last_action = act
    end

    if atom.changed then
      if not is_redo_or_undo and atom.lhs ~= '.' then
        last_edit = atom
      end
    end
  end,
})

vim.keymap.set({ 'n', 'x' }, ';', function()
  -- Count given to ";" itself, not the count of the remembered action.
  local count = vim.v.count > 0 and tostring(vim.v.count) or ''

  -- CmdAtom is deferred; read (and replay) only once the pending events landed,
  -- in case ";" directly follows the action it should repeat.
  vim.schedule(function()
    if not last_action then
      vim.api.nvim_feedkeys(';', 'n', false)
      return
    end
    vim.api.nvim_feedkeys(count .. last_action.keys, last_action.remap and 'm' or 'n', false)
  end)
end, { desc = 'Repeat last action' })

vim.keymap.set({ 'n', 'x' }, ',', function()
  local count = vim.v.count > 0 and tostring(vim.v.count) or ''

  vim.schedule(function()
    if not last_action then
      vim.api.nvim_feedkeys(',', 'n', false)
      return
    end
    -- The opposite is new user input: let Neovim resolve mappings again.
    vim.api.nvim_feedkeys(count .. last_action.opposite, 'm', false)
  end)
end, { desc = 'Repeat last action in the opposite direction' })

vim.keymap.set('n', '.', function()
  -- Multicursors: degrade to builtin "." (cascades).
  local mc = vim.api.nvim_create_namespace('nvim.multicursor')
  if #vim.api.nvim_buf_get_extmarks(0, mc, 0, -1, { limit = 1 }) > 0 then
    vim.api.nvim_feedkeys('.', 'n', false)
    return
  end

  vim.schedule(function()
    if not last_edit then
      vim.api.nvim_feedkeys('.', 'n', false)
      return
    end
    -- `keys == ''` is unreplayable: feed nothing, like the official example.
    vim.api.nvim_feedkeys(
      last_edit.keys or last_edit.lhs,
      last_edit.keys == nil and 'm' or 'n',
      false
    )
  end)
end, { desc = 'Repeat last edit' })
