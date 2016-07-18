MainlineKey = {

  new = function(self, data, parent, previousMainlineKey)
    local mainlineKey = data

    setmetatable(mainlineKey, {__index = self})

    mainlineKey.parent = parent
    mainlineKey.time   = mainlineKey.time or 0

    if(mainlineKey.id == 0)then
      mainlineKey.duration = mainlineKey.parent.length

    else
      mainlineKey.duration = mainlineKey.time
    end

    mainlineKey.duration = mainlineKey.duration - previousMainlineKey.time

    if(mainlineKey.object_ref)then
      mainlineKey.objectRefs = {}

      for index, value in pairs(mainlineKey.object_ref) do
        local objectRef = Ref:new(value, mainlineKey)

        table.insert(mainlineKey.objectRefs, objectRef)
      end
    end

    return mainlineKey
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
  end

}
