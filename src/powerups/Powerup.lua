Powerup = Class {}

function Powerup:init(spawnTime)
    self.type = type
    self.inPlay = false
    self.active = false
    self.elapsed = 0
    self.spawnTimer = spawnTime
    self.width = POWERUP_W
    self.height = POWERUP_H
    self.x = math.random(VIRTUAL_WIDTH - self.width)
    self.y = math.random(VIRTUAL_HEIGHT / 3)
    self.dx = 0
    self.dy = math.random(50, 100)
end

function Powerup:update(dt)
    if self.x > VIRTUAL_WIDTH or self.x < -self.width or self.y > VIRTUAL_HEIGHT then
        self.inPlay = false
        self:reset()
    end
    if self.inPlay then
        self.elapsed = 0
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
    else
        self.elapsed = self.elapsed + dt
    end
end

function Powerup:reset()
    self.x = math.random(VIRTUAL_WIDTH - self.width)
    self.y = math.random(VIRTUAL_HEIGHT / 3)
    self.dx = 0
    self.dy = math.random(50, 100)
end

function Powerup:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], self.x, self.y)
    end
end

function Powerup:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    return true
end

function Powerup:apply(playState) end