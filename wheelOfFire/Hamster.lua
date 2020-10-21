local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local dot2 = utils.dot2
local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, hamsterWheel, config)
  self.engine = assert(engine)
  self.hamsterWheel = assert(hamsterWheel)

  local x, y = self.hamsterWheel.body:getPosition()
  self.body = love.physics.newBody(self.engine.world, x, y, "dynamic")
  self.body:setAngularDamping(16)

  local shape = love.physics.newCircleShape(config.radius or 0.25)
  self.fixture = love.physics.newFixture(self.body, shape, config.density or 1)
  self.fixture:setSensor(true)

  self.moveInputX = 0
  self.moveInputY = 0

  self.jumpInput = config.fireInput or false
  self.previousJumpInput = self.jumpInput

  self.fireInput = config.fireInput or false
  self.previousFireInput = self.fireInput

  local x1, y1 = self.body:getPosition()
  local x2, y2 = self.hamsterWheel.body:getPosition()

  self.ropeJoint = love.physics.newRopeJoint(
    self.body, self.hamsterWheel.body, x1, y1, x2, y2, 0.375)

  self.directionX = 1
  self:createWheelJoint()

  insert(self.engine.hamsters, self)
end

function M:destroy()
  removeLast(self.engine.hamsters, self)
  self:destroyWheelJoint()

  self.ropeJoint:destroy()
  self.ropeJoint = nil

  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil
end

function M:fixedUpdateControl(dt)
  if self.jumpInput and not self.previousJumpInput then
    self:destroyWheelJoint()
    self.directionX = -self.directionX
    self:createWheelJoint()
  end

  if self.fireInput and not self.previousFireInput then
    for _, cannon in ipairs(self.hamsterWheel.cannons) do
      cannon:fire()
    end
  end

  local axisX, axisY = self.wheelJoint:getAxis()

  local tangentX = axisY
  local tangentY = -axisX

  local motorSpeed = -16 * dot2(self.moveInputX, self.moveInputY, tangentX, tangentY)
  self.wheelJoint:setMotorSpeed(motorSpeed)
end

function M:createWheelJoint()
  local x1, y1 = self.body:getWorldPoint(0, -self.directionX * 0.375)
  local x2, y2 = self.hamsterWheel.body:getPosition()
  local axisX, axisY = self.body:getWorldVector(0, -self.directionX)

  self.wheelJoint = love.physics.newWheelJoint(
    self.body, self.hamsterWheel.body, x1, y1, x2, y2, axisX, axisY)

  self.wheelJoint:setMotorEnabled(true)
  self.wheelJoint:setMaxMotorTorque(2)

  self.wheelJoint:setSpringFrequency(8)
end

function M:destroyWheelJoint()
  self.wheelJoint:destroy()
  self.wheelJoint = nil
end

return M
