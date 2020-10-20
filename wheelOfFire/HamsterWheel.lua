local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)

  local x = config.x or 0
  local y = config.y or 0

  self.body = love.physics.newBody(self.engine.world, x, y, "dynamic")
  self.body:setAngle(config.angle or 0)

  local shape = love.physics.newCircleShape(config.radius or 0.5)
  self.fixture = love.physics.newFixture(self.body, shape, config.density or 1 / 16)
  self.fixture:setFriction(config.friction or 1)

  insert(self.engine.hamsterWheels, self)
end

function M:destroy()
  removeLast(self.engine.hamsterWheels, self)

  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil
end

return M
