local Class = require("wheelOfFire.Class")

local InterpolatedTransform = require("wheelOfFire.InterpolatedTransform")

local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = table.removeLast

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)

  self.localToScreen = InterpolatedTransform.new(self.engine)
  self.localToWorld = InterpolatedTransform.new(self.engine)

  self.viewport = {
    x = config.viewport and config.x or 0,
    y = config.viewport and config.viewport.y or 0,

    width = config.viewport and config.viewport.width or 800,
    height = config.viewport and config.viewport.height or 600,
  }

  local scale = self.viewport.height * (1 / 8)

  self.worldToScreen = love.math.newTransform(
    0.5 * self.viewport.width, 0.5 * self.viewport.height, 0, scale)

  insert(self.engine.cameras, self)
end

function M:destroy()
  removeLast(self.engine.cameras, self)
end

return M
