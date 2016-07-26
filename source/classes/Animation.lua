Animation = {

  new = function(self, data, spriterObject, entity)
    local animation = data

    setmetatable(animation, {__index = self})

    animation.spriterObject = spriterObject
    animation.entity        = entity

    if(animation.timeline)then
      animation.timelines = {}

      for index, value in pairs(animation.timeline) do
        local timeline = Timeline:new(value, spriterObject, animation)

        table.insert(animation.timelines, timeline)
      end
    end

    if(animation.mainline and animation.mainline.key)then
      animation.mainlineKeys = {}

      for index, value in pairs(animation.mainline.key) do
        local mainlineKey = MainlineKey:new(value, animation)

        table.insert(animation.mainlineKeys, mainlineKey)
      end
    end

    return animation
  end,

  normalize = function(self)
    self.currentMainlineKey = 0
    self.speed              = 100

    for index, mainlineKey in pairs(self.mainlineKeys) do
      mainlineKey:normalize()
    end

    for index, timeline in pairs(self.timelines) do
      timeline:normalize()
    end
  end,

  create = function(self)
    if(not self.displayObject and self.mainlineKeys)then
      self.displayObject = display.newGroup()

      self.displayObject.animation = self

      self.mainlineKeys[1]:create()
    end
  end,

  play = function(self)
    self:create()

    self:playNextMainlineKey()
  end,

  playNextMainlineKey = function(self)
    -- TODO: make the initial delay when first mainlineKey is not on time zero

    self.currentMainlineKey = self.currentMainlineKey + 1

    self.mainlineKeys[self.currentMainlineKey]:play()

    local nextMainlineKey = self.mainlineKeys[self.currentMainlineKey + 1]

    if(nextMainlineKey)then
      timer.performWithDelay(nextMainlineKey.duration * 100 / self.speed, function()
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

  getLastMainlineKey = function(self)
    return self.mainlineKeys[#self.mainlineKeys]
  end,

  getDisplayObject = function(self)
    return self.displayObject
  end,

  findMainlineKeyById = function(self, id)
    return findBy(self.mainlineKeys, "id", id)
  end,

  findTimelineById = function(self, id)
    return findBy(self.timelines, "id", tonumber(id))
  end

}
