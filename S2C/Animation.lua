local Animation = {}

local Timeline = require("S2C.Timeline")
local Mainline = require("S2C.Mainline")

function Animation:new(data, parent)
  local animation = data
  animation.timelines = {}
  animation.parent = parent
  animation.speed = 1

  setmetatable(animation, {__index = self})

  for index, value in pairs(animation.timeline) do
    local timeline = Timeline:new(value, animation)

    table.insert(animation.timelines, timeline)
  end

  animation.mainline = Mainline:new(animation.mainline, animation)

  return animation
end

function Animation:create()
  self.group = display.newGroup()

  for index, timeline in pairs(self.timelines) do
    timeline:create()
  end
end

function Animation:play()
  self:create()

  self.mainline:play()
end

function Animation:findTimelineById(id)
  for index, timeline in pairs(self.timelines) do
    if(timeline.id == id)then
      return timeline
    end
  end
end

return Animation
