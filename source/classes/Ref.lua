Ref = {

  new = function(self, data, mainlineKey)
    local ref = data

    setmetatable(ref, {__index = self})

    ref.mainlineKey = mainlineKey

    return ref
  end,

  normalize = function(self)
    if(self.z_index)then
      self.z_index = self.z_index + 1
    end

    local animation = self.mainlineKey:getAnimation()

    self.timeline = animation:findTimelineById(self.timeline)

    self.key = self.timeline:findTimelineKeyById(self.key)

    if(self.parent)then
      self.parent = self.mainlineKey:findBoneRefById(self.parent)

      self.parent:setRef(self)

      self.key:setParent(self.parent)
    end

    self.key:setRef(self)
  end,

  play = function(self)
    collectgarbage()

    if(not self.timeline:isPlaying())then
      self.timeline:play()
    end

    self.timeline:show()
  end,

  setRef = function(self, ref)
    self.ref = ref
  end,

  getRef = function(self)
    return self.ref
  end,

  getZIndex = function(self)
    return self.z_index
  end,

  getTimeline = function(self)
    return self.timeline
  end,

  getParent = function(self)
    return self.parent
  end

}

--
-- function ObjectRef:stop()
--   self.timeline:stop()
-- end
