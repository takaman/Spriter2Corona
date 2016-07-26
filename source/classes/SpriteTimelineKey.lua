SpriteTimelineKey = {

  new = function(self, data, spriterObject, timelineKey)
    local spriteTimelineKey = data

    setmetatable(spriteTimelineKey, {__index = self})

    spriteTimelineKey.spriterObject = spriterObject
    spriteTimelineKey.timelineKey   = timelineKey

    spriteTimelineKey.x = spriteTimelineKey.x or 0
    spriteTimelineKey.y = - (spriteTimelineKey.y or 0)

    spriteTimelineKey.scale_x = spriteTimelineKey.scale_x or 1
    spriteTimelineKey.scale_y = spriteTimelineKey.scale_y or 1

    spriteTimelineKey.xScale = spriteTimelineKey.scale_x
    spriteTimelineKey.yScale = spriteTimelineKey.scale_y

    return spriteTimelineKey
  end,

  normalize = function(self)
    self.folder = self.spriterObject:findFolderById(self.folder)
    self.file   = self.folder:findFileById(self.file)

    self.x, self.y, self.scale_x, self.scale_y = self:getParameters()

    if(self.timelineKey.spin == 1)then
      self.angle = self.angle - 360
    end

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
