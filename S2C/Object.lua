local Object = {}

function Object:new(data, parent)
  local object = data
  object.parent = parent

  setmetatable(object, {__index = self})

  object.folder = object.parent.parent.parent.parent.parent:findFolderById(object.folder)
  object.file = object.folder:findFileById(object.file)

  object.y = object.y * -1

  return object
end

return Object
