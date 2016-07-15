Animation = {

  new = function(self, data, parent, base)
    local animation = data

    setmetatable(animation, {__index = self})

    animation.parent       = parent
    animation.base         = base
    animation.curKey       = 0
    animation.timelines    = {}
    animation.mainlineKeys = {}

    animation:setSpeed(1)

    for index, value in pairs(animation.timeline) do
      local timeline = Timeline:new(value, animation, animation.base)

      table.insert(animation.timelines, timeline)
    end

    local mainlineKeys = animation.mainline.key

    for index, value in pairs(mainlineKeys) do
      local previousMainlineKey = mainlineKeys[index - 1] or mainlineKeys[#mainlineKeys]

      local mainlineKey = MainlineKey:new(value, animation, previousMainlineKey)

      table.insert(animation.mainlineKeys, mainlineKey)
    end

    return animation
  end,

  findTimelineById = function(self, id)
    return findBy(self.timelines, "id", id)
  end,

  setSpeed = function(self, speed)
    self.speed = tonumber(speed)
  end,

  getDisplayObject = function(self)
    return self.group
  end,

  play = function(self)
    collectgarbage()

    self:create()

    -- TODO: make the starting delay if first mainlineKey is not on time 0

    self.curKey = self.curKey + 1

    self.mainlineKeys[self.curKey]:play()

    local nextMainlineKey = self.mainlineKeys[self.curKey + 1]

    if(not nextMainlineKey)then
      nextMainlineKey = self.mainlineKeys[1]

      self.curKey = 0
    end

    timer.performWithDelay(nextMainlineKey.duration / self.speed, function()
      self:play()
    end)
  end,

  create = function(self)
    if(not self.group)then
      self.group = display.newGroup()

      for index, timeline in pairs(self.timelines) do
        timeline:create()
      end
    end
  end

}
