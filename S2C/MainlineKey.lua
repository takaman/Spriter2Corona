local MainlineKey = {}

function MainlineKey:new(data, parent)
  local mainlineKey = data
  mainlineKey.parent = parent

  setmetatable(mainlineKey, {__index = self})

  mainlineKey.time = mainlineKey.time or 0

  for index, objectRef in pairs(mainlineKey.object_ref) do
    local timelineId = tonumber(objectRef.timeline)

    objectRef.timeline = mainlineKey.parent.parent:findTimelineById(timelineId)
    objectRef.key = objectRef.timeline:findTimelineKeyById(objectRef.key)
  end

  return mainlineKey
end

function MainlineKey:play()
  for index, objectRef in pairs(self.object_ref) do
    objectRef.timeline.curMainlineKey = self.id

    if(not objectRef.timeline.playing)then
      objectRef.timeline:play()
    end

    objectRef.timeline:show()
  end

  for index, timeline in pairs(self.parent.parent.timelines) do
    if(timeline.curMainlineKey ~= self.id)then
      timeline:hide()
    end
  end
end

return MainlineKey
