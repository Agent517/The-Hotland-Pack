local DefuseZone, super = Class(Object)

function DefuseZone:init(x, y, width, height)
    super.init(self, x, y, width, height)

    self:setHitbox(0,0,width,height)
    self.flasher = 0
    self.colliding_with = {}

    self.layer = BATTLE_LAYERS['below_battlers']

end

function DefuseZone:getDebugInfo()
    local info = super.getDebugInfo(self)
    table.insert(info, "Size: (" .. self.width .. ", " .. self.height .. ")")
    return info
end

function DefuseZone:update()
    super.update(self)
    self.colliding_with = {}
    for i, enemy in ipairs(Game.battle.enemies) do
        if self:collidesWith(enemy) and enemy.onDefuse then
            self.colliding_with[i] = enemy
            if not enemy.defused then
                enemy.color = {1,1,0}
                enemy.sprite.color = {1,1,0}
            end
        elseif not enemy.defused then
            enemy.color = {1,1,1}
            enemy.sprite.color = {1,1,1}
        end
    end
    if self.flasher > 0 then
        self.flasher = self.flasher - 1 * DTMULT
    end
    
end


function DefuseZone:defuse(target)
    self.flasher = 8 -- UT uses 16, but Kristal runs at 60FPS instead of 30.
    if self:collidesWith(target) then
        return true
    else
        return false
    end
    
end

function DefuseZone:draw()
    if #self.colliding_with > 0 then
        love.graphics.setColor(COLORS.lime)
    else
        love.graphics.setColor(COLORS.green)
    end
    --love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    if self.flasher > 0 then
        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    end
end

return DefuseZone