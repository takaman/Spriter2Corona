local path = string.sub(..., 0, string.find(..., "%.[^%.]*$"))

local MainlineKey = {}

local ObjectRef = require(path .. "ObjectRef")

function MainlineKey:new(data, parent)
  local mainlineKey = data
  mainlineKey.objectRefs = {}
  mainlineKey.parent = parent

  setmetatable(mainlineKey, {__index = self})

  mainlineKey.time = mainlineKey.time or 0

  for index, value in pairs(mainlineKey.object_ref) do
    local objectRef = ObjectRef:new(value, mainlineKey)

    table.insert(mainlineKey.objectRefs, objectRef)
  end

  return mainlineKey
end

function MainlineKey:play()
  local nextKey = self.parent.keys[self.parent.curKey + 1] or self.parent.keys[1]

  for index, objectRef in pairs(self.objectRefs) do
    local objRefFound = false

    for nextIndex, nextObjectRef in pairs(nextKey.objectRefs) do
      if(objectRef.timeline == nextObjectRef.timeline)then
        objRefFound = true

        break
      end
    end

    if(objRefWillHide)then
      objectRef:stop()

    else
      objectRef:play()
    end
  end

  for index, timeline in pairs(self.parent.parent.timelines) do
    if(timeline.curMainlineKey ~= self.id)then
      timeline:hide()
    end
  end
end

return MainlineKey
