-- TODO: remove, I've put this only to space in Corona console
print(" \n \n \n ")



-- some lines to see better the anim
local verticalLine = display.newLine(160, 0, 160, 480)
verticalLine:setStrokeColor(1, 0, 0, 1)
verticalLine.strokeWidth = 3

local horizontalLine = display.newLine(0, 240, 320, 240)
horizontalLine:setStrokeColor(1, 0, 0, 1)
horizontalLine.strokeWidth = 3



-- TODO: remove this lines of code, get lib from root dir
local s2cPath = system.pathForFile("../dist/Spriter2Corona.lua", system.ResourceDirectory)
package.path = package.path .. ";" .. s2cPath



-- EXAMPLE OF USAGE

-- import the library
local S2C = require("Spriter2Corona")

-- create a S2C instance passing the *.scon file path
local s2c = S2C:new("GreyGuy/player.bkp.scon")

if(s2c)then
  -- find the entity by name
  local entity = s2c:findEntityByName("Player")

  if(entity)then
    -- find the animation by name
    local animation = entity:findAnimationByName("walk")

    if(animation)then
      -- default speed is 100 (%), 50 is half slower speed
      animation:setSpeed(50)

      -- create the animation
      animation:create()

      -- modify the animation DisplayObject
      local displayObj = animation:getDisplayObject()

      displayObj.x = display.contentCenterX
      displayObj.y = display.contentCenterY

      displayObj.xScale = 1
      displayObj.yScale = 1
    end
  end
end
