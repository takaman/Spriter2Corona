Folder = {

  new = function(self, data, spriterObject)
    local folder = data

    setmetatable(folder, {__index = self})

    folder.spriterObject = spriterObject

    if(folder.file)then
      folder.files = {}

      for index, value in pairs(folder.file) do
        local file = File:new(value, folder.spriterObject, folder)

        table.insert(folder.files, file)

        file:normalize()
      end
    end

    return folder
  end,

  findFileById = function(self, id)
    return findBy(self.files, "id", id)
  end

}
