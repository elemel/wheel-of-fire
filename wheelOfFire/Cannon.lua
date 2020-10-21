local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, hamsterWheel, config)
  self.engine = assert(engine)
  self.hamsterWheel = assert(hamsterWheel)

  insert(self.hamsterWheel.cannons, self)
end

function M:destroy()
  removeLast(self.hamsterWheel.cannons, self)
end

function M:fire()
  local x, y = self.hamsterWheel.body:getWorldPoint(0.25, 0)
  local body = love.physics.newBody(self.engine.world, x, y, "dynamic")
  body:setGravityScale(0.5)

  local shape = love.physics.newCircleShape(0.125)
  local fixture = love.physics.newFixture(body, shape)
  fixture:setSensor(true)

  local directionX, directionY = self.hamsterWheel.body:getWorldVector(1, 0)
  local impulse = 0.5

  body:applyLinearImpulse(impulse * directionX, impulse * directionY, x, y)

  self.hamsterWheel.body:applyLinearImpulse(
    -impulse * directionX, -impulse * directionY, x, y)
end

return M
