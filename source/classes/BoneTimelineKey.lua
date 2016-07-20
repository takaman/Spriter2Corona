BoneTimelineKey = {

  new = function(self, data, spriterObject, timelineKey)
    local boneTimelineKey = data

    setmetatable(boneTimelineKey, {__index = self})

    boneTimelineKey.spriterObject = spriterObject
    boneTimelineKey.timelineKey   = timelineKey

    return boneTimelineKey
  end,

  normalize = function(self)
    self.x = self.x or 0
    self.y = - (self.y or 0)

    self.scale_x = self.scale_x or 1
    self.scale_y = self.scale_y or 1

    local timeline = self.timelineKey:getTimeline()

    local previousTimelineKey = timeline:findTimelineKeyById(self.timelineKey:getId() - 1) or timeline:getLastTimelineKey()

    self.angle = - self.angle
  end

}
