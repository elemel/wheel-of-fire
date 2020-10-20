local Class = require("wheelOfFire.Class")

local M = Class.new()

function M:init(game, config)
  self.game = assert(game)

  local x = config.x or 0
  local y = config.y or 0

  local width = config.width or 1
  local height = config.height or 1

  self.body = love.physics.newBody(self.game.world, x, y)
  self.body:setAngle(config.angle or 0)

  local shape = love.physics.newRectangleShape(width, height)
  self.fixture = love.physics.newFixture(self.body, shape)
end

function M:destroy()
  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil
end

return M
