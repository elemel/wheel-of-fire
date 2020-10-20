local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(hamsterWheel, config)
  self.hamsterWheel = assert(hamsterWheel)
  self.engine = assert(self.hamsterWheel.engine)

  local x, y = self.hamsterWheel.body:getPosition()
  self.body = love.physics.newBody(self.engine.world, x, y + 0.25, "dynamic")

  local shape = love.physics.newCircleShape(config.radius or 0.25)
  self.fixture = love.physics.newFixture(self.body, shape, config.density or 1)
  self.fixture:setSensor(true)

  self.inputX = 0
  self.inputY = 0

  self.jumpInput = false
  self.previousJumpInput = self.jumpInput

  self.directionX = 1
  self:createJoint()

  insert(self.engine.hamsters, self)
end

function M:destroy()
  removeLast(self.engine.hamsters, self)

  self.joint:destroy()
  self.joint = nil

  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil
end

function M:fixedUpdateControl(dt)
  if self.jumpInput and not self.previousJumpInput then
    self.joint:destroy()
    self.joint = nil

    self.directionX = -self.directionX
    self:createJoint()
  end

  self.joint:setMotorSpeed(-self.inputX * 8)
end

function M:createJoint()
  local x1, y1 = self.hamsterWheel.body:getPosition()
  local x2, y2 = self.body:getWorldPoint(0, -self.directionX * 0.25)

  self.joint = love.physics.newRevoluteJoint(
    self.hamsterWheel.body, self.body, x1, y1, x2, y2)

  self.joint:setMotorEnabled(true)
  self.joint:setMaxMotorTorque(0.5)
  self.joint:setMotorSpeed(-self.inputX * 8)
end

return M
