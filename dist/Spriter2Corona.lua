-- this is the first file compiled, forward declare vars and funcs to use in plugin

-- forward declaration of plugin vars and funcs
local SpriterObject, Folder, File, Entity, Animation, MainlineKey, Ref, Timeline, TimelineKey, BoneTimelineKey, SpriteTimelineKey

local json = require("json")

-- find by function used to navigate through spriter data
local function findBy(objects, key, value)
  if(value)then
    for index, object in pairs(objects) do
      if(object[key] == value)then
        return object
      end
    end
  end
end

Animation = {

  new = function(self, data, spriterObject, entity)
    local animation = data

    setmetatable(animation, {__index = self})

    animation.spriterObject = spriterObject
    animation.entity        = entity

    if(animation.timeline)then
      animation.timelines = {}

      for index, value in pairs(animation.timeline) do
        local timeline = Timeline:new(value, animation.spriterObject, animation)

        table.insert(animation.timelines, timeline)
      end
    end

    if(animation.mainline and animation.mainline.key)then
      animation.mainlineKeys = {}

      for index, value in pairs(animation.mainline.key) do
        local mainlineKey = MainlineKey:new(value, animation)

        table.insert(animation.mainlineKeys, mainlineKey)

        mainlineKey:normalize()
      end
    end

    return animation
  end,

  normalize = function(self)
    self.currentMainlineKey = 0
    self.speed              = 100

    if(self.timelines)then
      for index, timeline in pairs(self.timelines) do
        timeline:normalize()
      end
    end
  end,

  create = function(self)
    if(not self.group and self.timelines)then
      self.group = display.newGroup()

      self.group.animation = self

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

  getLength = function(self)
    return self.length
  end,

  getLastMainlineKey = function(self)
    return self.mainlineKeys[#self.mainlineKeys]
  end,

  getDisplayObject = function(self)
    return self.group
  end,

  findMainlineKeyById = function(self, id)
    return findBy(self.mainlineKeys, "id", id)
  end,

  findTimelineById = function(self, id)
    return findBy(self.timelines, "id", tonumber(id))
  end

}

BoneTimelineKey = {

  new = function(self, data, spriterObject, timelineKey)
    local boneTimelineKey = data

    setmetatable(boneTimelineKey, {__index = self})

    boneTimelineKey.spriterObject = spriterObject
    boneTimelineKey.timelineKey   = timelineKey

    return boneTimelineKey
  end,

  normalize = function(self)
    self.x = self.x or 0
    self.y = - (self.y or 0)

    self.scale_x = self.scale_x or 1
    self.scale_y = self.scale_y or 1

    local timeline = self.timelineKey:getTimeline()

    local previousTimelineKey = timeline:findTimelineKeyById(self.timelineKey:getId() - 1) or timeline:getLastTimelineKey()

    self.angle = - self.angle
  end

}

Entity = {

  new = function(self, data, spriterObject)
    local entity = data

    setmetatable(entity, {__index = self})

    entity.spriterObject = spriterObject

    if(entity.animation)then
      entity.animations = {}

      for index, value in pairs(entity.animation) do
        local animation = Animation:new(value, entity.spriterObject, entity)

        table.insert(entity.animations, animation)

        animation:normalize()
      end
    end

    return entity
  end,

  findAnimationByName = function(self, name)
    return findBy(self.animations, "name", name)
  end

}

File = {

  new = function(self, data, spriterObject, folder)
    local file = data

    setmetatable(file, {__index = self})

    file.spriterObject = spriterObject
    file.folder        = folder

    return file
  end,

  normalize = function(self)
    self.name = self.spriterObject:getPath() .. self.name

    self.pivot_y = (self.pivot_y - 1) * -1
  end,

  getName = function(self)
    return self.name
  end

}

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

MainlineKey = {

  new = function(self, data, animation)
    local mainlineKey = data

    setmetatable(mainlineKey, {__index = self})

    mainlineKey.animation = animation

    if(mainlineKey.bone_ref)then
      mainlineKey.boneRefs = {}

      for index, value in pairs(mainlineKey.bone_ref) do
        local boneRef = Ref:new(value, mainlineKey)

        table.insert(mainlineKey.boneRefs, boneRef)
      end
    end

    if(mainlineKey.object_ref)then
      mainlineKey.objectRefs = {}

      for index, value in pairs(mainlineKey.object_ref) do
        local objectRef = Ref:new(value, mainlineKey)

        table.insert(mainlineKey.objectRefs, objectRef)
      end
    end

    return mainlineKey
  end,

  normalize = function(self)
    self.time = self.time or self.animation:getLength()

    local previousMainlineKey = self.animation:findMainlineKeyById(self.id - 1) or self.animation:getLastMainlineKey()

    self.duration = self.time - previousMainlineKey.time

    if(self.boneRefs)then
      for key, boneRef in pairs(self.boneRefs) do
        boneRef:normalize()
      end

      for key, objectRef in pairs(self.objectRefs) do
        objectRef:normalize()
      end
    end
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
  end,

  getAnimation = function(self)
    return self.animation
  end,

  findBoneRefById = function(self, id)
    return findBy(self.boneRefs, "id", id)
  end

}

Ref = {

  new = function(self, data, mainlineKey)
    local ref = data

    setmetatable(ref, {__index = self})

    ref.mainlineKey = mainlineKey

    return ref
  end,

  normalize = function(self)
    if(self.z_index)then
      self.z_index = self.z_index + 1
    end

    local animation = self.mainlineKey:getAnimation()

    self.timeline = animation:findTimelineById(self.timeline)

    self.key = self.timeline:findTimelineKeyById(self.key)

    if(self.parent)then
      self.parent = self.mainlineKey:findBoneRefById(self.parent)

      self.parent:setRef(self)

      self.key:setParent(self.parent)
    end

    self.key:setRef(self)
  end,

  play = function(self)
    collectgarbage()

    if(not self.timeline:isPlaying())then
      self.timeline:play()
    end

    self.timeline:show()
  end,

  setRef = function(self, ref)
    self.ref = ref
  end,

  getRef = function(self)
    return self.ref
  end,

  getZIndex = function(self)
    return self.z_index
  end,

  getTimeline = function(self)
    return self.timeline
  end,

  getParent = function(self)
    return self.parent
  end

}

--
-- function ObjectRef:stop()
--   self.timeline:stop()
-- end

SpriteTimelineKey = {

  new = function(self, data, spriterObject, timelineKey)
    local spriteTimelineKey = data

    setmetatable(spriteTimelineKey, {__index = self})

    spriteTimelineKey.spriterObject = spriterObject
    spriteTimelineKey.timelineKey   = timelineKey

    return spriteTimelineKey
  end,

  normalize = function(self)
    self.x = self.x or 0
    self.y = - (self.y or 0)

    self.scale_x = self.scale_x or 1
    self.scale_y = self.scale_y or 1

    self.folder = self.spriterObject:findFolderById(self.folder)
    self.file   = self.folder:findFileById(self.file)

    local timeline = self.timelineKey:getTimeline()

    local previousTimelineKey = timeline:findTimelineKeyById(self.timelineKey:getId() - 1) or timeline:getLastTimelineKey()

    self.angle = - self.angle
  end,

  getFile = function(self)
    return self.file
  end

}

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

Timeline = {

  new = function(self, data, spriterObject, animation)
    local timeline = data

    setmetatable(timeline, {__index = self})

    timeline.spriterObject = spriterObject
    timeline.animation     = animation

    if(timeline.key)then
      timeline.keys = {}

      for index, value in pairs(timeline.key) do
        local timelineKey = TimelineKey:new(value, timeline.spriterObject, timeline)

        table.insert(timeline.keys, timelineKey)
      end
    end

    return timeline
  end,

  normalize = function(self)
    self.playing = false
    self.curKey  = 0

    if(self.keys)then
      for key, timelineKey in pairs(self.keys) do
        timelineKey:normalize()
      end
    end
  end,

  create = function(self)
    if(not self.displayObject)then
      local timelineKey = self.keys[1]

      if(timelineKey.bone)then
        self.displayObject = display.newGroup()

      else
        self.displayObject = display.newImage(timelineKey.object:getFile():getName())
      end

      self.displayObject.timeline = self

      local parentDisplayObject = self.animation:getDisplayObject()

      if(timelineKey.parent)then
        local parentTimeline = timelineKey.parent:getTimeline()

        parentTimeline:create()

        parentDisplayObject = parentTimeline:getDisplayObject()
      end

      local zIndex = timelineKey.ref:getZIndex() or parentDisplayObject.numChildren + 1

      if(timelineKey.bone)then
        zIndex = timelineKey.ref.ref:getZIndex()
      end

      -- TODO: check if is possible to move zIndex to object props

      for i = parentDisplayObject.numChildren, 1, -1 do
        local parentChildrenDisplayObject = parentDisplayObject[i]

        local parentZIndex = parentChildrenDisplayObject.timeline.keys[1].ref:getZIndex()

        if(not parentZIndex)then
          parentZIndex = parentChildrenDisplayObject.timeline.keys[1].ref.ref:getZIndex()
        end

        if(parentZIndex > zIndex)then
          zIndex = i

          break
        end
      end

      zIndex = math.min(zIndex, parentDisplayObject.numChildren + 1)

      parentDisplayObject:insert(zIndex, self.displayObject)

      timelineKey:create()

      -- self:hide()
    end
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
    self.displayObject.isVisible = true
  end,

  hide = function(self)
    self.displayObject.isVisible = false
  end,

  getAnimation = function(self)
    return self.animation
  end,

  getLastTimelineKey = function(self)
    return self.keys[#self.keys]
  end,

  getDisplayObject = function(self)
    return self.displayObject
  end,

  isPlaying = function(self)
    return self.playing
  end,

  findTimelineKeyById = function(self, id)
    return findBy(self.keys, "id", id)
  end

}

TimelineKey = {

  new = function(self, data, spriterObject, timeline)
    local timelineKey = data

    setmetatable(timelineKey, {__index = self})

    timelineKey.spriterObject = spriterObject
    timelineKey.timeline      = timeline

    if(timelineKey.bone)then
      timelineKey.bone = BoneTimelineKey:new(timelineKey.bone, timelineKey.spriterObject, timelineKey)
    end

    if(timelineKey.object)then
      timelineKey.object = SpriteTimelineKey:new(timelineKey.object, timelineKey.spriterObject, timelineKey)
    end

    return timelineKey
  end,

  normalize = function(self)
    self.time = self.time or self.timeline:getAnimation():getLength()

    local previousTimelineKey = self.timeline:findTimelineKeyById(self.id - 1) or self.timeline:getLastTimelineKey()

    self.duration = self.time - previousTimelineKey.time

    self.spin = self.spin or 1

    if(self.spin == 0)then
      self.spin = 1
    end

    if(self.bone)then
      self.bone:normalize()
    end

    if(self.object)then
      self.object:normalize()
    end
  end,

  create = function(self)
    local displayObject = self.timeline:getDisplayObject()

    local parameters = self.object or self.bone

    displayObject.rotation = parameters.angle

    local x = parameters.x
    local y = parameters.y

    local xScale = parameters.scale_x
    local yScale = parameters.scale_y

    if(self.object)then
      displayObject.anchorX = self.object:getFile().pivot_x
      displayObject.anchorY = self.object:getFile().pivot_y
    end

    local ref = self:getRef()

    if(ref)then
      local parentRef = ref:getParent()

      while ref and parentRef do
        local parentTimeline = parentRef:getTimeline()

        xScale = xScale * parentTimeline.keys[1].bone.scale_x
        yScale = yScale * parentTimeline.keys[1].bone.scale_y

        x = x * parentTimeline.keys[1].bone.scale_x
        y = y * parentTimeline.keys[1].bone.scale_y

        ref = parentTimeline.keys[1]:getRef()
        parentRef = ref:getParent()
      end
    end

    if(self.object)then
      displayObject.xScale = xScale
      displayObject.yScale = yScale
    end

    displayObject.x = x
    displayObject.y = y
  end,

  play = function(self)
    -- collectgarbage()
    --
    -- self:create()
    --
    -- local timelineKeys = self.timeline.keys
    --
    -- local nextKey = timelineKeys[self.timeline.curKey + 1] or timelineKeys[1]
    --
    -- if(nextKey.id ~= self.id)then
    --   transition.to(self.timeline.image, {
    --     time = nextKey.duration * self.timeline:getAnimationSpeed() / 100,
    --
    --     x = nextKey.object.x,
    --     y = nextKey.object.y,
    --
    --     xScale = nextKey.object.scale_x,
    --     yScale = nextKey.object.scale_y,
    --
    --     rotation = nextKey.object.angle,
    --
    --     onComplete = function()
    --       self.timeline:play()
    --     end
    --   })
    -- end
  end,

  setRef = function(self, ref)
    self.ref = ref
  end,

  setParent = function(self, parent)
    self.parent = parent
  end,

  getId = function(self)
    return self.id
  end,

  getTimeline = function(self)
    return self.timeline
  end,

  getRef = function(self, ref)
    return self.ref
  end

}

-- this is the last file compiled in plugin, to return the main object
return SpriterObject
