MainlineKey = {

  new = function(self, data, animation)
    local mainlineKey = data

    setmetatable(mainlineKey, {__index = self})

    mainlineKey.animation = animation

    if(mainlineKey.bone_ref)then
      mainlineKey.boneRefs = {}

      for index, value in pairs(mainlineKey.bone_ref) do
        local boneRef = Ref:new(value, mainlineKey)

        table.insert(mainlineKey.boneRefs, boneRef)
      end
    end

    if(mainlineKey.object_ref)then
      mainlineKey.objectRefs = {}

      for index, value in pairs(mainlineKey.object_ref) do
        local objectRef = Ref:new(value, mainlineKey)

        table.insert(mainlineKey.objectRefs, objectRef)
      end
    end

    return mainlineKey
  end,

  normalize = function(self)
    self.time = self.time or 0

    -- TODO: check if this duration is right
    local previousMainlineKey = self.animation:findMainlineKeyById(self.id - 1) or self.animation:getLastMainlineKey()

    if(self.time == 0)then
      self.duration = self.animation.length - previousMainlineKey.time

    else
      self.duration = self.time - previousMainlineKey.time
    end

    for key, boneRef in pairs(self.boneRefs) do
      boneRef:normalize()
    end

    for key, objectRef in pairs(self.objectRefs) do
      objectRef:normalize()
    end
  end,

  create = function(self)
    for key, objectRef in pairs(self.objectRefs) do
      objectRef:create()
    end
  end,

  play = function(self)
    for key, boneRef in pairs(self.boneRefs) do
      boneRef:play()
    end

    for key, objectRef in pairs(self.objectRefs) do
      objectRef:play()
    end
  end,

  findBoneRefById = function(self, id)
    return findBy(self.boneRefs, "id", id)
  end

}




-- local mainlineKeys = self.parent.mainlineKeys
-- local nextKey = mainlineKeys[self.parent.curKey + 1] or mainlineKeys[1]

-- if(self.objectRefs)then
  -- local objRefFound = false

  -- for nextIndex, nextObjectRef in pairs(nextKey.objectRefs) do
  --   if(objectRef.timeline == nextObjectRef.timeline)then
  --     objRefFound = true
  --
  --     break
  --   end
  -- end

  -- if(objRefWillHide)then
  --   objectRef:stop()
  --
  -- else
  --   objectRef:play()
  -- end
-- end
