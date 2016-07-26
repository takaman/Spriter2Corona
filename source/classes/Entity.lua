Entity = {

  new = function(self, data, spriterObject)
    local entity = data

    setmetatable(entity, {__index = self})

    entity.spriterObject = spriterObject

    if(entity.animation)then
      entity.animations = {}

      for index, value in pairs(entity.animation) do
        local animation = Animation:new(value, spriterObject, entity)

        table.insert(entity.animations, animation)

        animation:normalize()
      end
    end

    return entity
  end,

  findAnimationByName = function(self, name)
    return findBy(self.animations, "name", name)
  end

}
