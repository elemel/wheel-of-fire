local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)

  self.x = config.x or 0
  self.y = config.y or 0

  self.angle = config.angle or 0
  self.scale = config.scale or 1

  self.viewport = {
    x = config.viewport and config.viewport.x or 0,
    y = config.viewport and config.viewport.y or 0,

    width = config.viewport and config.viewport.width or 800,
    height = config.viewport and config.viewport.height or 600,
  }

  insert(self.engine.cameras, self)
end

function M:destroy()
  removeLast(self.engine.cameras, self)
end

return M
