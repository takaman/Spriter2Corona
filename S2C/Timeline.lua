local Timeline = {}

local TimelineKey = require("S2C.TimelineKey")

function Timeline:new(data, parent)
  local timeline = data
  timeline.keys = {}
  timeline.parent = parent
  timeline.playing = false
  timeline.curKey = 0

  setmetatable(timeline, {__index = self})

  for index, value in pairs(timeline.key) do
    local timelineKey = TimelineKey:new(value, timeline)

    table.insert(timeline.keys, timelineKey)

    local prevKey = timeline.key[index - 1]

    local clockwise = 1

    if(prevKey)then
      timelineKey.duration = timelineKey.time - prevKey.time

      if(prevKey.spin == -1)then
        clockwise = prevKey.spin
      end

    else
      timelineKey.duration = timeline.parent.length - timeline.key[#timeline.key].time
    end

    timelineKey.object.angle = (360 - timelineKey.object.angle) * - clockwise
  end

  return timeline
end

function Timeline:create()
  local key = self.keys[1]

  self.image = display.newImage(self.parent.group, key.object.file.name)

  self.image.isVisible = false

  self.image.x = key.object.x
  self.image.y = key.object.y

  self.image.xScale = key.object.scale_x
  self.image.yScale = key.object.scale_y

  self.image.rotation = key.object.angle

  self.image.anchorX = key.object.file.pivot_x
  self.image.anchorY = key.object.file.pivot_y
end

function Timeline:play()
  self.playing = true

  self:next()
end

function Timeline:show()
  self.image.isVisible = true
end

function Timeline:hide()
  self.image.isVisible = false
end

function Timeline:next()
  self.curKey = self.curKey + 1

  if(self.curKey > #self.keys)then
    self.curKey = 1
  end

  self.keys[self.curKey]:play()
end

function Timeline:hide()
  self.image.isVisible = false
end

function Timeline:findTimelineKeyById(id)
  for index, timelineKey in pairs(self.keys) do
    if(timelineKey.id == id)then
      return timelineKey
    end
  end
end

return Timeline
