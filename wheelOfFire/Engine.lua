local Camera = require("wheelOfFire.Camera")
local Class = require("wheelOfFire.Class")
local Hamster = require("wheelOfFire.Hamster")
local HamsterWheel = require("wheelOfFire.HamsterWheel")
local KeyboardDevice = require("wheelOfFire.KeyboardDevice")
local Player = require("wheelOfFire.Player")
local utils = require("wheelOfFire.utils")
local Wall = require("wheelOfFire.Wall")

local decompose2 = utils.decompose2
local insertionSort = utils.insertionSort
local mix2 = utils.mix2
local mixAngle = utils.mixAngle
local mixScale2 = utils.mixScale2

local M = Class.new()

function M:init(resources, config)
  self.resources = assert(resources)

  self.fixedDt = config.fixedDt or 1 / 60
  self.accumulatedDt = 0
  self.fixedTime = 0

  self.world = love.physics.newWorld(0, 16)

  self.bones = {}
  self.dirtyTransformBones = {}
  self.dirtyPreviousTransformBones = {}

  self.cameras = {}
  self.hamsters = {}
  self.hamsterWheels = {}
  self.keyboardDevices = {}
  self.players = {}
  self.sprites = {}

  local viewportWidth, viewportHeight = love.graphics.getDimensions()

  Camera.new(self, {
    scale = 1 / 16,

    viewport = {
      x = 0,
      y = 0,

      width = viewportWidth,
      height = viewportHeight,
    },
  })

  Wall.new(self, {
    x = 0, y = 2,
    angle = 1 / 8 * math.pi,
    width = 16, height = 0.5,
  })

  hamsterWheel = HamsterWheel.new(self, {})
  keyboardDevice = KeyboardDevice.new(self, {})
  hamster = Hamster.new(self, hamsterWheel, {})
  Player.new(self, hamster, keyboardDevice, {})
end

function M:update(dt)
  self.accumulatedDt = self.accumulatedDt + dt

  while self.accumulatedDt >= self.fixedDt do
    self.accumulatedDt = self.accumulatedDt - self.fixedDt
    self:fixedUpdate(self.fixedDt)
  end

  local t = self.accumulatedDt / self.fixedDt

  for _, bone in ipairs(self.dirtyPreviousTransformBones) do
    local x1, y1, angle1, scaleX1, scaleY1 = decompose2(bone.previousTransform)
    local x2, y2, angle2, scaleX2, scaleY2 = decompose2(bone.transform)

    local x, y = mix2(x1, y1, x2, y2, t)
    local angle = mixAngle(angle1, angle2, t)
    local scaleX, scaleY = mixScale2(scaleX1, scaleY1, scaleX2, scaleY2, t)

    bone.interpolatedTransform:setTransformation(x, y, angle, scaleX, scaleY)
  end
end

function M:fixedUpdate(dt)
  for i = #self.dirtyPreviousTransformBones, 1, -1 do
    self.dirtyPreviousTransformBones[i]:setPreviousTransformDirty(false)
  end

  for _, player in ipairs(self.players) do
    player:fixedUpdateInput(dt)
  end

  for _, hamster in ipairs(self.hamsters) do
    hamster:fixedUpdateControl(dt)
  end

  self.world:update(dt)

  for _, hamster in ipairs(self.hamsters) do
    hamster:fixedUpdateAnimation(dt)
  end

  while #self.dirtyTransformBones >= 1 do
    self.dirtyTransformBones[#self.dirtyTransformBones]:setTransformDirty(false)
  end
end

function lessZ(a, b)
  return a.z < b.z
end

function M:draw()
  insertionSort(self.sprites, lessZ)

  for _, camera in ipairs(self.cameras) do
    love.graphics.push("all")
    local viewport = camera.viewport

    love.graphics.setScissor(
      viewport.x, viewport.y, viewport.width, viewport.height)

    love.graphics.translate(
      viewport.x + 0.5 * viewport.width, viewport.y + 0.5 * viewport.height)

    local scale = viewport.height * camera.scale
    love.graphics.scale(scale)
    love.graphics.setLineWidth(1 / scale)

    for _, sprite in ipairs(self.sprites) do
      love.graphics.draw(sprite.drawable, sprite.transform)
    end

    self:debugDrawFixtures()
    -- self:debugDrawHamsters()

    love.graphics.pop()
  end
end

function M:debugDrawFixtures()
  love.graphics.push("all")
  love.graphics.setColor(0, 1, 0, 1)

  for _, body in ipairs(self.world:getBodies()) do
    local angle = body:getAngle()

    for _, fixture in ipairs(body:getFixtures()) do
      local shape = fixture:getShape()
      local shapeType = shape:getType()

      if shapeType == "chain" then
        love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))

        local vertexCount = shape:getVertexCount()

        local previousX, previousY = body:getWorldPoint(
          shape:getPreviousVertex())

        local firstX, firstY = body:getWorldPoint(shape:getPoint(1))

        local lastX, lastY = body:getWorldPoint(shape:getPoint(vertexCount))
        local nextX, nextY = body:getWorldPoint(shape:getNextVertex())

        love.graphics.line(previousX, previousY, firstX, firstY)
        love.graphics.line(lastX, lastY, nextX, nextY)
      elseif shapeType == "circle" then
        local x, y = body:getWorldPoint(shape:getPoint())
        local radius = shape:getRadius()
        love.graphics.circle("line", x, y, radius)
        local directionX, directionY = body:getWorldVector(1, 0)

        love.graphics.line(
          x, y, x + directionX * radius, y + directionY * radius)
      elseif shapeType == "polygon" then
        love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
      end
    end
  end

  love.graphics.pop()
end

function M:debugDrawHamsters()
  love.graphics.push("all")

  for _, hamster in ipairs(self.hamsters) do
    local ax, ay, bx, by = hamster.wheelJoint:getAnchors()
    local axisX, axisY = hamster.wheelJoint:getAxis()

    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.line(ax, ay, ax + axisX, ay + axisY)

    love.graphics.setColor(0, 0.5, 1, 1)
    love.graphics.line(ax, ay, ax + hamster.moveInputX, ay + hamster.moveInputY)
  end

  love.graphics.pop()
end

function M:resize(w, h)
  for _, camera in ipairs(self.cameras) do
    camera.viewport.width = w
    camera.viewport.height = h
  end
end

return M
