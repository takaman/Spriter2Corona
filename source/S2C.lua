local path = string.sub(..., 0, string.find(..., "%.[^%.]*$"))

local S2C = {}

local json = require("json")
local Folder = require(path .. "Folder")
local Entity = require(path .. "Entity")

function S2C:new(filename)
  local filename = system.pathForFile(filename, system.ResourceDirectory)
  local data, errPos, errMsg = json.decodeFile(filename)

  if(data)then
    local s2c = data
    s2c.folders = {}
    s2c.entities = {}

    setmetatable(s2c, {__index = self})

    for index, value in pairs(data.folder) do
      local folder = Folder:new(value)

      table.insert(s2c.folders, folder)
    end

    for index, value in pairs(data.entity) do
      local entity = Entity:new(value, s2c)

      table.insert(s2c.entities, entity)
    end

    return s2c

  else
    print("[S2C] Decode failed at " .. tostring(errPos) .. ": " .. tostring(errMsg))
  end
end

function S2C:findFolderById(id)
  for index, folder in pairs(self.folders) do
    if(folder.id == id)then
      return folder
    end
  end
end

function S2C:findEntityByName(name)
  for index, entity in pairs(self.entities) do
    if(entity.name == name)then
      return entity
    end
  end
end

return S2C
