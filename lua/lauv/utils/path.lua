---@class Utils.Path
---@field filename string
local Path = {}
Path.__index = Path

-- Cache for performance and 0.11 compatibility
local uv = vim.uv

----------------------------------------------------------------------
-- Core Methods
----------------------------------------------------------------------

--- Check if the given object is a Path instance
---@param p any
---@return boolean
function Path.is_path(p)
  return getmetatable(p) == Path
end

--- Create a new Path object
--- Supports multiple arguments, nested tables, and existing Path objects
---@param ... string|string[]|Utils.Path
---@return Utils.Path
function Path:new(...)
  local args = { ... }

  -- Compatibility: handle cases where self is passed as a string (legacy plenary style)
  if type(self) == "string" then
    table.insert(args, 1, self)
    self = Path
  end

  -- Fast track: return if already a Path and no other args
  if #args == 1 and Path.is_path(args[1]) then
    --- @diagnostic disable-next-line: return-type-mismatch
    return args[1]
  end

  -- Modern processing: Flatten and extract filenames using vim.iter
  local path_string = vim
    .iter(args)
    :flatten(math.huge)
    :map(function(item)
      if Path.is_path(item) then
        return item.filename
      end
      if type(item) == "string" then
        return item
      end
    end)
    :filter(function(item)
      return item ~= nil and item ~= ""
    end)
    :fold(nil, function(acc, item)
      if not acc then
        return item
      end
      return vim.fs.joinpath(acc, item)
    end) or ""

  return setmetatable({
    -- vim.fs.normalize resolves ".." and "." and removes redundant separators
    filename = vim.fs.normalize(path_string),
  }, Path)
end

-- ----------------------------------------------------------------------
-- -- Basic Utilities
-- ----------------------------------------------------------------------
--
-- ---@return string
-- function Path:__tostring()
--   return self.filename
-- end
--
-- --- Check equality between two paths
-- ---@param other any
-- ---@return boolean
-- function Path:__eq(other)
--   return Path.is_path(other) and self.filename == other.filename
-- end
--
-- --- Join path segments to the current path
-- ---@param ... string
-- ---@return Utils.Path
-- function Path:joinpath(...)
--   return Path:new(self.filename, ...)
-- end
--
-- --- Syntax sugar: path / "subdir"
-- ---@param child string
-- ---@return Utils.Path
-- function Path:__div(child)
--   return self:joinpath(child)
-- end
--
-- --- Get the parent directory
-- ---@return Utils.Path
-- function Path:parent()
--   return Path:new(vim.fs.dirname(self.filename))
-- end
--
-- --- Get the last component of the path
-- ---@return string
-- function Path:basename()
--   return vim.fs.basename(self.filename)
-- end
--
-- ----------------------------------------------------------------------
-- -- FS Operations
-- ----------------------------------------------------------------------

--- Get fs_stat for the current path
---@return uv.aliases.fs_stat_table|nil stat, string? err_name, string? err_msg
function Path:_stat()
  return uv.fs_stat(self.filename)
end

--- Check if path exists on disk
---@return boolean
function Path:exists()
  return self:_stat() ~= nil
end

-- --- Check if path is a directory
-- ---@return boolean
-- function Path:is_dir()
--   local s = self:_stat()
--   return s ~= nil and s.type == "directory"
-- end
--
-- --- Check if path is a regular file
-- ---@return boolean
-- function Path:is_file()
--   local s = self:_stat()
--   return s ~= nil and s.type == "file"
-- end
--
-- --- Create directory if it doesn't exist
-- ---@param opts? { mode?: integer, parents?: boolean }
-- ---@return Utils.Path
-- function Path:mkdir(opts)
--   opts = opts or {}
--   local mode = opts.mode or tostring(493) -- 0755
--   local flags = (opts.parents ~= false) and "p" or ""
--   vim.fn.mkdir(self.filename, flags, mode)
--   return self
-- end
--
-- ----------------------------------------------------------------------
-- -- Iteration & Search
-- ----------------------------------------------------------------------
--
-- --- Iterate over immediate children of the directory
-- ---@return Iter
-- function Path:iter()
--   if not self:is_dir() then
--     return vim.iter({})
--   end
--
--   -- vim.fs.dir returns an iterator of (name, type)
--   return vim.iter(vim.fs.dir(self.filename)):map(function(name, type)
--     return self:joinpath(name), type
--   end)
-- end
--
-- --- Recursively find files/directories (Neovim 0.10+ native)
-- ---@param opts? { type?: "file"|"directory", limit?: integer }
-- ---@return Iter
-- function Path:find(opts)
--   opts = opts or {}
--   local finder = vim.fs.find(function()
--     return true
--   end, {
--     path = self.filename,
--     limit = opts.limit or math.huge,
--     type = opts.type,
--   })
--
--   return vim.iter(finder):map(function(p)
--     return Path:new(p)
--   end)
-- end

return Path
