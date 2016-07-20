-- this is the first file compiled, forward declare vars and funcs to use in plugin

-- forward declaration of plugin vars and funcs
local SpriterObject, Folder, File, Entity, Animation, MainlineKey, Ref, Timeline, TimelineKey, BoneTimelineKey, SpriteTimelineKey

local json = require("json")

-- find by function used to navigate through spriter data
local function findBy(objects, key, value)
  if(value)then
    for index, object in pairs(objects) do
      if(object[key] == value)then
        return object
      end
    end
  end
end
