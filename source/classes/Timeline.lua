Timeline = {

  new = function(self, data, parent, base)
    local timeline = data

    setmetatable(timeline, {__index = self})

    timeline.parent  = parent
    timeline.base    = base
    timeline.playing = false
    timeline.curKey  = 0
    timeline.keys    = {}

    for index, value in pairs(timeline.key) do
      local previousTimelineKey = timeline.key[index - 1] or timeline.key[#timeline.key]

      local timelineKey = TimelineKey:new(value, timeline, timeline.base, previousTimelineKey)

      table.insert(timeline.keys, timelineKey)
    end

    return timeline
  end,

  findTimelineKeyById = function(self, id)
    for index, timelineKey in pairs(self.keys) do
      if(timelineKey.id == id)then
        return timelineKey
      end
    end
  end,

  create = function(self)
    local timelineKey = self.keys[1]

    self.image = display.newImage(self.parent.group, timelineKey.object.file.name)

    timelineKey:create()

    self:hide()
  end,

  show = function(self)
    self.image.isVisible = true
  end,

  hide = function(self)
    self.image.isVisible = false
  end,

  play = function(self)
    collectgarbage()

    self.playing = true

    self.curKey = self.curKey + 1

    if(self.curKey > #self.keys)then
      self.curKey = 1
    end

    self.keys[self.curKey]:play()
  end,

  getAnimationSpeed = function(self)
    return self.parent.speed
  end,

  getAnimationLength = function(self)
    return self.parent.length
  end

}

-- function Timeline:stop()
--   self.keys[self.curKey]:stop()
-- end
