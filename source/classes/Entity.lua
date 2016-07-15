Entity = {

  new = function(self, data, parent)
    local entity = data

    setmetatable(entity, {__index = self})

    entity.parent     = parent
    entity.animations = {}

    for index, value in pairs(entity.animation) do
      local animation = Animation:new(value, entity, entity.parent)

      table.insert(entity.animations, animation)
    end

    return entity
  end,

  findAnimationByName = function(self, name)
    return findBy(self.animations, "name", name)
  end

}
