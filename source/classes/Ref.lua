Ref = {

  new = function(self, data, mainlineKey)
    local ref = data

    setmetatable(ref, {__index = self})

    ref.mainlineKey = mainlineKey

    return ref
  end,

  normalize = function(self)
    self.timeline = self.mainlineKey.animation:findTimelineById(self.timeline)
    self.key      = self.timeline:findTimelineKeyById(self.key)
    self.parent   = self.mainlineKey:findBoneRefById(self.parent)

    if(self.z_index)then
      self.z_index = self.z_index + 1
    end

    if(self.parent)then
      self.parent:setRef(self)
    end

    self.key:setRef(self)
  end,

  create = function(self, zIndex)
    local displayObject = self.mainlineKey.animation:getDisplayObject()

    zIndex = zIndex or self.z_index

    if(self.parent)then
      self.parent:create(zIndex)

      displayObject = self.parent.timeline:getLastDisplayObject()
    end

    self.key:create(displayObject, zIndex)
  end,

  play = function(self)
    if(not self.timeline.playing)then
      self.timeline:play()
    end
  end,

  setRef = function(self, ref)
    self.ref = ref
  end

}
