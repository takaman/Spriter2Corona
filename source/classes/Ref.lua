Ref = {

  new = function(self, data, parent)
    local ref = data

    setmetatable(ref, {__index = self})

    ref.parent = parent

    local timelineId = tonumber(ref.timeline)

    ref.timeline = ref.parent.parent:findTimelineById(timelineId)
    ref.timeline.zIndex = ref.z_index or 0
    ref.timeline.zIndex = ref.timeline.zIndex + 1

    ref.key = ref.timeline:findTimelineKeyById(ref.key)

    return ref
  end,

  play = function(self)
    collectgarbage()

    if(not self.timeline.playing)then
      self.timeline:play()
    end

    self.timeline:show()
  end

}

--
-- function ObjectRef:stop()
--   self.timeline:stop()
-- end
