TimelineKey = {

  new = function(self, data, parent, base, previousTimelineKey)
    local timelineKey = data

    setmetatable(timelineKey, {__index = self})

    timelineKey.parent = parent
    timelineKey.base   = base
    timelineKey.time   = timelineKey.time or 0
    timelineKey.spin   = timelineKey.spin or 0

    if(timelineKey.object)then
      timelineKey.object = SpriteTimelineKey:new(timelineKey.object, timelineKey, timelineKey.base, previousTimelineKey.object)
    end

    if(timelineKey.id == 0)then
      timelineKey.duration = timelineKey.parent:getAnimationLength()

    else
      timelineKey.duration = timelineKey.time
    end

    timelineKey.duration = timelineKey.duration - previousTimelineKey.time

    return timelineKey
  end,

  create = function(self)
    if(self.object)then
      local image = self.parent.image

      image.x = self.object.x
      image.y = self.object.y

      image.xScale = self.object.scale_x
      image.yScale = self.object.scale_y

      image.rotation = self.object.angle

      image.anchorX = self.object.file.pivot_x
      image.anchorY = self.object.file.pivot_y
    end
  end,

  play = function(self)
    collectgarbage()

    self:create()

    local timelineKeys = self.parent.keys

    local nextKey = timelineKeys[self.parent.curKey + 1] or timelineKeys[1]

    self.transition = transition.to(self.parent.image, {
      time = nextKey.duration / self.parent:getAnimationSpeed(),

      x = nextKey.object.x,
      y = nextKey.object.y,

      xScale = nextKey.object.scale_x,
      yScale = nextKey.object.scale_y,

      rotation = nextKey.object.angle,

      onComplete = function()
        self.parent:play()
      end
    })
  end

}

-- function TimelineKey:stop()
--   transition.cancel(self.transition)
--
-- --  self.transition:pause()
-- end
