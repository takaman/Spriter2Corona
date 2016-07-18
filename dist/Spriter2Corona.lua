-- this is the first file compiled, forward declare vars and funcs to use in plugin

-- forward declaration of plugin vars and funcs
local SpriterObject, Folder, File, Entity, Animation, MainlineKey, Ref, Timeline, TimelineKey, SpriteTimelineKey

local json = require("json")

-- find by function used to navigate through spriter data
local function findBy(objects, key, value)
  for index, object in pairs(objects) do
    if(object[key] == value)then
      return object
    end
  end
end

Animation = {

  new = function(self, data, parent, base)
    local animation = data

    setmetatable(animation, {__index = self})

    animation.parent             = parent
    animation.base               = base
    animation.currentMainlineKey = 0
    animation.speed              = 100

    if(animation.timeline)then
      animation.timelines = {}

      for index, value in pairs(animation.timeline) do
        local timeline = Timeline:new(value, animation, animation.base)

        table.insert(animation.timelines, timeline)
      end
    end

    if(animation.mainline and animation.mainline.key)then
      animation.mainlineKeys = {}

      for index, value in pairs(animation.mainline.key) do
        local previousMainlineKey = animation.mainline.key[index - 1] or animation.mainline.key[#animation.mainline.key]

        local mainlineKey = MainlineKey:new(value, animation, previousMainlineKey)

        table.insert(animation.mainlineKeys, mainlineKey)
      end
    end

    return animation
  end,

  create = function(self)
    if(not self.group and self.timelines)then
      self.group = display.newGroup()

      for index, timeline in pairs(self.timelines) do
        timeline:create()
      end
    end
  end,

  play = function(self)
    self:create()

    self:playNextMainlineKey()
  end,

  playNextMainlineKey = function()
    collectgarbage()

    self.currentMainlineKey = self.currentMainlineKey + 1

    self.mainlineKeys[self.currentMainlineKey]:play()

    local nextMainlineKey = self.mainlineKeys[self.currentMainlineKey + 1]

    if(nextMainlineKey)then
      timer.performWithDelay(nextMainlineKey.duration * self.speed / 100, function()
        self:playNextMainlineKey()
      end)
    end
  end,

  setSpeed = function(self, speed)
    if(speed)then
      speed = tonumber(speed) or 100

      self.speed = tonumber(speed)
    end
  end,

  getDisplayObject = function(self)
    return self.group
  end,

  findTimelineById = function(self, id)
    return findBy(self.timelines, "id", id)
  end

}

BoneTimelineKey = {

  new = function(self, data, parent, base, previousTimelineKey)
    local boneTimelineKey = data

    setmetatable(boneTimelineKey, {__index = self})

    boneTimelineKey.parent  = parent
    boneTimelineKey.base    = base
    boneTimelineKey.y       = (boneTimelineKey.y or 0) * -1
    boneTimelineKey.scale_x = boneTimelineKey.scale_x or 1
    boneTimelineKey.scale_y = boneTimelineKey.scale_y or 1
    boneTimelineKey.folder  = boneTimelineKey.base:findFolderById(boneTimelineKey.folder)
    boneTimelineKey.file    = boneTimelineKey.folder:findFileById(boneTimelineKey.file)
    boneTimelineKey.angle   = boneTimelineKey.angle or 0

    local clockwise = 1

    if(previousTimelineKey.spin == -1)then
      clockwise = -1
    end

    boneTimelineKey.angle = (360 - boneTimelineKey.angle) * clockwise

    return boneTimelineKey
  end

}

Entity = {

  new = function(self, data, parent)
    local entity = data

    setmetatable(entity, {__index = self})

    entity.parent     = parent
    entity.animations = {}

    for index, value in pairs(entity.animation) do
      local animation = Animation:new(value, entity, entity.parent)

      table.insert(entity.animations, animation)
    end

    return entity
  end,

  findAnimationByName = function(self, name)
    return findBy(self.animations, "name", name)
  end

}

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

MainlineKey = {

  new = function(self, data, parent, previousMainlineKey)
    local mainlineKey = data

    setmetatable(mainlineKey, {__index = self})

    mainlineKey.parent = parent
    mainlineKey.time   = mainlineKey.time or 0

    if(mainlineKey.id == 0)then
      mainlineKey.duration = mainlineKey.parent.length

    else
      mainlineKey.duration = mainlineKey.time
    end

    mainlineKey.duration = mainlineKey.duration - previousMainlineKey.time

    if(mainlineKey.object_ref)then
      mainlineKey.objectRefs = {}

      for index, value in pairs(mainlineKey.object_ref) do
        local objectRef = Ref:new(value, mainlineKey)

        table.insert(mainlineKey.objectRefs, objectRef)
      end
    end

    return mainlineKey
  end,

  play = function(self)
    collectgarbage()

    -- local mainlineKeys = self.parent.mainlineKeys
    -- local nextKey = mainlineKeys[self.parent.curKey + 1] or mainlineKeys[1]

    if(self.objectRefs)then
      for index, objectRef in pairs(self.objectRefs) do
        objectRef:play()

        -- local objRefFound = false

        -- for nextIndex, nextObjectRef in pairs(nextKey.objectRefs) do
        --   if(objectRef.timeline == nextObjectRef.timeline)then
        --     objRefFound = true
        --
        --     break
        --   end
        -- end

        -- if(objRefWillHide)then
        --   objectRef:stop()
        --
        -- else
        --   objectRef:play()
        -- end
      end
    end
  end

}

Ref = {

  new = function(self, data, parent)
    local ref = data

    setmetatable(ref, {__index = self})

    ref.parent = parent

    local timelineId = tonumber(ref.timeline)

    ref.timeline = ref.parent.parent:findTimelineById(timelineId)
    ref.timeline.zIndex = ref.z_index or 0
    ref.timeline.zIndex = ref.timeline.zIndex + 1

    ref.key = ref.timeline:findTimelineKeyById(ref.key)

    return ref
  end,

  play = function(self)
    collectgarbage()

    if(not self.timeline.playing)then
      self.timeline:play()
    end

    self.timeline:show()
  end

}

--
-- function ObjectRef:stop()
--   self.timeline:stop()
-- end

SpriteTimelineKey = {

  new = function(self, data, parent, base, previousTimelineKey)
    local spriteTimelineKey = data

    setmetatable(spriteTimelineKey, {__index = self})

    spriteTimelineKey.parent  = parent
    spriteTimelineKey.base    = base
    spriteTimelineKey.y       = (spriteTimelineKey.y or 0) * -1
    spriteTimelineKey.scale_x = spriteTimelineKey.scale_x or 1
    spriteTimelineKey.scale_y = spriteTimelineKey.scale_y or 1
    spriteTimelineKey.folder  = spriteTimelineKey.base:findFolderById(spriteTimelineKey.folder)
    spriteTimelineKey.file    = spriteTimelineKey.folder:findFileById(spriteTimelineKey.file)
    spriteTimelineKey.angle   = spriteTimelineKey.angle or 0

    local clockwise = 1

    if(previousTimelineKey.spin == -1)then
      clockwise = -1
    end

    spriteTimelineKey.angle = (360 - spriteTimelineKey.angle) * clockwise

    return spriteTimelineKey
  end

}

SpriterObject = {

  --[[
    filename is a mandatory parameter to create a instance of Spriter Object
    TODO: for now, it accept only *.scon files
  --]]
  new = function(self, filename)
    if(filename)then
      local path     = filename:sub(0, filename:find("%/[^%/]*$"))
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

  findFolderById = function(self, id)
    return findBy(self.folders, "id", id)
  end,

  findEntityByName = function(self, name)
    return findBy(self.entities, "name", name)
  end

}

Timeline = {

  new = function(self, data, parent, base)
    local timeline = data

    setmetatable(timeline, {__index = self})

    timeline.parent  = parent
    timeline.base    = base
    timeline.playing = false
    timeline.curKey  = 0

    if(timeline.key)then
      timeline.keys    = {}

      for index, value in pairs(timeline.key) do
        local previousTimelineKey = timeline.key[index - 1] or timeline.key[#timeline.key]

        local timelineKey = TimelineKey:new(value, timeline, timeline.base, previousTimelineKey)

        table.insert(timeline.keys, timelineKey)
      end
    end

    return timeline
  end,

  create = function(self)
    local timelineKey = self.keys[1]

    if(timelineKey.object)then
      self.image = display.newImage(timelineKey.object.file.name)

      self.image.base = self

      local zIndex = math.min(self.zIndex, self.parent.group.numChildren + 1)

      if(self.parent.group[zIndex])then
        for i = zIndex, 1, -1 do
          local zIndexImage = self.parent.group[i]

          if(self.zIndex > zIndexImage.base.zIndex)then
            zIndex = i + 1

            break
          end
        end
      end

      self.parent.group:insert(zIndex, self.image)
    end

    timelineKey:create()

    -- self:hide()
  end,

  play = function(self)
    collectgarbage()

    self.playing = true

    self.curKey = self.curKey + 1

    if(self.curKey > #self.keys)then
      self.curKey = 1
    end

    self.keys[self.curKey]:play()
  end,

  show = function(self)
    if(self.image)then
      self.image.isVisible = true
    end
  end,

  hide = function(self)
    if(self.image)then
      self.image.isVisible = false
    end
  end,

  getAnimationSpeed = function(self)
    return self.parent.speed
  end,

  getAnimationLength = function(self)
    return self.parent.length
  end,

  findTimelineKeyById = function(self, id)
    return findBy(self.keys, "id", id)
  end

}

TimelineKey = {

  new = function(self, data, parent, base, previousTimelineKey)
    local timelineKey = data

    setmetatable(timelineKey, {__index = self})

    timelineKey.parent = parent
    timelineKey.base   = base
    timelineKey.time   = timelineKey.time or 0
    timelineKey.spin   = timelineKey.spin or 0

    if(timelineKey.object)then
      timelineKey.object = SpriteTimelineKey:new(timelineKey.object, timelineKey, timelineKey.base, previousTimelineKey)
    end

    if(timelineKey.id == 0)then
      timelineKey.duration = timelineKey.parent:getAnimationLength()

    else
      timelineKey.duration = timelineKey.time
    end

    timelineKey.duration = timelineKey.duration - previousTimelineKey.time

    return timelineKey
  end,

  create = function(self)
    if(self.object)then
      local image = self.parent.image

      image.x = self.object.x
      image.y = self.object.y

      image.xScale = self.object.scale_x
      image.yScale = self.object.scale_y

      image.rotation = self.object.angle

      image.anchorX = self.object.file.pivot_x
      image.anchorY = self.object.file.pivot_y
    end
  end,

  play = function(self)
    collectgarbage()

    self:create()

    local timelineKeys = self.parent.keys

    local nextKey = timelineKeys[self.parent.curKey + 1] or timelineKeys[1]

    if(nextKey.id ~= self.id)then
      transition.to(self.parent.image, {
        time = nextKey.duration * self.parent:getAnimationSpeed() / 100,

        x = nextKey.object.x,
        y = nextKey.object.y,

        xScale = nextKey.object.scale_x,
        yScale = nextKey.object.scale_y,

        rotation = nextKey.object.angle,

        onComplete = function()
          self.parent:play()
        end
      })
    end
  end

}

-- this is the last file compiled in plugin, to return the main object
return SpriterObject
