local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, drawable, localToWorld, z)
  self.engine = assert(engine)
  self.drawable = assert(drawable)
  self.localToWorld = assert(localToWorld)
  self.z = z or 0

  insert(self.engine.sprites, self)
end

function M:destroy()
  removeLast(self.engine.sprites, self)

  self.localToWorld = nil
  self.drawable = nil
  self.engine = nil
end

return M
