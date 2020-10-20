local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(hamster, config)
  self.hamster = assert(hamster)
  self.engine = assert(self.hamster.engine)
  insert(self.engine.players, self)
end

function M:destroy()
  removeLast(self.engine.players, self)
end

function M:fixedUpdateInput(dt)
  local leftInput = love.keyboard.isDown("a")
  local rightInput = love.keyboard.isDown("d")

  local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)
  self.hamster.joint:setMotorSpeed(-inputX * 8)
end

return M
