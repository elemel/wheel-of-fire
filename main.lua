local Engine = require("wheelOfFire.Engine")

function love.load(arg)
  love.window.setTitle("Wheel of Fire")

  love.window.setMode(800, 600, {
    -- fullscreen = true,
    highdpi = true,
    resizable = true,
  })

  love.physics.setMeter(1)

  resources = {
    images = {
      hamster = love.graphics.newImage("resources/images/hamster.png"),
    }
  }

  engine = Engine.new(resources, {})
end

function love.update(dt)
  engine:update(dt)
end

function love.draw()
  engine:draw()
end

function love.resize(w, h)
  engine:resize(w, h)
end
