local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local length2 = utils.length2
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

  local upInput = love.keyboard.isDown("w")
  local downInput = love.keyboard.isDown("s")

  local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)
  local inputY = (downInput and 1 or 0) - (upInput and 1 or 0)

  local length = length2(inputX, inputY)

  if length > 1 then
    inputX = inputX / length
    inputY = inputY / length
  end

  self.hamster.inputX = inputX
  self.hamster.inputY = inputY

  self.hamster.previousJumpInput = self.hamster.jumpInput
  self.hamster.jumpInput = love.keyboard.isDown("l")
end

return M
