---@class FlashFX : Object
---@overload fun(...) : FlashFX
local FlashFX, super = Class(Object)

function FlashFX:init(x, y, w, h)
    super.init(self, x, y, w, h)
    self.alpha = 1
end

function FlashFX:update()
    super.update(self)
    self.alpha = self.alpha - .05

    if self.alpha <= 0 then
        self:remove()
    end
end

function FlashFX:draw()
    super.draw(self)
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
end

return FlashFX