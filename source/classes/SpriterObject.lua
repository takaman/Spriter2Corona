SpriterObject = {

  --[[
    filename is a mandatory parameter to create a instance of Spriter Object
    TODO: for now, it accept only *.scon files
  --]]
  new = function(self, filename)
    if(filename)then
      local path = filename:sub(0, filename:find("%/[^%/]*$"))
      local filename = system.pathForFile(filename, system.ResourceDirectory)

      local data, errorPosition, errorMessage = json.decodeFile(filename)

      if(data)then
        local spriterObject = data

        setmetatable(spriterObject, {__index = self})

        spriterObject.path = path

        if(data.folder)then
          spriterObject.folders = {}

          for index, value in pairs(data.folder) do
            local folder = Folder:new(value, spriterObject)

            table.insert(spriterObject.folders, folder)
          end
        end

        if(data.entity)then
          spriterObject.entities = {}

          for index, value in pairs(data.entity) do
            local entity = Entity:new(value, spriterObject)

            table.insert(spriterObject.entities, entity)
          end
        end

        return spriterObject

      else
        print("[S2C] Decode failed at " .. tostring(errorPosition) .. ": " .. tostring(errorMessage))
      end

    else
      print("[S2C] 'Filename' is a mandatory parameter")
    end
  end,

  getPath = function(self)
    return self.path
  end,

  findFolderById = function(self, id)
    return findBy(self.folders, "id", id)
  end,

  findEntityByName = function(self, name)
    return findBy(self.entities, "name", name)
  end

}
