Timeline = {

  new = function(self, data, parent, base)
    local timeline = data

    setmetatable(timeline, {__index = self})

    timeline.parent  = parent
    timeline.base    = base
    timeline.playing = false
    timeline.curKey  = 0

    if(timeline.key)then
      timeline.keys    = {}

      for index, value in pairs(timeline.key) do
        local previousTimelineKey = timeline.key[index - 1] or timeline.key[#timeline.key]

        local timelineKey = TimelineKey:new(value, timeline, timeline.base, previousTimelineKey)

        table.insert(timeline.keys, timelineKey)
      end
    end

    return timeline
  end,

  create = function(self)
    local timelineKey = self.keys[1]

    if(timelineKey.object)then
      self.image = display.newImage(timelineKey.object.file.name)

      -- TODO: correct the z-index warning

      self.parent.group:insert(self.zIndex, self.image)
    end

    timelineKey:create()

    -- self:hide()
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

  show = function(self)
    if(self.image)then
      self.image.isVisible = true
    end
  end,

  hide = function(self)
    if(self.image)then
      self.image.isVisible = false
    end
  end,

  getAnimationSpeed = function(self)
    return self.parent.speed
  end,

  getAnimationLength = function(self)
    return self.parent.length
  end,

  findTimelineKeyById = function(self, id)
    return findBy(self.keys, "id", id)
  end

}
