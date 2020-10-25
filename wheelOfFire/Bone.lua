local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(engine, parent, localTransform)
  self.engine = assert(engine)
  self.children = {}

  self.localTransform = localTransform:clone()
  self.transform = localTransform:clone()
  self.previousTransform = localTransform:clone()
  self.interpolatedTransform = localTransform:clone()

  self.transformDirty = false
  self.previousTransformDirty = false

  insert(self.engine.bones, self)
  self:setParent(parent)
end

function M:destroy()
  for i = #self.children, 1, -1 do
    self.children[i]:setParent(nil)
  end

  self:setParent(nil)
  removeLast(self.engine.bones, self)
end

function M:setParent(parent)
  if parent == self.parent then
    return
  end

  if self.parent then
    removeLast(self.parent.children)
  end

  self.parent = parent

  if self.parent then
    insert(self.parent.children, self)
  end
end

function M:setTransformDirty(dirty)
  if dirty == self.transformDirty then
    return
  end

  if dirty then
    self.transformDirty = true
    insert(self.engine.dirtyTransformBones, self)

    self:setPreviousTransformDirty(true)

    for _, child in ipairs(self.children) do
      child:setTransformDirty(true)
    end

    return
  end

  self.transform:reset()

  if self.parent then
    self.parent:setTransformDirty(false)
    self.transform:apply(self.parent.transform)
  end

  self.transform:apply(self.localTransform)

  self.transformDirty = false
  removeLast(self.engine.dirtyTransformBones, self)
end

function M:setPreviousTransformDirty(dirty)
  if dirty == self.previousTransformDirty then
    return
  end

  if dirty then
    self.previousTransformDirty = true
    insert(self.engine.dirtyPreviousTransformBones, self)

    return
  end

  self:setTransformDirty(false)
  self.previousTransform:reset():apply(self.transform)
  self.interpolatedTransform:reset():apply(self.transform)

  self.previousTransformDirty = false
  removeLast(self.engine.dirtyPreviousTransformBones, self)
end

return M
