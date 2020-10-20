local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local mix2 = utils.mix2
local mixAngle = utils.mixAngle
local mixScale2 = utils.mixScale2
local removeLast = utils.removeLast

local M = Class.new()

local function setTransformations(
  transform, inverseTransform,
  x, y, angle, scaleX, scaleY, originX, originY)

  transform:setTransformation(x, y, angle, scaleX, scaleY, originX, originY)

  inverseTransform
    :reset()
    :translate(originX, originY)
    :scale(1 / scaleX, 1 / scaleY)
    :rotate(-angle)
    :translate(-x, -y)
end

function M:init(engine, x, y, angle, scaleX, scaleY, originX, originY)
  self.engine = assert(engine)

  x = x or 0
  y = y or 0

  angle = angle or 0

  scaleX = scaleX or 1
  scaleY = scaleY or scaleX

  originX = originX or 0
  originY = originY or 0

  self.x = x
  self.y = y

  self.angle = angle

  self.scaleX = scaleX
  self.scaleY = scaleY

  self.originX = originX
  self.originY = originY

  self.previousX = x
  self.previousY = y

  self.previousAngle = angle

  self.previousScaleX = scaleX
  self.previousScaleY = scaleY

  self.previousOriginX = originX
  self.previousOriginY = originY

  self.interpolatedX = x
  self.interpolatedY = y

  self.interpolatedAngle = angle

  self.interpolatedScaleX = scaleX
  self.interpolatedScaleY = scaleY

  self.interpolatedOriginX = originX
  self.interpolatedOriginY = originX

  self.transform = love.math.newTransform()
  self.inverseTransform = love.math.newTransform()

  self.previousTransform = love.math.newTransform()
  self.previousInverseTransform = love.math.newTransform()

  self.interpolatedTransform = love.math.newTransform()
  self.interpolatedInverseTransform = love.math.newTransform()

  insert(self.engine.interpolatedTransforms, self)
end

function M:destroy()
  removeLast(self.engine.interpolatedTransforms, self)
end

function M:fixedUpdateTransform(dt)
  setTransformations(
    self.transform,self.inverseTransform,
    self.x, self.y,
    self.angle,
    self.scaleX, self.scaleY,
    self.originX, self.originY)
end

function M:fixedUpdatePreviousTransform(dt)
  self.previousX = self.x
  self.previousY = self.y

  self.previousAngle = self.angle

  self.previousScaleX = self.scaleX
  self.previousScaleY = self.scaleY

  self.previousOriginX = self.originX
  self.previousOriginY = self.originX

  setTransformations(
    self.previousTransform,self.previousInverseTransform,
    self.previousX, self.previousY,
    self.previousAngle,
    self.previousScaleX, self.previousScaleY,
    self.previousOriginX, self.previousOriginY)
end

function M:updateInterpolatedTransform(dt)
  local t = self.engine.accumulatedDt / self.engine.fixedDt

  self.interpolatedX, self.interpolatedY = mix2(
    self.previousX, self.previousY, self.x, self.y, t)

  self.interpolatedScaleX, self.interpolatedScaleY = mixScale2(
    self.previousScaleX, self.previousScaleY, self.scaleX, self.scaleY, t)

  self.interpolatedAngle = mixAngle(self.previousAngle, self.angle, t)

  self.interpolatedOriginX, self.interpolatedOriginY = mix2(
    self.previousOriginX, self.previousOriginY, self.originX, self.originY, t)

  setTransformations(
    self.interpolatedTransform,self.interpolatedInverseTransform,
    self.interpolatedX, self.interpolatedY,
    self.interpolatedAngle,
    self.interpolatedScaleX, self.interpolatedScaleY,
    self.interpolatedOriginX, self.interpolatedOriginY)
end

return M
