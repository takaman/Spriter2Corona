File = {

  new = function(self, data, parent, base)
    local file = data

    setmetatable(file, {__index = self})

    file.parent  = parent
    file.base    = base
    file.name    = base.path .. file.name
    file.pivot_y = (file.pivot_y - 1) * -1

    return file
  end

}
