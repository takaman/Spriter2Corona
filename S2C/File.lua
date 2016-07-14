local File = {}

function File:new(data)
  local file = data

  setmetatable(file, {__index = self})

  file.pivot_y = (file.pivot_y - 1) * -1

  return file
end

return File
