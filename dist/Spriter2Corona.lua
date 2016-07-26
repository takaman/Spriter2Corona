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
        local timeline = Timeline:new(value, spriterObject, animation)

        table.insert(animation.timelines, timeline)
      end
    end

    if(animation.mainline and animation.mainline.key)then
      animation.mainlineKeys = {}

      for index, value in pairs(animation.mainline.key) do
        local mainlineKey = MainlineKey:new(value, animation)

        table.insert(animation.mainlineKeys, mainlineKey)
      end
    end

    return animation
  end,

  normalize = function(self)
    self.currentMainlineKey = 0
    self.speed              = 100

    for index, mainlineKey in pairs(self.mainlineKeys) do
      mainlineKey:normalize()
    end

    for index, timeline in pairs(self.timelines) do
      timeline:normalize()
    end
  end,

  create = function(self)
    if(not self.displayObject and self.mainlineKeys)then
      self.displayObject = display.newGroup()

      self.displayObject.animation = self

      self.mainlineKeys[1]:create()
    end
  end,

  play = function(self)
    self:create()

    self:playNextMainlineKey()
  end,

  playNextMainlineKey = function(self)
    -- TODO: make the initial delay when first mainlineKey is not on time zero

    self.currentMainlineKey = self.currentMainlineKey + 1

    self.mainlineKeys[self.currentMainlineKey]:play()

    local nextMainlineKey = self.mainlineKeys[self.currentMainlineKey + 1]

    if(nextMainlineKey)then
      timer.performWithDelay(nextMainlineKey.duration * 100 / self.speed, function()
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

  getLastMainlineKey = function(self)
    return self.mainlineKeys[#self.mainlineKeys]
  end,

  getDisplayObject = function(self)
    return self.displayObject
  end,

  findMainlineKeyById = function(self, id)
    return findBy(self.mainlineKeys, "id", id)
  end,

  findTimelineById = function(self, id)
    return findBy(self.timelines, "id", tonumber(id))
  end

}

BoneTimelineKey = {

  new = function(self, data, timelineKey)
    local boneTimelineKey = data

    setmetatable(boneTimelineKey, {__index = self})

    boneTimelineKey.timelineKey   = timelineKey

    boneTimelineKey.x = boneTimelineKey.x or 0
    boneTimelineKey.y = - (boneTimelineKey.y or 0)

    boneTimelineKey.scale_x = boneTimelineKey.scale_x or 1
    boneTimelineKey.scale_y = boneTimelineKey.scale_y or 1

    boneTimelineKey.xScale = boneTimelineKey.scale_x
    boneTimelineKey.yScale = boneTimelineKey.scale_y

    return boneTimelineKey
  end,

  normalize = function(self)
    self.x, self.y, self.scale_x, self.scale_y = self:getParameters()

    self.angle = - self.angle

    -- self.angle = 360 - self:getRotation()
  end,

  getRotation = function(self)
    local angle = self.angle

    local ref = self.timelineKey.ref
    local parentRef = ref.parent

    if(parentRef)then
      local parentTimeline = parentRef.timeline
      local parentTimelineKey = parentTimeline:findTimelineKeyById(self.id) or parentTimeline:getLastTimelineKey()

      local parentAngle = parentTimelineKey.bone:getRotation()

      angle = angle + parentAngle
    end

    return angle
  end,

  getParameters = function(self)
    local x = self.x
    local y = self.y

    local xScale = self.xScale
    local yScale = self.yScale

    local ref = self.timelineKey.ref
    local parentRef = ref.parent

    if(parentRef)then
      local parentTimeline = parentRef.timeline
      local parentTimelineKey = parentTimeline:findTimelineKeyById(self.id) or parentTimeline:getLastTimelineKey()

      local parentX, parentY, parentXScale, parentYScale = parentTimelineKey.bone:getParameters()

      x = x * parentXScale
      y = y * parentYScale

      xScale = xScale * parentXScale
      yScale = yScale * parentYScale
    end

    return x, y, xScale, yScale
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
        local animation = Animation:new(value, spriterObject, entity)

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
    self.name = self.spriterObject.path .. self.name

    self.pivot_y = (self.pivot_y - 1) * -1
  end,

}

Folder = {

  new = function(self, data, spriterObject)
    local folder = data

    setmetatable(folder, {__index = self})

    folder.spriterObject = spriterObject

    if(folder.file)then
      folder.files = {}

      for index, value in pairs(folder.file) do
        local file = File:new(value, spriterObject, folder)

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
    self.time = self.time or 0

    -- TODO: check if this duration is right
    local previousMainlineKey = self.animation:findMainlineKeyById(self.id - 1) or self.animation:getLastMainlineKey()

    if(self.time == 0)then
      self.duration = self.animation.length - previousMainlineKey.time

    else
      self.duration = self.time - previousMainlineKey.time
    end

    for key, boneRef in pairs(self.boneRefs) do
      boneRef:normalize()
    end

    for key, objectRef in pairs(self.objectRefs) do
      objectRef:normalize()
    end
  end,

  create = function(self)
    for key, objectRef in pairs(self.objectRefs) do
      objectRef:create()
    end
  end,

  play = function(self)
    for key, boneRef in pairs(self.boneRefs) do
      boneRef:play()
    end

    for key, objectRef in pairs(self.objectRefs) do
      objectRef:play()
    end
  end,

  findBoneRefById = function(self, id)
    return findBy(self.boneRefs, "id", id)
  end

}




-- local mainlineKeys = self.parent.mainlineKeys
-- local nextKey = mainlineKeys[self.parent.curKey + 1] or mainlineKeys[1]

-- if(self.objectRefs)then
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
-- end

Ref = {

  new = function(self, data, mainlineKey)
    local ref = data

    setmetatable(ref, {__index = self})

    ref.mainlineKey = mainlineKey

    return ref
  end,

  normalize = function(self)
    self.timeline = self.mainlineKey.animation:findTimelineById(self.timeline)
    self.key      = self.timeline:findTimelineKeyById(self.key)
    self.parent   = self.mainlineKey:findBoneRefById(self.parent)

    if(self.z_index)then
      self.z_index = self.z_index + 1
    end

    if(self.parent)then
      self.parent:setRef(self)
    end

    self.key:setRef(self)
  end,

  create = function(self, zIndex)
    local displayObject = self.mainlineKey.animation:getDisplayObject()

    zIndex = zIndex or self.z_index

    if(self.parent)then
      self.parent:create(zIndex)

      displayObject = self.parent.timeline:getLastDisplayObject()
    end

    self.key:create(displayObject, zIndex)
  end,

  play = function(self)
    if(not self.timeline.playing)then
      self.timeline:play()
    end
  end,

  setRef = function(self, ref)
    self.ref = ref
  end

}

SpriteTimelineKey = {

  new = function(self, data, spriterObject, timelineKey)
    local spriteTimelineKey = data

    setmetatable(spriteTimelineKey, {__index = self})

    spriteTimelineKey.spriterObject = spriterObject
    spriteTimelineKey.timelineKey   = timelineKey

    spriteTimelineKey.x = spriteTimelineKey.x or 0
    spriteTimelineKey.y = - (spriteTimelineKey.y or 0)

    spriteTimelineKey.scale_x = spriteTimelineKey.scale_x or 1
    spriteTimelineKey.scale_y = spriteTimelineKey.scale_y or 1

    spriteTimelineKey.xScale = spriteTimelineKey.scale_x
    spriteTimelineKey.yScale = spriteTimelineKey.scale_y

    return spriteTimelineKey
  end,

  normalize = function(self)
    self.folder = self.spriterObject:findFolderById(self.folder)
    self.file   = self.folder:findFileById(self.file)

    self.x, self.y, self.scale_x, self.scale_y = self:getParameters()

    if(self.timelineKey.spin == 1)then
      self.angle = self.angle - 360
    end

    self.angle = - self.angle

    -- self.angle = 360 - self:getRotation()
  end,

  getRotation = function(self)
    local angle = self.angle

    local ref = self.timelineKey.ref
    local parentRef = ref.parent

    if(parentRef)then
      local parentTimeline = parentRef.timeline
      local parentTimelineKey = parentTimeline:findTimelineKeyById(self.id) or parentTimeline:getLastTimelineKey()

      local parentAngle = parentTimelineKey.bone:getRotation()

      angle = angle + parentAngle
    end

    return angle
  end,

  getParameters = function(self)
    local x = self.x
    local y = self.y

    local xScale = self.xScale
    local yScale = self.yScale

    local ref = self.timelineKey.ref
    local parentRef = ref.parent

    if(parentRef)then
      local parentTimeline = parentRef.timeline
      local parentTimelineKey = parentTimeline:findTimelineKeyById(self.id) or parentTimeline:getLastTimelineKey()

      local parentX, parentY, parentXScale, parentYScale = parentTimelineKey.bone:getParameters()

      x = x * parentXScale
      y = y * parentYScale

      xScale = xScale * parentXScale
      yScale = yScale * parentYScale
    end

    return x, y, xScale, yScale
  end

}

SpriterObject = {

  -- TODO: for now, it accept only *.scon files
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
        local timelineKey = TimelineKey:new(value, spriterObject, timeline)

        table.insert(timeline.keys, timelineKey)
      end
    end

    return timeline
  end,

  normalize = function(self)
    self.playing        = false
    self.currentKey     = 0
    self.displayObjects = {}

    if(self.keys)then
      for key, timelineKey in pairs(self.keys) do
        timelineKey:normalize()
      end
    end
  end,

  create = function(self, timelineKeyId, parentDisplayObject, zIndex)
    local timelineKey = self:findTimelineKeyById(timelineKeyId)

    local displayObject

    -- TODO: test if this breaks the zIndex
    zIndex = math.min(zIndex, parentDisplayObject.numChildren + 1)

    if(timelineKey.bone)then
      displayObject = display.newGroup()

      parentDisplayObject:insert(zIndex, displayObject)

    else
      displayObject = display.newImage(timelineKey.object.file.name)

      parentDisplayObject:insert(zIndex, displayObject)
    end

    displayObject.timeline = self

    table.insert(self.displayObjects, displayObject)

      -- if(timelineKey.bone)then
      --   self.displayObject = display.newGroup()
      --
      -- else
      --   self.displayObject = display.newImage(timelineKey.object.file.name)
      -- end
      --
      -- self.displayObject.timeline = self
      --
      -- local parentDisplayObject = self.animation.displayObject
      --
      -- local zIndex = timelineKey.ref.z_index

      -- if(timelineKey.ref.ref)then
      --   zIndex = timelineKey.ref.ref.z_index:getZIndex()
      -- end

        -- TODO: check if is possible to move zIndex to object props

        -- ZINDEX recursivo, pegando o maior dos parent, e depois o resto, rs

        -- for i = parentDisplayObject.numChildren, 1, -1 do
        --   local parentChildrenDisplayObject = parentDisplayObject[i]
        --
        --   local parentZIndex = parentChildrenDisplayObject.timeline:findTimelineKeyById(0).ref:getZIndex()
        --
        --   if(not parentZIndex)then
        --     parentZIndex = parentChildrenDisplayObject.timeline:findTimelineKeyById(0).ref.ref:getZIndex()
        --   end
        --
        --   if(parentZIndex > zIndex)then
        --     zIndex = i
        --
        --     break
        --   end
        -- end

        -- zIndex = math.min(zIndex, parentDisplayObject.numChildren + 1)
        --
        -- parentDisplayObject:insert(zIndex, self.displayObject)
        --
        -- timelineKey:create()

        -- self:hide()
  end,

  play = function(self)
    self.playing = true

    self:playNextTimelineKey()
  end,

  playNextTimelineKey = function(self)
    self.currentKey = self.currentKey + 1

    if(self.currentKey > #self.keys)then
      self.currentKey = 1
    end

    self.keys[self.currentKey]:play()
  end,

  getLastDisplayObject = function(self)
    return self.displayObjects[#self.displayObjects]
  end,

  getLastTimelineKey = function(self)
    return self.keys[#self.keys]
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
      timelineKey.bone = BoneTimelineKey:new(timelineKey.bone, timelineKey)
    end

    if(timelineKey.object)then
      timelineKey.object = SpriteTimelineKey:new(timelineKey.object, spriterObject, timelineKey)
    end

    return timelineKey
  end,

  normalize = function(self)
    self.time = self.time or 0

    local previousTimelineKey = self.timeline:findTimelineKeyById(self.id - 1) or self.timeline:getLastTimelineKey()

    if(self.time == 0)then
      self.duration = self.timeline.animation.length - previousTimelineKey.time

    else
      self.duration = self.time - previousTimelineKey.time
    end

    self.spin = self.spin or 1

    if(self.bone)then
      self.bone:normalize()
    end

    if(self.object)then
      self.object:normalize()
    end
  end,

  create = function(self, displayObject, zIndex)
    self.timeline:create(self.id, displayObject, zIndex)

    local displayObject = self.timeline:getLastDisplayObject()

    local parameters = self.object or self.bone

    displayObject.x = parameters.x
    displayObject.y = parameters.y

    displayObject.rotation = parameters.angle

    if(self.object)then
      displayObject.xScale = parameters.scale_x
      displayObject.yScale = parameters.scale_y

      displayObject.anchorX = self.object.file.pivot_x
      displayObject.anchorY = self.object.file.pivot_y
    end
  end,

  play = function(self)
    -- TODO: implement the way of start the animation by setting the current key params

    local nextKey = self.timeline:findTimelineKeyById(self.id + 1) or self.timeline:findTimelineKeyById(0)

    local nextParameters = nextKey.bone or nextKey.object

    local xScale = 1
    local yScale = 1

    if(self.object)then
      xScale = nextParameters.scale_x
      yScale = nextParameters.scale_y
    end

    if(nextKey.id ~= self.id)then
      local numChildren = 1

      for key, displayObject in pairs(self.timeline.displayObjects) do
        local parameters = self.object or self.bone

        displayObject.x = parameters.x
        displayObject.y = parameters.y

        displayObject.rotation = parameters.angle

        if(self.object)then
          displayObject.xScale = parameters.scale_x
          displayObject.yScale = parameters.scale_y
        end

        if(not displayObject.playing)then
          displayObject.playing = true

          displayObject.transition = transition.to(displayObject, {
            time = nextKey.duration * 100 / self.timeline.animation.speed,

            rotation = nextParameters.angle,

            x = nextParameters.x,
            y = nextParameters.y,

            xScale = xScale,
            yScale = yScale,

            onComplete = function()
              displayObject.playing = false

              if(numChildren < #self.timeline.displayObjects)then
                numChildren = numChildren + 1

              else
                self.timeline:playNextTimelineKey()
              end
            end
          })
        end
      end
    end
  end,

  setRef = function(self, ref)
    self.ref = ref
  end

}

-- this is the last file compiled in plugin, to return the main object
return SpriterObject
