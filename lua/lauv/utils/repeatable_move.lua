---@class UtilRepeat
local M = {}

---@class UtilRepeat.MoveOpts
---@field forward boolean If true, move forward, and false is for backward.
---@field start? boolean If true, choose the start of the node, and false is for the end.

---@alias UtilRepeat.MoveFunction fun(opts: UtilRepeat.MoveOpts, ...: any)
---@alias UtilRepeat.BuiltinCharMove 'f'|'F'|'t'|'T'

---@class UtilRepeat.RepeatableMove
---@field func UtilRepeat.MoveFunction|UtilRepeat.BuiltinCharMove
---@field opts UtilRepeat.MoveOpts
---@field additional_args any[]

---@type UtilRepeat.RepeatableMove?
M.last_move = nil

--- Wrapper for tree-sitter repeatable move,
--- avoid error when the module is not loaded
---@param forward_move_fn function
---@param backward_move_fn function
function M.make_repeatable_move_pair(forward_move_fn, backward_move_fn)
  local function move_fn(opts)
    if opts.forward then
      return forward_move_fn()
    else
      return backward_move_fn()
    end
  end

  return function()
    move_fn = M.make_repeatable_move(move_fn)
    return move_fn { forward = true }
  end, function()
    move_fn = M.make_repeatable_move(move_fn)
    return move_fn { forward = false }
  end
end

---Make a move function repeatable.
---@param move_fn UtilRepeat.MoveFunction
---@return UtilRepeat.MoveFunction
function M.make_repeatable_move(move_fn)
  return function(opts, ...)
    M.last_move = { func = move_fn, opts = vim.deepcopy(opts), additional_args = { ... } }
    move_fn(opts, ...)
  end
end

---Repeat the last move, optionally overriding its options.
---@param opts_extend UtilRepeat.MoveOpts?
function M.repeat_last_move(opts_extend)
  if not M.last_move then
    return
  end

  local opts = vim.tbl_deep_extend('force', M.last_move.opts, opts_extend or {})
  if type(M.last_move.func) == 'function' then
    M.last_move.func(opts, unpack(M.last_move.additional_args))
  else
    -- Let Neovim repeat the character search, which retains its target character.
    vim.cmd.normal { args = { opts.forward and ';' or ',' }, bang = true }
  end
end

function M.repeat_last_move_opposite()
  if M.last_move then
    M.repeat_last_move({ forward = not M.last_move.opts.forward })
  end
end

function M.repeat_last_move_next()
  M.repeat_last_move({ forward = true })
end

function M.repeat_last_move_previous()
  M.repeat_last_move({ forward = false })
end

-- NOTE: map builtin_f_expr, builtin_F_expr, builtin_t_expr, builtin_T_expr with { expr = true }.
--
-- We are not using M.make_repeatable_move or M.set_last_move and instead registering at M.last_move manually
-- because move_fn is not a function (but string f, F, t, T).
-- We don't want to execute a move function, but instead return an expression (f, F, t, T).
M.builtin_f_expr = function()
  M.last_move = {
    func = 'f',
    opts = { forward = true },
    additional_args = {},
  }
  return 'f'
end

M.builtin_F_expr = function()
  M.last_move = {
    func = 'F',
    opts = { forward = false },
    additional_args = {},
  }
  return 'F'
end

M.builtin_t_expr = function()
  M.last_move = {
    func = 't',
    opts = { forward = true },
    additional_args = {},
  }
  return 't'
end

M.builtin_T_expr = function()
  M.last_move = {
    func = 'T',
    opts = { forward = false },
    additional_args = {},
  }
  return 'T'
end

return M
