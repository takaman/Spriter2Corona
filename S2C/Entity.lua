local Entity = {}

local Animation = require("S2C.Animation")

function Entity:new(data, parent)
  local entity = data
  entity.animations = {}
  entity.parent = parent

  setmetatable(entity, {__index = self})

  for index, value in pairs(entity.animation) do
    local animation = Animation:new(value, entity)

    table.insert(entity.animations, animation)
  end

  return entity
end

return Entity
