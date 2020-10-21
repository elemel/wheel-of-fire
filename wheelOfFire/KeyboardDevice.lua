local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local length2 = utils.length2
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)

  self.leftKey = config.leftKey or "a"
  self.rightKey = config.rightKey or "d"

  self.upKey = config.upKey or "w"
  self.downKey = config.downKey or "s"

  self.jumpKey = config.jumpKey or "l"
  self.fireKey = config.fireKey or "k"

  self.respawnKey = config.respawnKey or "backspace"

  insert(self.engine.keyboardDevices, self)
end

function M:destroy()
  removeLast(self.engine.keyboardDevices, self)
end

function M:getJumpInput()
  return love.keyboard.isDown(self.jumpKey)
end

function M:getFireInput()
  return love.keyboard.isDown(self.fireKey)
end

function M:getRespawnInput()
  return love.keyboard.isDown(self.respawnKey)
end

function M:getMoveInput()
  local leftInput = love.keyboard.isDown(self.leftKey)
  local rightInput = love.keyboard.isDown(self.rightKey)

  local upInput = love.keyboard.isDown(self.upKey)
  local downInput = love.keyboard.isDown(self.downKey)

  local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)
  local inputY = (downInput and 1 or 0) - (upInput and 1 or 0)

  local length = length2(inputX, inputY)

  if length > 1 then
    inputX = inputX / length
    inputY = inputY / length
  end

  return inputX, inputY
end

return M
