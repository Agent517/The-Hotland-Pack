local bullet, super = Class(WorldBullet)

function bullet:init(x, y)
    super:init(self, x, y, "bullets/spear/spear")
    self.layer = Game.world.map.object_layer
    self.timer = Timer()
    self:addChild(self.timer)
    self.collidable = false
    self.damage = (Game:isLight() and 3) or 24
    self.battle_fade = false

    self:setScale(2, 2)
    -- self:setOrigin(.5, .5)
    self:setHitbox(0, 10, 20, 20)

    Assets.playSound("snd_spearappear")

    self.timer:after(.5, function ()
        Assets.playSound("snd_spearrise")
        self:setSprite("bullets/spear/spearrise")
        self.sprite:play(1/18, false)
    end)

    self.timer:after(.6, function ()
        self.collidable = true
    end)

    self.timer:after(1, function ()
        self.collidable = false
        self:fadeOutSpeedAndRemove(0.1)
    end)
end

function bullet:onCollide(soul)
    if soul.inv_timer == 0 then
        self:onDamage(soul)
    end
end

function bullet:update()
    super.update(self)
    self.layer = Game.world.map.object_layer
end

function bullet:draw()
    super:draw(self)

    if DEBUG_RENDER and self.collider then
        if self.collidable then
            self.collider:draw(0, 1, 0)
        else
            self.collider:draw(1, 0, 0)
        end
    end
end


return bullet