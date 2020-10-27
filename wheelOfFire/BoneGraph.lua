local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local mixTransform = utils.mixTransform

local M = Class.new()

function M:init()
  self.boneSet = {}
  self.transformDirtySet = {}
  self.previousTransformDirtySet = {}
end

function M:updatePreviousTransforms()
  for bone in pairs(self.previousTransformDirtySet) do
    bone:setPreviousTransformDirty(false)
  end
end

function M:updateTransforms()
  for bone in pairs(self.transformDirtySet) do
    bone:setTransformDirty(false)
  end
end

function M:updateInterpolatedTransforms(t)
  for bone in pairs(self.previousTransformDirtySet) do
    mixTransform(
      bone.previousTransform,
      bone.transform,
      t,
      bone.interpolatedtransform)
  end
end

return M
