local path = string.sub(..., 0, string.find(..., "%.[^%.]*$"))

local Folder = {}

local File = require(path .. "File")

function Folder:new(data)
  local folder = data
  folder.files = {}

  setmetatable(folder, {__index = self})

  for index, value in pairs(folder.file) do
    local file = File:new(value)

    table.insert(folder.files, file)
  end

  return folder
end

function Folder:findFileById(id)
  for index, file in pairs(self.files) do
    if(file.id == id)then
      return file
    end
  end
end

return Folder
