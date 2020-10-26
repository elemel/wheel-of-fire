local Class = require("wheelOfFire.Class")
local utils = require("wheelOfFire.utils")

local insert = table.insert
local removeLast = utils.removeLast

local M = Class.new()

function M:init(boneGraph, localToParent, parent)
  self.boneGraph = assert(boneGraph)
  self.children = {}

  self.localToParent = localToParent:clone()
  self.localToWorld = localToParent:clone()
  self.previousLocalToWorld = localToParent:clone()
  self.interpolatedLocalToWorld = localToParent:clone()

  insert(self.boneGraph.bones, self)
  self:setParent(parent)
end

function M:destroy()
  for i = #self.children, 1, -1 do
    self.children[i]:setParent(nil)
  end

  self:setParent(nil)
  removeLast(self.boneGraph.bones, self)
end

function M:setParent(parent)
  if parent == self.parent then
    return
  end

  self:setDirty(false)

  if self.parent then
    removeLast(self.parent.children)
  end

  self.parent = parent

  if self.parent then
    insert(self.parent.children, self)
  end

  self:setDirty(true)
end

function M:setDirty(dirty)
  if dirty and not self.boneGraph.boneToDirty[self] then
    self.boneGraph.boneToDirty[self] = true

    for _, child in ipairs(self.children) do
      child:setDirty(true)
    end
  elseif not dirty and self.boneGraph.boneToDirty[self] then
    self.localToWorld:reset()

    if self.parent then
      self.parent:setDirty(false)
      self.localToWorld:apply(self.parent.localToWorld)
    end

    self.localToWorld:apply(self.localToParent)
    self.boneGraph.boneToDirty[self] = false
  end
end

function M:setPreviousDirty(dirty)
  assert(dirty == false)
  self:setDirty(false)

  self.previousLocalToWorld:reset():apply(self.localToWorld)
  self.interpolatedLocalToWorld:reset():apply(self.localToWorld)

  self.boneGraph.boneToDirty[self] = nil
end

return M
