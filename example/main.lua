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


-- TODO: remove, it sets the drawmode of corona to wireframe view of all objects
-- display.setDrawMode("wireframe")


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
    local animation = entity:findAnimationByName("walk")

    if(animation)then
      local speed = 100

      -- add the key event listener to test animation speed
      Runtime:addEventListener("key", function(event)
        if(event.phase == "down")then
          if(event.keyName == "up")then
            speed = speed + 10

          elseif(event.keyName == "down")then
            speed = speed - 10
          end

          animation:setSpeed(speed)

          print("[S2C Example] Animation running at " .. speed .. "%")
        end

        return false
      end)

      -- default speed is 100 (%), 50 is half slower speed
      animation:setSpeed(speed)

      -- play the animation
      animation:play()

      -- modify the animation DisplayObject
      local displayObj = animation:getDisplayObject()

      displayObj.x = display.contentCenterX
      displayObj.y = display.contentCenterY

      displayObj.xScale = 1
      displayObj.yScale = 1

      -- displayObj.anchorChildren = true
      -- displayObj.anchorX = 0.5
      -- displayObj.anchorY = 0.5
    end
  end
end
