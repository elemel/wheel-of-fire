local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(game, config)
  self.game = assert(game)

  local x = config.x or 0
  local y = config.y or 0

  self.body = love.physics.newBody(self.game.world, x, y, "dynamic")
  self.body:setAngle(config.angle or 0)

  local shape = love.physics.newCircleShape(config.radius or 0.5)
  self.fixture = love.physics.newFixture(self.body, shape, config.density or 1)

  insert(self.game.hamsterWheels, self)
end

function M:destroy()
  removeLast(self.game.hamsterWheels, self)

  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil
end

return M
