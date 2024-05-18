local TileGenerator, super = Class(Event)

function TileGenerator:init(data)
    super.init(self, data.x, data.y, data.width, data.height)
    self.timer = Timer()
    self:addChild(self.timer)
    self.tiles = {}
    self.tile_types = {"pink", "red", "green", "blue", "orange", "yellow", "purple"}
    self:generate(true)

end

function TileGenerator:getDebugInfo()
    local info = super.getDebugInfo(self)
    if self.x        then table.insert(info, "X: "     .. self.x)     end
    if self.y    then table.insert(info, "Y: " .. self.y) end
    if self.width    then table.insert(info, "Width: " .. self.width) end
    if self.height    then table.insert(info, "Height: " .. self.height) end
    -- if self.tiles    then table.insert(info, "Tiles: " .. self.tiles) end
    return info
end

function TileGenerator:update()
    super.update(self)
    for _,tile in pairs(self.tiles) do
        tile.layer = self.layer
    end
end

function TileGenerator:generate(silent)
    if not silent then
        Assets.playSound("bell")
    end
    for _,tile in pairs(self.tiles) do
        tile:remove()
        self.tiles = {}
        table.remove(Game.world.map.events, tile)
    end
    local parent = layer_type == "controllers" and Game.world.controller_parent or Game.world
    for width = 0, self.width - 40, 40 do
        for height = 0, self.height - 40, 40 do
            local data = {id = 10, name = "floortile", x = self.x + width, y = self.y + height, width = 40, height = 40, properties = {type = Utils.pick(self.tile_types)}}
            local floortile = Registry.createEvent("floortile", data)
            table.insert(self.tiles, floortile)
            table.insert(Game.world.map.events, floortile)
            parent:addChild(floortile)
            Game.world.map.events_by_name[data.name] = Game.world.map.events_by_name[data.name] or {}
            table.insert(Game.world.map.events_by_name[data.name], floortile)
            -- table.insert(Game.world.map.events_by_layer[self.layer.name], floortile)
        end
    end
end

function TileGenerator:activate(silent)
    if not silent then
        Assets.playSound("bell")
    end
    for _,tile in pairs(self.tiles) do
        tile:activate(true)
    end
    self.active = true
end

function TileGenerator:deactivate(silent)
    if not silent then
        Assets.playSound("noise")
    end
    for _,tile in pairs(self.tiles) do
        tile:deactivate(true)
    end
    self.active = false
end


function TileGenerator:shuffle(shuffle_amount, silent)
    if not shuffle_amount then
        shuffle_amount = 1
    end
    self.timer:script(function (wait)
        for i = 1, shuffle_amount do
            if not silent then
                Assets.playSound("noise")
            end
            for _,tile in pairs(self.tiles) do
                tile:resetEffects()
                tile:switchType(Utils.pick(self.tile_types), true)
            end
            wait(.5)
        end
    end)

end

function TileGenerator:resetEffects()
    self.solid = false
end

function TileGenerator:onEnter(player)
    if self.active and player:includes(Player) then

    end
end

return TileGenerator 