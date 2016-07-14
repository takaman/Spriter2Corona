print(" \n \n \n ")

local S2C = require("S2C.S2C")

local s2c = S2C:new("spriter.scon")

if(s2c)then
  local animation = s2c.entities[1].animations[1]

  animation.speed = 2

  animation:play()

  -- TODO: remover
  animation.group.x = display.contentCenterX
  animation.group.y = display.contentCenterY
  animation.group.xScale = 0.5
  animation.group.yScale = 0.5
end
