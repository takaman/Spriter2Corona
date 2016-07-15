SpriteTimelineKey = {

  new = function(self, data, parent, base, previousSpriteTimelineKey)
    local spriteTimelineKey = data

    setmetatable(spriteTimelineKey, {__index = self})

    spriteTimelineKey.parent  = parent
    spriteTimelineKey.base    = base
    spriteTimelineKey.y       = spriteTimelineKey.y * -1
    spriteTimelineKey.scale_x = spriteTimelineKey.scale_x or 1
    spriteTimelineKey.scale_y = spriteTimelineKey.scale_y or 1
    spriteTimelineKey.folder  = spriteTimelineKey.base:findFolderById(spriteTimelineKey.folder)
    spriteTimelineKey.file    = spriteTimelineKey.folder:findFileById(spriteTimelineKey.file)
    spriteTimelineKey.angle   = spriteTimelineKey.angle or 0

    local clockwise = - 1

    if(previousSpriteTimelineKey.spin == -1)then
      clockwise = 1
    end

    spriteTimelineKey.angle = (360 - spriteTimelineKey.angle) * clockwise

    return spriteTimelineKey
  end

}
