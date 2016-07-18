-- TODO: remove, I've put this only to space in Corona console
print(" \n \n \n ")



-- EXAMPLE OF USAGE

-- import the library
local S2C = require("dist.Spriter2Corona")

-- create a S2C instance passing the *.scon file path
local s2c = S2C:new("GreyGuy/player.scon")

if(s2c)then
  -- find the entity by name
  local entity = s2c:findEntityByName("Player")

  if(entity)then
    -- find the animation by name
    local animation = entity:findAnimationByName("walk")

    if(animation)then
      -- default speed is 100 (%)
      animation:setSpeed(50)

      -- play the animation
      animation:create()

      -- modify the animation DisplayObject
      local displayObj = animation:getDisplayObject()

      displayObj.x = display.contentCenterX
      displayObj.y = display.contentCenterY
      displayObj.xScale = 0.5
      displayObj.yScale = 0.5
    end
  end
end


--[[

SpriterObject
  - findEntityByName

  Entity
    - findAnimationByName

    Animation
      - create, play, pause, stop, setSpeed

      * MainlineKey
        * Ref

      * Timeline
        * TimelineKey
          * SpriteTimelineKey

  * Folder
    * File

]]--
