local abs = math.abs
local pi = math.pi
local remove = table.remove

local M = {}

local function sign(a)
  return a < 0 and -1 or a > 0 and 1 or 0
end

local function mix(a, b, t)
  return (1 - t) * a + t * b
end

local function mix2(
  ax, ay,
  bx, by,
  tx, ty)

  ty = ty or tx

  local x = mix(ax, bx, tx)
  local y = mix(ay, by, ty)

  return x, y
end

local function mix3(
  ax, ay, az,
  bx, by, bz,
  tx, ty, tz)

  ty = ty or tx
  tz = tz or tx

  local x = mix(ax, bx, tx)
  local y = mix(ay, by, ty)
  local z = mix(az, bz, tz)

  return x, y, z
end

local function mix4(
  ax, ay, az, aw,
  bx, by, bz, bw,
  tx, ty, tz, tw)

  ty = ty or tx
  tz = tz or tx
  tw = tw or tx

  local x = mix(ax, bx, tx)
  local y = mix(ay, by, ty)
  local z = mix(az, bz, tz)
  local w = mix(aw, bw, tw)

  return x, y, z, w
end

local function normalizeAngle(angle, origin)
  origin = origin or 0
  return (angle - origin + pi) % (2 * pi) + origin - pi
end

local function mixAngle(a, b, t)
  origin = 0.5 * (a + b)

  a = normalizeAngle(a, origin)
  b = normalizeAngle(b, origin)

  return mix(a, b, t)
end

local function mixScale(a, b, t)
  return sign(mix(a, b, t)) * mix(abs(a), abs(b), t)
end

local function mixScale2(
  ax, ay,
  bx, by,
  tx, ty)

  ty = ty or tx

  local x = mixScale(ax, bx, tx)
  local y = mixScale(ay, by, ty)

  return x, y
end

local function mixScale3(
  ax, ay, az,
  bx, by, bz,
  tx, ty, tz)

  ty = ty or tx
  tz = tz or tx

  local x = mixScale(ax, bx, tx)
  local y = mixScale(ay, by, ty)
  local z = mixScale(az, bz, tz)

  return x, y, z
end

local function find(t, v)
  for k, v2 in pairs(t) do
    if v2 == v then
      return k
    end
  end

  return nil
end

local function findFirst(t, v)
  for i, v2 in ipairs(t) do
    if v2 == v then
      return i
    end
  end

  return nil
end

local function findLast(t, v)
  for i = #t, 1, -1 do
    if t[i] == v then
      return i
    end
  end

  return nil
end

local function removeLast(t, v)
  local i = findLast(t, v)

  if i then
    remove(t, i)
  end
end

M.find = find
M.findFirst = findFirst
M.findLast = findLast
M.mix = mix
M.mix2 = mix2
M.mix3 = mix3
M.mix4 = mix4
M.mixAngle = mixAngle
M.mixScale = mixScale
M.mixScale2 = mixScale2
M.mixScale3 = mixScale3
M.normalizeAngle = normalizeAngle
M.removeLast = removeLast
M.sign = sign

return M
