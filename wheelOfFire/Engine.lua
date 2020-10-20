local Camera = require("wheelOfFire.Camera")
local Class = require("wheelOfFire.Class")
local HamsterWheel = require("wheelOfFire.HamsterWheel")
local Wall = require("wheelOfFire.Wall")

local M = Class.new()

function M:init(resources, config)
  self.fixedDt = config.fixedDt or 1 / 60
  self.accumulatedDt = 0
  self.fixedTime = 0

  self.world = love.physics.newWorld(0, 16)

  self.interpolatedTransforms = {}
  self.cameras = {}
  self.hamsterWheels = {}

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
    x = 0, y = 4,
    width = 8, height = 0.5,
  })

  HamsterWheel.new(self, {})
end

function M:update(dt)
  self.accumulatedDt = self.accumulatedDt + dt

  while self.accumulatedDt >= self.fixedDt do
    self.accumulatedDt = self.accumulatedDt - self.fixedDt
    self:fixedUpdate(self.fixedDt)
  end

  for _, transform in ipairs(self.interpolatedTransforms) do
    transform:updateInterpolatedTransform(dt)
  end
end

function M:fixedUpdate(dt)
  for _, transform in ipairs(self.interpolatedTransforms) do
    transform:fixedUpdatePreviousTransform(dt)
  end

  self.world:update(dt)

  for _, transform in ipairs(self.interpolatedTransforms) do
    transform:fixedUpdateTransform(dt)
  end
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

    self:debugDrawFixtures()
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

        local previousX, previousY = body:getWorldPoint(shape:getPreviousVertex())
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
        love.graphics.line(x, y, x + directionX * radius, y + directionY * radius)
      elseif shapeType == "polygon" then
        love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
      end
    end
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
