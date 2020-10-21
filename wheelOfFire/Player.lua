local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, hamster, inputDevice, config)
  self.engine = assert(engine)
  self.hamster = assert(hamster)
  self.inputDevice = assert(inputDevice)
  insert(self.engine.players, self)
end

function M:destroy()
  removeLast(self.engine.players, self)
end

function M:fixedUpdateInput(dt)
  self.hamster.previousJumpInput = self.hamster.jumpInput
  self.hamster.previousFireInput = self.hamster.fireInput

  self.hamster.moveInputX, self.hamster.moveInputY = self.inputDevice:getMoveInput()

  self.hamster.jumpInput = self.inputDevice:getJumpInput()
  self.hamster.fireInput = self.inputDevice:getFireInput()
end

return M
