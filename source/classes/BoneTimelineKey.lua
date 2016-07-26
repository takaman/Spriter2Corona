BoneTimelineKey = {

  new = function(self, data, timelineKey)
    local boneTimelineKey = data

    setmetatable(boneTimelineKey, {__index = self})

    boneTimelineKey.timelineKey   = timelineKey

    boneTimelineKey.x = boneTimelineKey.x or 0
    boneTimelineKey.y = - (boneTimelineKey.y or 0)

    boneTimelineKey.scale_x = boneTimelineKey.scale_x or 1
    boneTimelineKey.scale_y = boneTimelineKey.scale_y or 1

    boneTimelineKey.xScale = boneTimelineKey.scale_x
    boneTimelineKey.yScale = boneTimelineKey.scale_y

    return boneTimelineKey
  end,

  normalize = function(self)
    self.x, self.y, self.scale_x, self.scale_y = self:getParameters()

    self.angle = - self.angle

    -- self.angle = 360 - self:getRotation()
  end,

  getRotation = function(self)
    local angle = self.angle

    local ref = self.timelineKey.ref
    local parentRef = ref.parent

    if(parentRef)then
      local parentTimeline = parentRef.timeline
      local parentTimelineKey = parentTimeline:findTimelineKeyById(self.id) or parentTimeline:getLastTimelineKey()

      local parentAngle = parentTimelineKey.bone:getRotation()

      angle = angle + parentAngle
    end

    return angle
  end,

  getParameters = function(self)
    local x = self.x
    local y = self.y

    local xScale = self.xScale
    local yScale = self.yScale

    local ref = self.timelineKey.ref
    local parentRef = ref.parent

    if(parentRef)then
      local parentTimeline = parentRef.timeline
      local parentTimelineKey = parentTimeline:findTimelineKeyById(self.id) or parentTimeline:getLastTimelineKey()

      local parentX, parentY, parentXScale, parentYScale = parentTimelineKey.bone:getParameters()

      x = x * parentXScale
      y = y * parentYScale

      xScale = xScale * parentXScale
      yScale = yScale * parentYScale
    end

    return x, y, xScale, yScale
  end

}
