local Dummy, super = Class(LightEnemyBattler)

function Dummy:init()
    super:init(self)

    -- Enemy name
    self.name = "Dummy Bomb"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("dummy_ut")

    -- Enemy health
    self.max_health = 100
    self.health = 100
    -- Enemy attack (determines bullet damage)
    self.attack = 5
    -- Enemy defense (usually 0)
    self.defense = 0
    -- Enemy reward
    self.money = 69
    self.experience = 1
    
    self.dialogue_bubble = "ut_large"

    -- Mercy given when sparing this enemy before its spareable (20% for basic enemies)
    self.spare_points = 0

    -- Whether the enemy runs/slides away when defeated/spared
    self.exit_on_defeat = false
    self.can_freeze = false
    self.can_die = false

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        -- "basic",
        -- "aiming",
        -- "movingarena"
    }

    self.menu_waves = {
        -- "aiming"
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
        "[wave:3][speed:0.5]Tick... ",
        "[wave:3][speed:0.5]Tock... "
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "Despite the name,\nthis one is not a dud."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* The bomb is still active!",
    }
    -- Text displayed at the bottom of the screen when the enemy has low health
    self.low_health_text = "* The dummy looks like it's\nabout to fall over."

    self:registerAct("Defuse Bomb", "", "all")
    -- Aim for\ndefuse\nzone!

    -- Hitbox used for bomb purposes
    self:setHitbox(0,0,self.width,self.height)
    
    self.siner = 0

    -- can be a table or a number. if it's a number, it determines the width, and the height will be 13 (the ut default).
    -- if it's a table, the first value is the width, and the second is the height
    self.gauge_size = 150

    self.damage_offset = {5, -70}
end

function Dummy:update()
    super.update(self)
    -- Once the battle has properly started, this enemy will move left and right in a sine motion.
    if Game.battle.state ~= "TRANSITION" and Game.battle.state ~= "INTRO" and not self.defused and not self.lock_movement then
        if not self.start_x then
            self.start_x = self.x
            self.start_y = self.y
        end
        self.siner = self.siner + DT
        self.x = self.start_x + math.sin(self.siner*2) * 120
    end
end

function Dummy:onAct(battler, name)
    if name == "Defuse Bomb" then
        local result
        for i, defuser in ipairs(Game.world.stage:getObjects(LightDefuseZone)) do
            result = defuser:defuse(self)
            if result == true then break end
        end
        self:onDefuse(result)
        if result == true then
            Assets.playSound("break2")
            return "[noskip]* Bomb defused![wait:1s]"
        else
            Assets.playSound("break1")
            return "* Defuse failed![wait:5]\n* Aim for DEFUSE ZONE!"
        end
    elseif name == "Standard" then --X-Action
        return "* "..battler.chara:getName().." tried something.[wait:10] Nothing happened."
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super.onAct(self, battler, name)
end

function Dummy:onDefuse(success)
    if success then
        self.defused = true
        --self:lightStatusMessage("msg", "defuse")
        self.color = COLORS.lime
        self.sprite.color = {0,1,0}
        Game.battle.timer:after(0.5, function ()
            self:spare()
        end)
    else
        self:lightStatusMessage("msg", "miss", Game.battle.multi_mode and {Game.battle.party[1].chara:getLightMissColor()} or {192/255, 192/255, 192/255})
    end
end

function Dummy:hurt(amount, battler, on_defeat, color, anim, attacked)
    self.show_hp = false

    if attacked ~= false then
        attacked = true
    end
    local message
    if amount <= 0 then
        if not self.display_damage_on_miss or not attacked then
            message = self:lightStatusMessage("msg", "miss", color or (battler and {battler.chara:getLightMissColor()}))
        else
            message = self:lightStatusMessage("damage", 0, color or (battler and {battler.chara:getLightDamageColor()}))
        end
        if message and (anim and anim ~= nil) then
            message:resetPhysics()
        end
        if attacked then
            self.hurt_timer = 1
        end

        self:onDodge(battler, attacked)
        return
    end

    -- Don't take damage
    --message = self:lightStatusMessage("damage", amount, color or (battler and {battler.chara:getLightDamageColor()}))
    if message and (anim and anim ~= nil) then
        message:resetPhysics()
    end
    --self.health = self.health - amount

    self.hurt_timer = 1
    self:onHurt(amount, battler)

    self:checkHealth(on_defeat, amount, battler)

    self.show_hp = true

end

function Dummy:spare(pacify)
    self.exit_on_defeat = true
    super.spare(self, pacify)
    Game.battle.timer:after(0.5, function ()
        Game.battle.timer:tween(0.5, self, {alpha = 0})
    end)

    
end

return Dummy