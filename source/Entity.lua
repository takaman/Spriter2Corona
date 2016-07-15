local path = string.sub(..., 0, string.find(..., "%.[^%.]*$"))

local Entity = {}

local Animation = require(path .. "Animation")

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

function Entity:findAnimationByName(name)
  for index, animation in pairs(self.animations) do
    if(animation.name == name)then
      return animation
    end
  end
end

return Entity
