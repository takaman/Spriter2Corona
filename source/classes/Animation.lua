Animation = {

  new = function(self, data, spriterObject, entity)
    local animation = data

    setmetatable(animation, {__index = self})

    animation.spriterObject = spriterObject
    animation.entity        = entity

    if(animation.timeline)then
      animation.timelines = {}

      for index, value in pairs(animation.timeline) do
        local timeline = Timeline:new(value, animation.spriterObject, animation)

        table.insert(animation.timelines, timeline)
      end
    end

    if(animation.mainline and animation.mainline.key)then
      animation.mainlineKeys = {}

      for index, value in pairs(animation.mainline.key) do
        local mainlineKey = MainlineKey:new(value, animation)

        table.insert(animation.mainlineKeys, mainlineKey)

        mainlineKey:normalize()
      end
    end

    return animation
  end,

  normalize = function(self)
    self.currentMainlineKey = 0
    self.speed              = 100

    if(self.timelines)then
      for index, timeline in pairs(self.timelines) do
        timeline:normalize()
      end
    end
  end,

  create = function(self)
    if(not self.group and self.timelines)then
      self.group = display.newGroup()

      self.group.animation = self

      for index, timeline in pairs(self.timelines) do
        timeline:create()
      end
    end
  end,

  play = function(self)
    self:create()

    self:playNextMainlineKey()
  end,

  playNextMainlineKey = function()
    collectgarbage()

    self.currentMainlineKey = self.currentMainlineKey + 1

    self.mainlineKeys[self.currentMainlineKey]:play()

    local nextMainlineKey = self.mainlineKeys[self.currentMainlineKey + 1]

    if(nextMainlineKey)then
      timer.performWithDelay(nextMainlineKey.duration * self.speed / 100, function()
        self:playNextMainlineKey()
      end)
    end
  end,

  setSpeed = function(self, speed)
    if(speed)then
      speed = tonumber(speed) or 100

      self.speed = tonumber(speed)
    end
  end,

  getLength = function(self)
    return self.length
  end,

  getLastMainlineKey = function(self)
    return self.mainlineKeys[#self.mainlineKeys]
  end,

  getDisplayObject = function(self)
    return self.group
  end,

  findMainlineKeyById = function(self, id)
    return findBy(self.mainlineKeys, "id", id)
  end,

  findTimelineById = function(self, id)
    return findBy(self.timelines, "id", tonumber(id))
  end

}
