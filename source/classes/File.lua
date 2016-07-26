File = {

  new = function(self, data, spriterObject, folder)
    local file = data

    setmetatable(file, {__index = self})

    file.spriterObject = spriterObject
    file.folder        = folder

    return file
  end,

  normalize = function(self)
    self.name = self.spriterObject.path .. self.name

    self.pivot_y = (self.pivot_y - 1) * -1
  end,

}
