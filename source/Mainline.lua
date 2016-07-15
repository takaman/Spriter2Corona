local path = string.sub(..., 0, string.find(..., "%.[^%.]*$"))

local Mainline = {}

local MainlineKey = require(path .. "MainlineKey")

function Mainline:new(data, parent)
  local mainline = data
  mainline.keys = {}
  mainline.parent = parent
  mainline.curKey = 1

  setmetatable(mainline, {__index = self})

  for index, value in pairs(mainline.key) do
    local mainlineKey = MainlineKey:new(value, mainline)

    table.insert(mainline.keys, mainlineKey)

    local prevKey = mainline.key[index - 1]

    if(prevKey)then
      mainlineKey.duration = mainlineKey.time - prevKey.time

      if(prevKey.spin == -1)then
        clockwise = prevKey.spin
      end

    else
      mainlineKey.duration = mainline.parent.length - mainline.key[#mainline.key].time
    end
  end

  return mainline
end

function Mainline:play()
  self.keys[self.curKey]:play()

  local nextKey = self.keys[self.curKey + 1]

  if(nextKey)then
    self.curKey = self.curKey + 1

  else
    self.curKey = 1

    nextKey = self.keys[self.curKey]
  end

  timer.performWithDelay(nextKey.duration / self.parent.speed, function()
    self:play()
  end)
end

return Mainline
