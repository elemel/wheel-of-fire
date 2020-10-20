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

  self.joint = love.physics.newRevoluteJoint(self.hamsterWheel.body, self.body, x, y)
  self.joint:setMotorEnabled(true)
  self.joint:setMaxMotorTorque(0.5)

  insert(self.engine.hamsters, self)
end

function M:destroy()
  removeLast(self.engine.hamsters, self)

  self.body:destroy()
  self.body = nil
end

return M
