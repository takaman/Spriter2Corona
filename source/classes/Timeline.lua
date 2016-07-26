Timeline = {

  new = function(self, data, spriterObject, animation)
    local timeline = data

    setmetatable(timeline, {__index = self})

    timeline.spriterObject = spriterObject
    timeline.animation     = animation

    if(timeline.key)then
      timeline.keys = {}

      for index, value in pairs(timeline.key) do
        local timelineKey = TimelineKey:new(value, spriterObject, timeline)

        table.insert(timeline.keys, timelineKey)
      end
    end

    return timeline
  end,

  normalize = function(self)
    self.playing        = false
    self.currentKey     = 0
    self.displayObjects = {}

    if(self.keys)then
      for key, timelineKey in pairs(self.keys) do
        timelineKey:normalize()
      end
    end
  end,

  create = function(self, timelineKeyId, parentDisplayObject, zIndex)
    local timelineKey = self:findTimelineKeyById(timelineKeyId)

    local displayObject

    -- TODO: test if this breaks the zIndex
    zIndex = math.min(zIndex, parentDisplayObject.numChildren + 1)

    if(timelineKey.bone)then
      displayObject = display.newGroup()

      parentDisplayObject:insert(zIndex, displayObject)

    else
      displayObject = display.newImage(timelineKey.object.file.name)

      parentDisplayObject:insert(zIndex, displayObject)
    end

    displayObject.timeline = self

    table.insert(self.displayObjects, displayObject)

      -- if(timelineKey.bone)then
      --   self.displayObject = display.newGroup()
      --
      -- else
      --   self.displayObject = display.newImage(timelineKey.object.file.name)
      -- end
      --
      -- self.displayObject.timeline = self
      --
      -- local parentDisplayObject = self.animation.displayObject
      --
      -- local zIndex = timelineKey.ref.z_index

      -- if(timelineKey.ref.ref)then
      --   zIndex = timelineKey.ref.ref.z_index:getZIndex()
      -- end

        -- TODO: check if is possible to move zIndex to object props

        -- ZINDEX recursivo, pegando o maior dos parent, e depois o resto, rs

        -- for i = parentDisplayObject.numChildren, 1, -1 do
        --   local parentChildrenDisplayObject = parentDisplayObject[i]
        --
        --   local parentZIndex = parentChildrenDisplayObject.timeline:findTimelineKeyById(0).ref:getZIndex()
        --
        --   if(not parentZIndex)then
        --     parentZIndex = parentChildrenDisplayObject.timeline:findTimelineKeyById(0).ref.ref:getZIndex()
        --   end
        --
        --   if(parentZIndex > zIndex)then
        --     zIndex = i
        --
        --     break
        --   end
        -- end

        -- zIndex = math.min(zIndex, parentDisplayObject.numChildren + 1)
        --
        -- parentDisplayObject:insert(zIndex, self.displayObject)
        --
        -- timelineKey:create()

        -- self:hide()
  end,

  play = function(self)
    self.playing = true

    self:playNextTimelineKey()
  end,

  playNextTimelineKey = function(self)
    self.currentKey = self.currentKey + 1

    if(self.currentKey > #self.keys)then
      self.currentKey = 1
    end

    self.keys[self.currentKey]:play()
  end,

  getLastDisplayObject = function(self)
    return self.displayObjects[#self.displayObjects]
  end,

  getLastTimelineKey = function(self)
    return self.keys[#self.keys]
  end,

  findTimelineKeyById = function(self, id)
    return findBy(self.keys, "id", id)
  end

}
