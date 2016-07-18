Animation = {

  new = function(self, data, parent, base)
    local animation = data

    setmetatable(animation, {__index = self})

    animation.parent             = parent
    animation.base               = base
    animation.currentMainlineKey = 0
    animation.speed              = 100

    if(animation.timeline)then
      animation.timelines = {}

      for index, value in pairs(animation.timeline) do
        local timeline = Timeline:new(value, animation, animation.base)

        table.insert(animation.timelines, timeline)
      end
    end

    if(animation.mainline and animation.mainline.key)then
      animation.mainlineKeys = {}

      for index, value in pairs(animation.mainline.key) do
        local previousMainlineKey = animation.mainline.key[index - 1] or animation.mainline.key[#animation.mainline.key]

        local mainlineKey = MainlineKey:new(value, animation, previousMainlineKey)

        table.insert(animation.mainlineKeys, mainlineKey)
      end
    end

    return animation
  end,

  create = function(self)
    if(not self.group and self.timelines)then
      self.group = display.newGroup()

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

  getDisplayObject = function(self)
    return self.group
  end,

  findTimelineById = function(self, id)
    return findBy(self.timelines, "id", id)
  end

}
