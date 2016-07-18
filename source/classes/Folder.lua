Folder = {

  new = function(self, data, parent)
    local folder = data

    setmetatable(folder, {__index = self})

    folder.parent = parent

    if(folder.file)then
      folder.files = {}

      for index, value in pairs(folder.file) do
        local file = File:new(value, folder, folder.parent)

        table.insert(folder.files, file)
      end
    end

    return folder
  end,

  findFileById = function(self, id)
    return findBy(self.files, "id", id)
  end

}
