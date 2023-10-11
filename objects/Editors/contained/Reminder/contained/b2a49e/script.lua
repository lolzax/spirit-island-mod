-- The height/width of UI panel to be the same size as the object
local objSize = 200

-- Gets the object (spirit or power card) beneath the reminder token
function getObject()
    local hits = Physics.cast({
        origin = self.getBounds().center,
        direction = Vector(0,-1,0),
        max_distance = 2,
    })
    for _,v in pairs(hits) do
        local obj = v.hit_object
        if obj.hasTag("Spirit") or obj.type == "Card" then
            return obj
        end
    end
    return nil
end

-- Gets a set of parameters for image location suitable to be saved to script state
-- These are agnostic of the actual image on the object, and of the mask size
function getImageLocation(params)
    local obj = params.obj
    if obj == nil then
        return nil
    end

    local location = {}

    if obj.type == "Card" then
        location.field = "FaceURL"
    elseif obj.is_face_down then
        location.field = "ImageSecondaryURL"
    else
        location.field = "ImageURL"
    end

    local selfPos = self.getPosition()
    local objPos = obj.getPosition()
    local selfBounds = self.getBounds()
    local objBounds = obj.getBounds()
    local selfSize = selfBounds.size.x -- We're not quite square, so only use our width

    location.width = objBounds.size.x / selfSize * objSize
    location.height = objBounds.size.z / selfSize * objSize

    location.x = (objPos.x - selfPos.x) / objBounds.size.x * location.width
    location.y = (objPos.z - selfPos.z) / objBounds.size.z * location.height

    return location
end

-- Sets this object's position and size above a given object such that getImageLocation() would return a given location.
-- We can't do this with takeObject(), as that can't set size.
-- So we might as well do this here, so that the code sits next to getImageLocation().
function setToLocation(params)
    local obj = params.obj
    if obj == nil then
        return
    end

    local location = params.location
    if location == nil then
        location = getDefaultLocation({obj = obj})
    end
    if location == nil then
        return
    end

    local objPos = obj.getPosition()
    local selfBounds = self.getBounds()
    local objBounds = obj.getBounds()
    local selfSize = selfBounds.size.x

    local desiredX = objPos.x - location.x * objBounds.size.x / location.width
    local desiredZ = objPos.z - location.y * objBounds.size.z / location.height
    local desiredY = objPos.y + 1
    self.setPosition(Vector(desiredX, desiredY, desiredZ))

    local desiredSize = objBounds.size.x * objSize / location.width
    self.setScale(self.getScale():scale(desiredSize / selfSize))
end

-- TODO: Shunt getDefaultLocation(), getField() and getImageAttributes() up to global so they can be used there.

function getDefaultLocation(params)
    local obj = params.obj
    if obj == nil then
        return nil
    end

    if obj.type == "Card" then
        return {
            field = "FaceURL",
            x = -0.17 * objSize,
            y = -0.45 * objSize,
            width = 1.85 * objSize,
            height = 2.59 * objSize,
        }
    elseif obj.hasTag("Spirit") then
        return {
            field = "ImageSecondaryURL",
            x = 0.63 * objSize,
            y = -0.23 * objSize,
            width = 2.40 * objSize,
            height = 1.60 * objSize,
        }
    else
        return nil
    end
end

function getField(obj, field)
    local data = obj.getData()
    if obj.type == "Card" then
        if data.CustomDeck then
            for _,d in pairs(data.CustomDeck) do
                if d.NumWidth == 1 and d.NumHeight == 1 then
                    return d[field]
                end
            end
        end
        return ""
    else
        return data.CustomImage[field]
    end
end

-- Gets the image attributes to be set in the UI
function getImageAttributes(params)
    local obj = params.obj
    if obj == nil then
        return {image = ""}
    end

    local location = params.location
    if location == nil then
        location = getDefaultLocation({obj = obj})
    end

    return {
        image = getField(obj, location.field),
        position = tostring(location.x).." "..tostring(location.y).." 0",
        width = tostring(location.width),
        height = tostring(location.height),
    }
end

function updateImage()
    local obj = getObject()
    local location = getImageLocation({obj = obj})
    local attributes = getImageAttributes({obj = obj, location = location})
    self.UI.setAttributes("image", attributes)
end

function onLoad()
    Wait.time(updateImage, 0.1, -1)
end
