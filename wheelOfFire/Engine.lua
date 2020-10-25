local Camera = require("wheelOfFire.Camera")
local Class = require("wheelOfFire.Class")
local Hamster = require("wheelOfFire.Hamster")
local HamsterWheel = require("wheelOfFire.HamsterWheel")
local KeyboardDevice = require("wheelOfFire.KeyboardDevice")
local Player = require("wheelOfFire.Player")
local Wall = require("wheelOfFire.Wall")

local M = Class.new()

function M:init(resources, config)
  self.resources = assert(resources)

  self.fixedDt = config.fixedDt or 1 / 60
  self.accumulatedDt = 0
  self.fixedTime = 0

  self.world = love.physics.newWorld(0, 16)

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
end

function M:fixedUpdate(dt)
  for _, player in ipairs(self.players) do
    player:fixedUpdateInput(dt)
  end

  for _, hamster in ipairs(self.hamsters) do
    hamster:fixedUpdateControl(dt)
  end

  self.world:update(dt)
end

function M:draw()
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
