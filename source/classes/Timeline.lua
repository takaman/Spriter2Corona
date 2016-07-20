Timeline = {

  new = function(self, data, spriterObject, animation)
    local timeline = data

    setmetatable(timeline, {__index = self})

    timeline.spriterObject = spriterObject
    timeline.animation     = animation

    if(timeline.key)then
      timeline.keys = {}

      for index, value in pairs(timeline.key) do
        local timelineKey = TimelineKey:new(value, timeline.spriterObject, timeline)

        table.insert(timeline.keys, timelineKey)
      end
    end

    return timeline
  end,

  normalize = function(self)
    self.playing = false
    self.curKey  = 0

    if(self.keys)then
      for key, timelineKey in pairs(self.keys) do
        timelineKey:normalize()
      end
    end
  end,

  create = function(self)
    if(not self.displayObject)then
      local timelineKey = self.keys[1]

      if(timelineKey.bone)then
        self.displayObject = display.newGroup()

      else
        self.displayObject = display.newImage(timelineKey.object:getFile():getName())
      end

      self.displayObject.timeline = self

      local parentDisplayObject = self.animation:getDisplayObject()

      if(timelineKey.parent)then
        local parentTimeline = timelineKey.parent:getTimeline()

        parentTimeline:create()

        parentDisplayObject = parentTimeline:getDisplayObject()
      end

      local zIndex = timelineKey.ref:getZIndex() or parentDisplayObject.numChildren + 1

      if(timelineKey.bone)then
        zIndex = timelineKey.ref.ref:getZIndex()
      end

      -- TODO: check if is possible to move zIndex to object props

      for i = parentDisplayObject.numChildren, 1, -1 do
        local parentChildrenDisplayObject = parentDisplayObject[i]

        local parentZIndex = parentChildrenDisplayObject.timeline.keys[1].ref:getZIndex()

        if(not parentZIndex)then
          parentZIndex = parentChildrenDisplayObject.timeline.keys[1].ref.ref:getZIndex()
        end

        if(parentZIndex > zIndex)then
          zIndex = i

          break
        end
      end

      zIndex = math.min(zIndex, parentDisplayObject.numChildren + 1)

      parentDisplayObject:insert(zIndex, self.displayObject)

      timelineKey:create()

      -- self:hide()
    end
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
    self.displayObject.isVisible = true
  end,

  hide = function(self)
    self.displayObject.isVisible = false
  end,

  getAnimation = function(self)
    return self.animation
  end,

  getLastTimelineKey = function(self)
    return self.keys[#self.keys]
  end,

  getDisplayObject = function(self)
    return self.displayObject
  end,

  isPlaying = function(self)
    return self.playing
  end,

  findTimelineKeyById = function(self, id)
    return findBy(self.keys, "id", id)
  end

}
