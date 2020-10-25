local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, drawable, transform, z)
  self.engine = assert(engine)
  self.drawable = assert(drawable)
  self.transform = assert(transform)
  self.z = z or 0

  insert(self.engine.sprites, self)
end

function M:destroy()
  removeLast(self.engine.sprites, self)

  self.transform = nil
  self.drawable = nil
  self.engine = nil
end

return M
