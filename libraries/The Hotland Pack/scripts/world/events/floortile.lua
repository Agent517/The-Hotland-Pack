local FloorTile, super = Class(Event)

function FloorTile:init(data)
    super.init(self, data.x, data.y, data.width, data.height)
    self.type = data.properties["type"] or "pink"
    self.active = data.properties["active"] or true
    self.movespeed = .3


    -- Do not modify these - stuff for collision checks
    self.electrified = false
    self.shocking = false
    self.upblocked = false
    self.rightblocked = false
    self.leftblocked = false
    self.downblocked = false
    self.hitbox = Hitbox(self, .2, .2, self.width*.8, self.height*.8)
    self.checkerhitbox = Hitbox(self, self.width/3, -8, self.width/2, self.height*1.4)
    self.checkerhitbox2 = Hitbox(self, -8, self.height/3, self.width*1.4, self.height/2)
    self.topcircle = CircleCollider(self, self.width/2, self.height/2 - 40, 10)
    self.downcircle = CircleCollider(self, self.width/2, self.height/2 + 40, 10)
    self.rightcircle = CircleCollider(self, self.width/2 + 40, self.height/2, 10)
    self.leftcircle = CircleCollider(self, self.width/2 - 40, self.height/2, 10)
    self.collider = self.hitbox

    if self.type == "red" then
        self.solid = true
    end

        
    self.timer = Timer()
    self:addChild(self.timer)

    self.timer:every(1, function ()
        Object.startCache()
        if self.type == "yellow" and self.active then
            for _,tile in ipairs(Game.world:getEvents("floortile")) do
                if tile:collidesWith(self.checkerhitbox) or tile:collidesWith(self.checkerhitbox2) then
                    tile.electrified = true
                end
            end
        elseif self.type == "purple" and self.active then
            for _,tile in ipairs(Game.world:getEvents("floortile")) do
                if tile:collidesWith(self.topcircle) then
                    if tile.type == "red" then
                        self.upblocked = true
                    else
                        self.upblocked = false
                    end
                elseif tile:collidesWith(self.downcircle) then
                    if tile.type == "red" then
                        self.downblocked = true
                    else
                        self.downblocked = false
                    end
                elseif tile:collidesWith(self.rightcircle) then
                    if tile.type == "red" then
                        self.rightblocked = true
                    else
                        self.rightblocked = false
                    end
                elseif tile:collidesWith(self.leftcircle) then
                    if tile.type == "red" then
                        self.leftblocked = true
                    else
                        self.leftblocked = false
                    end
                end
            end
            for _,other in ipairs(Game.world:getCollision()) do
                if self.topcircle:collidesWith(other) then
                    self.upblocked = true
                elseif self.downcircle:collidesWith(other) then
                    self.downblocked = true
                elseif self.rightcircle:collidesWith(other) then
                    self.rightblocked = true
                elseif self.leftcircle:collidesWith(other) then
                    self.leftblocked = true
                end
            end
        end
        Object.endCache()
    end)
end

function FloorTile:getDebugInfo()
    local info = super.getDebugInfo(self)
    if self.x        then table.insert(info, "X: "     .. self.x)     end
    if self.y    then table.insert(info, "Y: " .. self.y) end
    if self.width    then table.insert(info, "Width: " .. self.width) end
    if self.height    then table.insert(info, "Height: " .. self.height) end
    return info
end

function FloorTile:activate(silent)
    if not silent then
        Assets.playSound("bell")
    end
    
    if self.type == "red" then
        self.solid = true
    end
    self.active = true
end

function FloorTile:deactivate(silent)
    if not silent then
        Assets.playSound("noise")
    end
    self:resetEffects()
    self.active = false
end


function FloorTile:switchType(type, silent)
    self:resetEffects()
    if not silent then
        Assets.playSound("noise")
    end
    if type == "pink" then
        self.type = type
    elseif type == "red" then
        self.type = type
        self.solid = true
    elseif type == "green" then
        self.type = type
    elseif type == "blue" then
        self.type = type
    elseif type == "orange" then
        self.type = type
    elseif type == "yellow" then
        self.type = type
    elseif type == "purple" then
        self.type = type
    else
        print("Invalid tile type")
    end
end

function FloorTile:resetEffects()
    self.solid = false
    self.electrified = false
    if self.shocking == true then
        self.shocking = false
        if self.shocksprite then
            self.shocksprite:remove()
        end
    end
    -- if self.fx then
    --     player:removeFX(self.fx)
    -- end
end

function FloorTile:onEnter(player)
    local function pirhana()
        local pirhanasprite = Sprite("tiles/blue/pirhana")
        Game.world:addChild(pirhanasprite)
        pirhanasprite:setLayer(Game.world:parseLayer("objects"))
        pirhanasprite:setPosition(self.x + self.width/6, self.y + self.height/6)
        pirhanasprite:setScale(2, 2)
        pirhanasprite:play(1/30, false, function ()
            pirhanasprite:remove()
        end)
        if player.facing == "up" then
            player.facing = "down"
            player.sprite.facing = player.facing
            player:slideTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) + 40, self.movespeed, nil, function ()
                Game.lock_movement = false
            end)
        elseif player.facing == "down" then
            player.facing = "up"
            player.sprite.facing = player.facing
            player:slideTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) - 40, self.movespeed, nil, function ()
                Game.lock_movement = false
            end)
        elseif player.facing == "right" then
            player.facing = "left"
            player.sprite.facing = player.facing
            player:slideTo((self.x + self.width/2) - 40, self.y + (self.height/2 + self.height/6), self.movespeed, nil, function ()
                Game.lock_movement = false
            end)
        elseif player.facing == "left" then
            player.facing = "right"
            player.sprite.facing = player.facing
            player:slideTo((self.x + self.width/2) + 40, self.y + (self.height/2 + self.height/6), self.movespeed, nil, function ()
                Game.lock_movement = false
            end)
        end
    end

    local function shock()
        self.shocking = true
        if self.type == "yellow" then
            self.timer:script(function (wait)
                self.shocksprite = Sprite("tiles/yellow/shock")
                self:addChild(self.shocksprite)
                self.shocksprite:setPosition(-6, -6)
                self.shocksprite:setScale(2, 2)
                self.shocksprite:play(1/15, false)
                wait(.2)
                if Game:isLight() then
                    self.world:hurtParty(1)
                else
                    self.world:hurtParty(15)
                end
                if player.facing == "up" then
                    player.facing = "down"
                    player.sprite.facing = player.facing
                    player:slideTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) + 40, self.movespeed, nil, function ()
                        Game.lock_movement = false
                        self.shocking = false
                        self.shocksprite:remove()
                    end)
                elseif player.facing == "down" then
                    player.facing = "up"
                    player.sprite.facing = player.facing
                    player:slideTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) - 40, self.movespeed, nil, function ()
                        Game.lock_movement = false
                        self.shocking = false
                        self.shocksprite:remove()
                    end)
                elseif player.facing == "right" then
                    player.facing = "left"
                    player.sprite.facing = player.facing
                    player:slideTo((self.x + self.width/2) - 40, self.y + (self.height/2 + self.height/6), self.movespeed, nil, function ()
                        Game.lock_movement = false
                        self.shocking = false
                        self.shocksprite:remove()
                    end)
                elseif player.facing == "left" then
                    player.facing = "right"
                    player.sprite.facing = player.facing
                    player:slideTo((self.x + self.width/2) + 40, self.y + (self.height/2 + self.height/6), self.movespeed, nil, function ()
                        Game.lock_movement = false
                        self.shocking = false
                        self.shocksprite:remove()
                    end)
                end
            end)
        elseif self.type == "blue" then
            self.timer:script(function (wait)
                self.shocksprite = Sprite("tiles/blue/shock_blue")
                self:addChild(self.shocksprite)
                self.shocksprite:setPosition(-6, -6)
                self.shocksprite:setScale(2, 2)
                self.shocksprite:play(1/15, false)
                wait(.2)
                if Game:isLight() then
                    self.world:hurtParty(1)
                else
                    self.world:hurtParty(15)
                end
                if player.facing == "up" then
                    player.facing = "down"
                    player.sprite.facing = player.facing
                    player:slideTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) + 40, self.movespeed, nil, function ()
                        Game.lock_movement = false
                        self.shocking = false
                        self.shocksprite:remove()
                    end)
                elseif player.facing == "down" then
                    player.facing = "up"
                    player.sprite.facing = player.facing
                    player:slideTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) - 40, self.movespeed, nil, function ()
                        Game.lock_movement = false
                        self.shocking = false
                        self.shocksprite:remove()
                    end)
                elseif player.facing == "right" then
                    player.facing = "left"
                    player.sprite.facing = player.facing
                    player:slideTo((self.x + self.width/2) - 40, self.y + (self.height/2 + self.height/6), self.movespeed, nil, function ()
                        Game.lock_movement = false
                        self.shocking = false
                        self.shocksprite:remove()
                    end)
                elseif player.facing == "left" then
                    player.facing = "right"
                    player.sprite.facing = player.facing
                    player:slideTo((self.x + self.width/2) + 40, self.y + (self.height/2 + self.height/6), self.movespeed, nil, function ()
                        Game.lock_movement = false
                        self.shocking = false
                        self.shocksprite:remove()
                    end)
                end
            end)
        end
    end
    if self.active and player:includes(Player) then
        if self.type ~= "red" then
            Game.lock_movement = true
            player:walkTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6), self.movespeed, nil, nil, nil, function ()
                Game.lock_movement = false
                -- local flashfx = FlashFX(self.x, self.y, self.width, self.height)
                -- Game.world:addChild(flashfx)
                -- flashfx:setLayer(self.layer)
                if self.type == "green" then
                    local flashfx = FlashFX(self.x, self.y, self.width, self.height)
                    Game.world:addChild(flashfx)
                    flashfx:setLayer(self.layer)

                    Assets.playSound("bell")
                    Game.world:spawnBullet("spear", self.x + self.width/2, self.y)
                    -- Game.lock_movement = true
                    -- Game.world.player:alert(nil, {callback=function()
                    --     Game.lock_movement = false
                    --     Game:encounterLight("froggit", true, nil, nil)
                    -- end})
                elseif self.type == "blue" then
                    if self.electrified then
                        Assets.playSound("snd_shock")
                        Game.lock_movement = true
                        shock()
                    else
                        if player.flavor == "orange" then
                            Assets.playSound("alert")
                            pirhana()
                        else
                            Assets.playSound("snd_splash")
                        end
                    end
                elseif self.type == "purple" then
                    local flashfx = FlashFX(self.x, self.y, self.width, self.height)
                    Game.world:addChild(flashfx)
                    flashfx:setLayer(self.layer)
                    Assets.playSound("bell")
                    Game.lock_movement = true
                    player.flavor = "lemon"
                    player.actor.flavor = player.flavor
                    -- self.fx = player:addFX(AlphaFX)
                    if player.facing == "up" then
                        local arrowsprite = Sprite("tiles/purple/arrowup")
                        Game.world:addChild(arrowsprite)
                        arrowsprite:setLayer(Game.world:parseLayer("objects"))
                        -- arrowsprite:setLayer(self.layer)
                        arrowsprite:setPosition(self.x + self.width/6, self.y + self.height/6)
                        arrowsprite:setScale(2, 2)
                        arrowsprite:fadeOutAndRemove()
                        if not self.upblocked then
                            player:walkTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) - 40, self.movespeed, nil, nil, nil, function ()
                                Game.lock_movement = false
                            end)
                        else
                            Game.lock_movement = false
                        end
                    elseif player.facing == "down" then
                        local arrowsprite = Sprite("tiles/purple/arrowdown")
                        Game.world:addChild(arrowsprite)
                        arrowsprite:setLayer(Game.world:parseLayer("objects"))
                        arrowsprite:setPosition(self.x + self.width/6, self.y + self.height/6)
                        arrowsprite:setScale(2, 2)
                        arrowsprite:fadeOutAndRemove()
                        if not self.downblocked then
                            player:walkTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) + 40, self.movespeed, nil, nil, nil, function ()
                                Game.lock_movement = false
                            end)
                        else
                            Game.lock_movement = false
                        end
                    elseif player.facing == "right" then
                        local arrowsprite = Sprite("tiles/purple/arrowright")
                        Game.world:addChild(arrowsprite)
                        arrowsprite:setLayer(Game.world:parseLayer("objects"))
                        arrowsprite:setPosition(self.x + self.width/6, self.y + self.height/6)
                        arrowsprite:setScale(2, 2)
                        arrowsprite:fadeOutAndRemove()
                        if not self.rightblocked then
                            player:walkTo((self.x + self.width/2) + 40, self.y + (self.height/2 + self.height/6), self.movespeed, nil, nil, nil, function ()
                                Game.lock_movement = false
                            end)
                        else
                            Game.lock_movement = false
                        end
                    elseif player.facing == "left" then
                        local arrowsprite = Sprite("tiles/purple/arrowleft")
                        Game.world:addChild(arrowsprite)
                        arrowsprite:setLayer(Game.world:parseLayer("objects"))
                        arrowsprite:setPosition(self.x + self.width/6, self.y + self.height/6)
                        arrowsprite:setScale(2, 2)
                        arrowsprite:fadeOutAndRemove()
                        if not self.leftblocked then
                            player:walkTo((self.x + self.width/2) - 40, self.y + (self.height/2 + self.height/6), self.movespeed, nil, nil, nil, function ()
                                Game.lock_movement = false
                            end)
                        else
                            Game.lock_movement = false
                        end
                    end
                elseif self.type == "yellow" then
                    Assets.playSound("snd_shock")
                    Game.lock_movement = true
                    shock()
                    -- if player.facing == "up" then
                    --     player.facing = "down"
                    --     player.sprite.facing = player.facing
                    --     player:slideTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) + 40, .3, nil, nil, nil, function ()
                    --         Game.lock_movement = false
                    --         player:setFacing("down")
                    --     end)
                    -- elseif player.facing == "down" then
                    --     player:slideTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6) - 40, .3, nil, function ()
                    --         Game.lock_movement = false
                    --     end)
                    -- elseif player.facing == "right" then
                    --     player:slideTo((self.x + self.width/2) - 40, self.y + (self.height/2 + self.height/6), .3, nil, function ()
                    --         Game.lock_movement = false
                    --     end)
                    -- elseif player.facing == "left" then
                    --     player:slideTo((self.x + self.width/2) + 40, self.y + (self.height/2 + self.height/6), .3, nil, function ()
                    --         Game.lock_movement = false
                    --     end)
                    -- end
                elseif self.type == "orange" then
                    Assets.playSound("bell")
                    player.flavor = "orange"
                    player.actor.flavor = player.flavor
                end
            end)
        end


        -- if self.type == "green" then
        --     Assets.playSound("bell")

        --     Game.world:spawnBullet("spear", self.x + self.width/2, self.y)

        --     -- Game.lock_movement = true
        --     -- player:walkTo(self.x + self.width/2, self.y + (self.height/2 + self.height/6), .3, nil, nil, nil, function ()
        --     --     Game.world.player:alert(nil, {callback=function()
        --     --         Game.lock_movement = false
        --     --         Game:encounterLight("froggit", true, nil, nil)
        --     --     end})
        --     -- end)
        -- end
    end

end

function FloorTile:onExit(player)
    if player:includes(Player) then
        if self.shocking == true then
            self.shocking = false
            if self.shocksprite then
                self.shocksprite:remove()
            end
        end
        -- if self.fx then
        --     player:removeFX(self.fx)
        -- end
    end
end

function FloorTile:update()
    super.update(self)
    -- Object.startCache()
    -- if self.type == "yellow" and self.active then
    --     for _,tile in ipairs(Game.world:getEvents("floortile")) do
    --         if tile:collidesWith(self.checkerhitbox) or tile:collidesWith(self.checkerhitbox2) then
    --             tile.electrified = true
    --         end
    --     end
    -- elseif self.type == "purple" and self.active then
    --     for _,tile in ipairs(Game.world:getEvents("floortile")) do
    --         if tile:collidesWith(self.topcircle) then
    --             if tile.type == "red" then
    --                 self.upblocked = true
    --             else
    --                 self.upblocked = false
    --             end
    --         elseif tile:collidesWith(self.downcircle) then
    --             if tile.type == "red" then
    --                 self.downblocked = true
    --             else
    --                 self.downblocked = false
    --             end
    --         elseif tile:collidesWith(self.rightcircle) then
    --             if tile.type == "red" then
    --                 self.rightblocked = true
    --             else
    --                 self.rightblocked = false
    --             end
    --         elseif tile:collidesWith(self.leftcircle) then
    --             if tile.type == "red" then
    --                 self.leftblocked = true
    --             else
    --                 self.leftblocked = false
    --             end
    --         end
    --     end
    --     for _,other in ipairs(Game.world:getCollision()) do
    --         if self.topcircle:collidesWith(other) then
    --             self.upblocked = true
    --         elseif self.downcircle:collidesWith(other) then
    --             self.downblocked = true
    --         elseif self.rightcircle:collidesWith(other) then
    --             self.rightblocked = true
    --         elseif self.leftcircle:collidesWith(other) then
    --             self.leftblocked = true
    --         end
    --     end
    -- end
    -- Object.endCache()
end

function FloorTile:draw()
    super.draw(self)
    if self.active then
        if self.type == "pink" then
            love.graphics.setColor(1, 0.749, 0.753, 1)
            love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        elseif self.type == "red" then
            love.graphics.setColor(1, 0.251, 0.255, 1)
            love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        elseif self.type == "green" then
            love.graphics.setColor(0.616, 1, 0.475, 1)
            love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        elseif self.type == "blue" then
            if self.shocking == false then
                love.graphics.setColor(0.251, 0.251, 1)
                love.graphics.rectangle("fill", 0, 0, self.width, self.height)
            end
        elseif self.type == "orange" then
            love.graphics.setColor(1, 0.757, 0.286)
            love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        elseif self.type == "yellow" then
            if self.shocking == false then
                love.graphics.setColor(1, 1, 0.498)
                love.graphics.rectangle("fill", 0, 0, self.width, self.height)
            end
        elseif self.type == "purple" then
            love.graphics.setColor(0.757, 0, 0.753)
            love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        end

        -- blue 0.251, 0.251, 1
        -- orange 1, 0.757, 0.286
        -- yellow 1, 1, 0.498
        -- purple 0.757, 0, 0.753
    else
        love.graphics.setColor(0.41083, 0.41083, 0.41083, 1)
        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    end

    if DEBUG_RENDER and self.checkerhitbox and self.checkerhitbox2 and self.topcircle and self.downcircle and self.rightcircle and self.leftcircle then
        self.checkerhitbox:draw(1, 0, 0)
        self.checkerhitbox2:draw(0, 1, 0)
        self.topcircle:draw(0, 0, 1)
        self.downcircle:draw(0, 1, 0)
        self.rightcircle:draw(1, 0, 0)
        self.leftcircle:draw(1, 0, 1)
    end
end

return FloorTile 