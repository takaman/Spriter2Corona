local TimelineKey = {}

local Object = require("S2C.Object")

function TimelineKey:new(data, parent)
  local timelineKey = data
  timelineKey.parent = parent

  setmetatable(timelineKey, {__index = self})

  timelineKey.object = Object:new(timelineKey.object, timelineKey)

  timelineKey.time = timelineKey.time or 0

  timelineKey.object.scale_x = timelineKey.object.scale_x or 1
  timelineKey.object.scale_y = timelineKey.object.scale_y or 1

  timelineKey.object.angle = timelineKey.object.angle or 0

  timelineKey.spin = timelineKey.spin or 0

  return timelineKey
end

function TimelineKey:play()
  local nextKey = self.parent.keys[self.parent.curKey + 1]

  if(not nextKey)then
    nextKey = self.parent.keys[1]
  end

  transition.to(self.parent.image, {
    time = nextKey.duration * self.parent.parent.speed,
    x = nextKey.object.x,
    y = nextKey.object.y,
    xScale = nextKey.object.scale_x,
    yScale = nextKey.object.scale_y,
    rotation = nextKey.object.angle,
    onComplete = function()
      self.parent:next()
    end
  })
end

return TimelineKey
