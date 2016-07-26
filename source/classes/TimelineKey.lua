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
