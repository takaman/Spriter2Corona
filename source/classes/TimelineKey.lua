TimelineKey = {

  new = function(self, data, spriterObject, timeline)
    local timelineKey = data

    setmetatable(timelineKey, {__index = self})

    timelineKey.spriterObject = spriterObject
    timelineKey.timeline      = timeline

    if(timelineKey.bone)then
      timelineKey.bone = BoneTimelineKey:new(timelineKey.bone, timelineKey.spriterObject, timelineKey)
    end

    if(timelineKey.object)then
      timelineKey.object = SpriteTimelineKey:new(timelineKey.object, timelineKey.spriterObject, timelineKey)
    end

    return timelineKey
  end,

  normalize = function(self)
    self.time = self.time or self.timeline:getAnimation():getLength()

    local previousTimelineKey = self.timeline:findTimelineKeyById(self.id - 1) or self.timeline:getLastTimelineKey()

    self.duration = self.time - previousTimelineKey.time

    self.spin = self.spin or 1

    if(self.spin == 0)then
      self.spin = 1
    end

    if(self.bone)then
      self.bone:normalize()
    end

    if(self.object)then
      self.object:normalize()
    end
  end,

  create = function(self)
    local displayObject = self.timeline:getDisplayObject()

    local parameters = self.object or self.bone

    displayObject.rotation = parameters.angle

    local x = parameters.x
    local y = parameters.y

    local xScale = parameters.scale_x
    local yScale = parameters.scale_y

    if(self.object)then
      displayObject.anchorX = self.object:getFile().pivot_x
      displayObject.anchorY = self.object:getFile().pivot_y
    end

    local ref = self:getRef()

    if(ref)then
      local parentRef = ref:getParent()

      while ref and parentRef do
        local parentTimeline = parentRef:getTimeline()

        xScale = xScale * parentTimeline.keys[1].bone.scale_x
        yScale = yScale * parentTimeline.keys[1].bone.scale_y

        x = x * parentTimeline.keys[1].bone.scale_x
        y = y * parentTimeline.keys[1].bone.scale_y

        ref = parentTimeline.keys[1]:getRef()
        parentRef = ref:getParent()
      end
    end

    if(self.object)then
      displayObject.xScale = xScale
      displayObject.yScale = yScale
    end

    displayObject.x = x
    displayObject.y = y
  end,

  play = function(self)
    -- collectgarbage()
    --
    -- self:create()
    --
    -- local timelineKeys = self.timeline.keys
    --
    -- local nextKey = timelineKeys[self.timeline.curKey + 1] or timelineKeys[1]
    --
    -- if(nextKey.id ~= self.id)then
    --   transition.to(self.timeline.image, {
    --     time = nextKey.duration * self.timeline:getAnimationSpeed() / 100,
    --
    --     x = nextKey.object.x,
    --     y = nextKey.object.y,
    --
    --     xScale = nextKey.object.scale_x,
    --     yScale = nextKey.object.scale_y,
    --
    --     rotation = nextKey.object.angle,
    --
    --     onComplete = function()
    --       self.timeline:play()
    --     end
    --   })
    -- end
  end,

  setRef = function(self, ref)
    self.ref = ref
  end,

  setParent = function(self, parent)
    self.parent = parent
  end,

  getId = function(self)
    return self.id
  end,

  getTimeline = function(self)
    return self.timeline
  end,

  getRef = function(self, ref)
    return self.ref
  end

}
