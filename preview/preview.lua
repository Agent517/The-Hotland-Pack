local preview = {}

-- whether to fade out the default background
preview.hide_background = false

function preview:init(mod, button)
    self.mod_id = mod.id
    self.base_path = mod.path.."/preview"

    local function p(f) return self.base_path .. "/" .. f end
    -- code here gets called when the mods are loaded
    button:setColor((194/255), (26/255), (1/255))
    button:setFavoritedColor((249/255), (74/255), (28/255))
    self.sign = love.graphics.newImage(p("bg_2.png"))
end

function preview:draw()
    -- code here gets drawn to the background every frame!!
    -- make sure to check  self.fade  or  self.selected  here
    if self.fade > 0 then
        local alpha = 1 * self.fade
        love.graphics.setColor(1,1,1, alpha)
        love.graphics.draw(self.sign,SCREEN_WIDTH/4, SCREEN_HEIGHT/4)
    end
end

return preview