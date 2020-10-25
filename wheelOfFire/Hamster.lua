local Bone = require("wheelOfFire.Bone")
local Class = require("wheelOfFire.Class")
local Sprite = require("wheelOfFire.Sprite")
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
  self.body:setAngularDamping(32)

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
    self.body, self.hamsterWheel.body, x1, y1, x2, y2, 0.25)

  self.directionY = 1
  self:createWheelJoint()

  self.bone = Bone.new(self.engine, nil, love.math.newTransform(x, y))
  self.spriteBone = Bone.new(self.engine, self.bone, love.math.newTransform())

  local image = self.engine.resources.images.hamster
  self.sprite = Sprite.new(self.engine, image, self.spriteBone.interpolatedTransform)
  self:resetSpriteBone()

  insert(self.engine.hamsters, self)
end

function M:destroy()
  removeLast(self.engine.hamsters, self)

  self.sprite:destroy()
  self.sprite = nil

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
    self.directionY = -self.directionY
    self:createWheelJoint()
    self:resetSpriteBone()
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

function M:fixedUpdateAnimation(dt)
  local x, y = self.body:getPosition()
  local angle = self.body:getAngle()

  self.bone.localTransform:setTransformation(x, y, angle)
  self.bone:setTransformDirty(true)
end

function M:createWheelJoint()
  local x1, y1 = self.body:getWorldPoint(0, -self.directionY * 0.25)
  local x2, y2 = self.hamsterWheel.body:getPosition()
  local axisX, axisY = self.body:getWorldVector(0, -self.directionY)

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

function M:resetSpriteBone()
  local width, height = self.sprite.drawable:getDimensions()

  local scale = 1 / 1024

  local scaleX = scale
  local scaleY = self.directionY * scale

  local originX = 0.5 * width
  local originY = 0.5 * height

  self.spriteBone.localTransform:setTransformation(0, 0, 0, scaleX, scaleY, originX, originY)
  self.spriteBone:setTransformDirty(true)
  self.spriteBone:setTransformDirty(false)
  self.spriteBone:setPreviousTransformDirty(false)
end

return M
