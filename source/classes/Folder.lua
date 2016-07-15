Folder = {

  new = function(self, data)
    local folder = data

    setmetatable(folder, {__index = self})

    folder.files = {}

    for index, value in pairs(folder.file) do
      local file = File:new(value)

      table.insert(folder.files, file)
    end

    return folder
  end,

  findFileById = function(self, id)
    return findBy(self.files, "id", id)
  end

}
