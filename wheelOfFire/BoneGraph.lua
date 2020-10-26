local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local mixTransform = utils.mixTransform

local M = Class.new()

function M:init()
  self.bones = {}
  self.boneToDirty = {}
end

function M:updatePrevious()
  for bone in pairs(self.boneToDirty) do
    bone:setPreviousDirty(false)
  end
end

function M:updateDirty()
  for bone, dirty in pairs(self.boneToDirty) do
    if dirty then
      bone:setDirty(false)
    end
  end
end

function M:updateInterpolated(t)
  for bone in pairs(self.boneToDirty) do
    mixTransform(
      bone.previousLocalToWorld,
      bone.localToWorld,
      t,
      bone.interpolatedLocalToWorld)
  end
end

return M
