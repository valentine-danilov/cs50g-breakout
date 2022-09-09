PlayState = Class { __includes = BaseState }

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = { [1] = params.ball }
    self.level = params.level
    self.maxHealth = 3

    local hasLockedBricks = false
    for _, b in pairs(self.bricks) do
        if b.locked then
            hasLockedBricks = true
            break
        end
    end
    self.powerups = {
        [ADDITIONAL_BALLS_POWERUP] = Powerup(
            ADDITIONAL_BALLS_POWERUP,
            -- seconds
            math.random(10, 20)
        )
    }

    if hasLockedBricks then
        self.powerups[KEY_BLOCK_DESTROYER_POWERUP] = Powerup(
            KEY_BLOCK_DESTROYER_POWERUP,
            -- seconds
            math.random(10, 50)
        )
    end

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)

    -- Handle pause
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.paddle:update(dt)

    -- handle balls paddle and bricks collisions
    for key, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
        for k, brick in pairs(self.bricks) do
            if brick.inPlay and ball:collides(brick) then
                local hitScore = brick:hit(self.powerups)
                self.score = self.score + hitScore

                if self.score > self.recoverPoints then
                    self.health = math.min(self.maxHealth, self.health + 1)
                    if self.health > 1 then
                        self.paddle.size = 2
                    end
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)
                    gSounds['recover']:play()
                end

                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                if ball.x + 2 < brick.x and ball.dx > 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                elseif ball.y < brick.y then
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                else
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                break
            end
        end

        -- handle ball out of game
        if ball.y >= VIRTUAL_HEIGHT then

            if #self.balls > 1 then
                table.remove(self.balls, key)
            else
                self.health = self.health - 1
                if self.health == 1 then
                    self.paddle.size = 1
                end
                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
        end
    end

    -- handle powerup spawn and collisions
    for _, powerup in pairs(self.powerups) do
        if powerup.elapsed >= powerup.spawnTimer then
            powerup.inPlay = true
            powerup.elased = 0
        end
        if powerup.inPlay and powerup:collides(self.paddle) then
            if powerup.type == ADDITIONAL_BALLS_POWERUP then
                for i = 0, 1 do
                    local ball = Ball(math.random(7))
                    ball.x = self.paddle.x + (self.paddle.width / 2) - 16
                    ball.y = self.paddle.y - 16
                    ball.dx = math.random(-200, 200)
                    ball.dy = math.random(-60, -70)
                    table.insert(self.balls, ball)
                end
            else
                powerup.active = true
            end
            powerup.inPlay = false
            powerup:reset()
        end
    end

    self:updateEach(self.balls, dt)
    self:updateEach(self.bricks, dt)
    self:updateEach(self.powerups, dt)

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    self.paddle:render()
    self:renderEach(self.bricks)
    self:renderEach(self.balls)
    self:renderEach(self.powerups)
    table.forEach(self.bricks, function(k, v) v:renderParticles() end)

    renderActivePowerups(self.powerups)
    renderScore(self.score)
    renderHealth(self.health)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end

function PlayState:renderEach(renderables)
    table.forEach(renderables, function(k, v) v:render() end)
end

function PlayState:updateEach(updatables, dt)
    table.forEach(updatables, function(k, v) v:update(dt) end)
end
