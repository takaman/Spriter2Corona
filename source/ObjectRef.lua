local ObjectRef = {}

function ObjectRef:new(data, parent)
  local objectRef = data
  objectRef.parent = parent

  setmetatable(objectRef, {__index = self})

  local timelineId = tonumber(objectRef.timeline)

  objectRef.timeline = objectRef.parent.parent.parent:findTimelineById(timelineId)
  objectRef.key = objectRef.timeline:findTimelineKeyById(objectRef.key)

  return objectRef
end

function ObjectRef:play()
  self.timeline.curMainlineKey = self.parent.id

  if(not self.timeline.playing)then
    self.timeline:play()
  end

  self.timeline:show()
end

function ObjectRef:stop()
  self.timeline:stop()
end

return ObjectRef
