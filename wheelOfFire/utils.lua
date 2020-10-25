local abs = math.abs
local acos = math.acos
local pi = math.pi
local remove = table.remove
local sqrt = math.sqrt

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
  a = normalizeAngle(a, b)
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

local function length2(x, y)
  return sqrt(x * x + y * y)
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

local function dot2(ax, ay, bx, by)
  return ax * bx + ay * by
end

local function less(a, b)
  return a < b
end

local function insertionSort(t, before)
  before = before or less

  for i = 2, #t do
    for j = i, 2, -1 do
      if not before(t[j], t[j - 1]) then
        break
      end

      t[j], t[j - 1] = t[j - 1], t[j]
    end
  end
end

-- http://frederic-wang.fr/decomposition-of-2d-transform-matrices.html
local function decompose2(transform)
  local t11, t12, t13, t14,
    t21, t22, t23, t24,
    t31, t32, t33, t34,
    t41, t42, t43, t44 = transform:getMatrix()

  local x = t14
  local y = t24

  local angle = 0

  local scaleX = t11 * t11 + t21 * t21
  local scaleY = t12 * t12 + t22 * t22

  local shearX = 0
  local shearY = 0

  if scaleX + scaleY ~= 0 then
    local det = t11 * t22 - t12 * t21

    if scaleX >= scaleY then
      shearX = (t11 * t12 + t21 * t22) / scaleX
      scaleX = sqrt(scaleX)
      angle = sign(t21) * acos(t11 / scaleX)
      scaleY = det / scaleX
    else
      shearY = (t11 * t12 + t21 * t22) / scaleY
      scaleY = sqrt(scaleY)
      angle = 0.5 * pi - sign(t22) * acos(-t12 / scaleY)
      scaleX = det / scaleY
    end
  end

  return x, y, angle, scaleX, scaleY, 0, 0, shearX, shearY
end

M.decompose2 = decompose2
M.dot2 = dot2
M.find = find
M.findFirst = findFirst
M.findLast = findLast
M.insertionSort = insertionSort
M.length2 = length2
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
