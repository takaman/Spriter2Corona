-- TODO: remove, I've put this only to space in Corona console
print(" \n \n \n ")



-- EXAMPLE OF USAGE

-- import the library
local S2C = require("source.S2C")

-- create a S2C instance passing the *.scon file path
local s2c = S2C:new("spriter.scon")

if(s2c)then
  -- find the entity by name
  local entity = s2c:findEntityByName("Character")

  if(entity)then
    -- find the animation by name
    local animation = entity:findAnimationByName("NewAnimation")

    if(animation)then
      -- default speed is 1, - is lower, + is faster
      animation.speed = 0.5

      -- play the animation
      animation:play()

      -- modify the animation DisplayObject
      local displayObj = animation.group

      displayObj.x = display.contentCenterX
      displayObj.y = display.contentCenterY
      displayObj.xScale = 0.5
      displayObj.yScale = 0.5
    end
  end
end
