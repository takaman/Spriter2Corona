SpriteTimelineKey = {

  new = function(self, data, spriterObject, timelineKey)
    local spriteTimelineKey = data

    setmetatable(spriteTimelineKey, {__index = self})

    spriteTimelineKey.spriterObject = spriterObject
    spriteTimelineKey.timelineKey   = timelineKey

    return spriteTimelineKey
  end,

  normalize = function(self)
    self.x = self.x or 0
    self.y = - (self.y or 0)

    self.scale_x = self.scale_x or 1
    self.scale_y = self.scale_y or 1

    self.folder = self.spriterObject:findFolderById(self.folder)
    self.file   = self.folder:findFileById(self.file)

    local timeline = self.timelineKey:getTimeline()

    local previousTimelineKey = timeline:findTimelineKeyById(self.timelineKey:getId() - 1) or timeline:getLastTimelineKey()

    self.angle = - self.angle
  end,

  getFile = function(self)
    return self.file
  end

}
