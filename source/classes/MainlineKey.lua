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
    self.time = self.time or self.animation:getLength()

    local previousMainlineKey = self.animation:findMainlineKeyById(self.id - 1) or self.animation:getLastMainlineKey()

    self.duration = self.time - previousMainlineKey.time

    if(self.boneRefs)then
      for key, boneRef in pairs(self.boneRefs) do
        boneRef:normalize()
      end

      for key, objectRef in pairs(self.objectRefs) do
        objectRef:normalize()
      end
    end
  end,

  play = function(self)
    collectgarbage()

    -- local mainlineKeys = self.parent.mainlineKeys
    -- local nextKey = mainlineKeys[self.parent.curKey + 1] or mainlineKeys[1]

    if(self.objectRefs)then
      for index, objectRef in pairs(self.objectRefs) do
        objectRef:play()

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
      end
    end
  end,

  getAnimation = function(self)
    return self.animation
  end,

  findBoneRefById = function(self, id)
    return findBy(self.boneRefs, "id", id)
  end

}
