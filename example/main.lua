-- TODO: remove, I've put this only to space in Corona console
print(" \n \n \n ")

-- TODO: remove this line of code, get lib from root dir
local s2cPath = system.pathForFile("../dist/Spriter2Corona.lua", system.ResourceDirectory)
package.path = package.path .. ";" .. s2cPath



-- EXAMPLE OF USAGE

-- import the library
local S2C = require("Spriter2Corona")

-- create a S2C instance passing the *.scon file path
local s2c = S2C:new("GreyGuy/player.scon")

if(s2c)then
  -- find the entity by name
  local entity = s2c:findEntityByName("Player")

  if(entity)then
    -- find the animation by name
    local animation = entity:findAnimationByName("walk_000")

    if(animation)then
      -- default speed is 100 (%), 50 is half slower speed
      animation:setSpeed(50)

      -- play the animation
      animation:create()

      -- modify the animation DisplayObject
      local displayObj = animation:getDisplayObject()

      displayObj.x = display.contentCenterX
      displayObj.y = display.contentCenterY
      displayObj.anchorChildren = true
      displayObj.anchorX = 0.5
      displayObj.anchorY = 0.5
    end
  end
end
