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

    animation.parent       = parent
    animation.base         = base
    animation.curKey       = 0
    animation.timelines    = {}
    animation.mainlineKeys = {}

    animation:setSpeed(1)

    for index, value in pairs(animation.timeline) do
      local timeline = Timeline:new(value, animation, animation.base)

      table.insert(animation.timelines, timeline)
    end

    local mainlineKeys = animation.mainline.key

    for index, value in pairs(mainlineKeys) do
      local previousMainlineKey = mainlineKeys[index - 1] or mainlineKeys[#mainlineKeys]

      local mainlineKey = MainlineKey:new(value, animation, previousMainlineKey)

      table.insert(animation.mainlineKeys, mainlineKey)
    end

    return animation
  end,

  findTimelineById = function(self, id)
    return findBy(self.timelines, "id", id)
  end,

  setSpeed = function(self, speed)
    self.speed = tonumber(speed)
  end,

  getDisplayObject = function(self)
    return self.group
  end,

  play = function(self)
    collectgarbage()

    self:create()

    -- TODO: make the starting delay if first mainlineKey is not on time 0

    self.curKey = self.curKey + 1

    self.mainlineKeys[self.curKey]:play()

    local nextMainlineKey = self.mainlineKeys[self.curKey + 1]

    if(not nextMainlineKey)then
      nextMainlineKey = self.mainlineKeys[1]

      self.curKey = 0
    end

    timer.performWithDelay(nextMainlineKey.duration / self.speed, function()
      self:play()
    end)
  end,

  create = function(self)
    if(not self.group)then
      self.group = display.newGroup()

      for index, timeline in pairs(self.timelines) do
        timeline:create()
      end
    end
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

  new = function(self, data)
    local file = data

    setmetatable(file, {__index = self})

    file.pivot_y = (file.pivot_y - 1) * -1

    return file
  end

}

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

MainlineKey = {

  new = function(self, data, parent, previousMainlineKey)
    local mainlineKey = data

    setmetatable(mainlineKey, {__index = self})

    mainlineKey.parent     = parent
    mainlineKey.time       = mainlineKey.time or 0

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

  new = function(self, data, parent, base, previousSpriteTimelineKey)
    local spriteTimelineKey = data

    setmetatable(spriteTimelineKey, {__index = self})

    spriteTimelineKey.parent  = parent
    spriteTimelineKey.base    = base
    spriteTimelineKey.y       = spriteTimelineKey.y * -1
    spriteTimelineKey.scale_x = spriteTimelineKey.scale_x or 1
    spriteTimelineKey.scale_y = spriteTimelineKey.scale_y or 1
    spriteTimelineKey.folder  = spriteTimelineKey.base:findFolderById(spriteTimelineKey.folder)
    spriteTimelineKey.file    = spriteTimelineKey.folder:findFileById(spriteTimelineKey.file)
    spriteTimelineKey.angle   = spriteTimelineKey.angle or 0

    local clockwise = - 1

    if(previousSpriteTimelineKey.spin == -1)then
      clockwise = 1
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
      local filename = system.pathForFile(filename, system.ResourceDirectory)
      local data, errorPosition, errorMessage = json.decodeFile(filename)

      if(data)then
        local spriterObject = data

        setmetatable(spriterObject, {__index = self})

        spriterObject.folders  = {}
        spriterObject.entities = {}

        for index, value in pairs(data.folder) do
          local folder = Folder:new(value)

          table.insert(spriterObject.folders, folder)
        end

        for index, value in pairs(data.entity) do
          local entity = Entity:new(value, spriterObject)

          table.insert(spriterObject.entities, entity)
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
    timeline.keys    = {}

    for index, value in pairs(timeline.key) do
      local previousTimelineKey = timeline.key[index - 1] or timeline.key[#timeline.key]

      local timelineKey = TimelineKey:new(value, timeline, timeline.base, previousTimelineKey)

      table.insert(timeline.keys, timelineKey)
    end

    return timeline
  end,

  findTimelineKeyById = function(self, id)
    for index, timelineKey in pairs(self.keys) do
      if(timelineKey.id == id)then
        return timelineKey
      end
    end
  end,

  create = function(self)
    local timelineKey = self.keys[1]

    self.image = display.newImage(self.parent.group, timelineKey.object.file.name)

    timelineKey:create()

    self:hide()
  end,

  show = function(self)
    self.image.isVisible = true
  end,

  hide = function(self)
    self.image.isVisible = false
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

  getAnimationSpeed = function(self)
    return self.parent.speed
  end,

  getAnimationLength = function(self)
    return self.parent.length
  end

}

-- function Timeline:stop()
--   self.keys[self.curKey]:stop()
-- end

TimelineKey = {

  new = function(self, data, parent, base, previousTimelineKey)
    local timelineKey = data

    setmetatable(timelineKey, {__index = self})

    timelineKey.parent = parent
    timelineKey.base   = base
    timelineKey.time   = timelineKey.time or 0
    timelineKey.spin   = timelineKey.spin or 0

    if(timelineKey.object)then
      timelineKey.object = SpriteTimelineKey:new(timelineKey.object, timelineKey, timelineKey.base, previousTimelineKey.object)
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

    self.transition = transition.to(self.parent.image, {
      time = nextKey.duration / self.parent:getAnimationSpeed(),

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

}

-- function TimelineKey:stop()
--   transition.cancel(self.transition)
--
-- --  self.transition:pause()
-- end

-- this is the last file compiled in plugin, to return the main object
return SpriterObject
