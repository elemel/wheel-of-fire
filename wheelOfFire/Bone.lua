local Class = require("wheelOfFire.Class")

local M = Class.new()

function M:init(boneGraph, localTransform, parent)
  self.boneGraph = assert(boneGraph)
  self.childSet = {}

  self.localTransform = localTransform:clone()
  self.transform = localTransform:clone()
  self.previousTransform = localTransform:clone()
  self.interpolatedTransform = localTransform:clone()

  self.transformDirty = false
  self.previousTransformDirty = false

  self.boneGraph.boneSet[self] = true
  self:setParent(parent)
end

function M:destroy()
  for child in pairs(self.childSet) do
    child:setParent(nil)
  end

  self:setParent(nil)

  self.boneGraph.previousTransformDirtySet[self] = nil
  self.boneGraph.transformDirtySet[self] = nil
  self.boneGraph.boneSet[self] = nil
end

function M:setParent(parent)
  if parent ~= self.parent then
    if self.parent then
      self.parent.childSet[self] = nil
    end

    self.parent = parent

    if self.parent then
      self.parent.childSet[self] = true
    end

    self:setTransformDirty(true)
  end
end

function M:setTransformDirty(dirty)
  assert(type(dirty) == "boolean")

  if dirty ~= self.transformDirty then
    if dirty then
      self.transformDirty = true
      self.boneGraph.transformDirtySet[self] = true

      for child in pairs(self.childSet) do
        child:setTransformDirty(true)
      end

      self:setPreviousTransformDirty(true)
    else
      self.transform:reset()

      if self.parent then
        self.parent:setTransformDirty(false)
        self.transform:apply(self.parent.transform)
      end

      self.transform:apply(self.localTransform)

      self.transformDirty = false
      self.boneGraph.transformDirtySet[self] = nil
    end
  end
end

function M:setPreviousTransformDirty(dirty)
  assert(type(dirty) == "boolean")

  if dirty ~= self.previousTransformDirty then
    if dirty then
      self.previousTransformDirty = true
      self.boneGraph.previousTransformDirtySet[self] = true
    else
      self:setTransformDirty(false)

      self.previousTransform:reset():apply(self.transform)
      self.interpolatedTransform:reset():apply(self.transform)

      self.previousTransformDirty = false
      self.boneGraph.previousTransformDirtySet[self] = nil
    end
  end
end

return M
