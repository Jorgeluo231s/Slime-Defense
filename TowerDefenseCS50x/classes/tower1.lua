local tower = {}
tower.__index = tower

function tower:new(world,x,y)
    local instance = setmetatable({},tower)
    instance.x = x
    instance.y = y
    instance.collider = world:newRectangleCollider(instance.x,instance.y,128,128)
    instance.collider:setFixedRotation(true)
    instance.inRange = 280
    instance.cooldown = 0.3
    instance.fireTimer = 0
    instance.killCount = 0
    instance.towerImage = love.graphics.newImage('sprites/tower1.png')
    instance.projectile = {}
    instance.projectile.x = x+64
    instance.projectile.y = y+64
    instance.projectile.collider = world:newCircleCollider(instance.x+64,instance.y+64,15)
    instance.projectile.collider:setSensor(true)
    instance.projectile.damage = 34
    instance.projectile.speed = 550
    instance.projectile.angle = 0
    instance.projectile.image = love.graphics.newImage('sprites/arrow1.png')
    instance.projectile.width =instance.projectile.image:getWidth()
    instance.projectile.height = instance.projectile.image:getHeight()
    instance.projectile.isFlying = false
    instance.projectile.target = nil

    return instance
end


function tower:update(dt,allEnemies,player)
    --checks if the projectile isFlying , if it has finished  reset, else keep going and moving the collider
    if self.projectile.isFlying then
        local target = self.projectile.target
        if (not target) or (target.isFinished) or (target:isAlive()) == false then -- if flighttime is done then restart with is flying false, and setting the setPosition to the initial x,y
            if target then
                target.isTargeted = false
            end

            local newTarget = self:closestEnemy(allEnemies,self.inRange)
            if newTarget then 
                self.projectile.target = newTarget
                newTarget.isTargeted = true
            else
                self.projectile.isFlying = false
                self.projectile.target = nil
                self.projectile.collider:setLinearVelocity(0,0)
                self.projectile.collider:setPosition(self.x+64,self.y+64)
                return
            end
        end
        target = self.projectile.target
        local px,py = self.projectile.collider:getPosition()
        local tx,ty = target:getPosition()
        local dx = tx -px
        local dy = ty - py
        local distance = math.sqrt(dx*dx+dy*dy)
        local arrivalThreshold = 15
        if distance < arrivalThreshold then
            target:takeDamage(self.projectile.damage,player)
            target.isTargeted = false
            self.projectile.isFlying = false
            self.projectile.target = nil
            self.projectile.collider:setLinearVelocity(0,0)
            self.projectile.collider:setPosition(self.x+64,self.y+64)
            return
        else
            self.projectile.angle = math.atan2(dy,dx)
            local normX = dx/distance
            local normY = dy/distance
            local vx = normX *self.projectile.speed
            local vy = normY *self.projectile.speed
            self.projectile.collider:setLinearVelocity(vx,vy)
            self.projectile.x = px
            self.projectile.y = py
        end
        return
    end

    self.fireTimer = self.fireTimer -dt
    if self.fireTimer > 0 then
        return
    end

    local target = self:closestEnemy(allEnemies,self.inRange)
    if target then
        target.isTargeted = true
        self.fireTimer = self.cooldown --resets and makes the firetimer have the 1s closestDist
        self.projectile.target = target
        self.projectile.isFlying = true
        self.projectile.collider:setPosition(self.x + 64, self.y + 64)

        local tx, ty = target:getPosition()
        local dx = tx - (self.x + 64)
        local dy = ty - (self.y + 64)
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 0 then
            local vx = (dx/dist) * self.projectile.speed
            local vy = (dy/dist) * self.projectile.speed
            self.projectile.collider:setLinearVelocity(vx,vy)
        end
    end

end


function tower:draw()
    love.graphics.draw(self.towerImage,self.x,self.y)

    if self.projectile.isFlying then
        love.graphics.draw(self.projectile.image,self.projectile.x,self.projectile.y,self.projectile.angle,0.1,0.1,self.projectile.width/2,self.projectile.height/2)
    end
end


function tower:closestEnemy(allEnemies,range)
    local closestEnemy = nil
    local closestDist = range*range
    for i,enemy in ipairs(allEnemies) do
        if not enemy.isFinished and enemy:isAlive() and (enemy.isTargeted == false) then
            local ex,ey = enemy:getX(),enemy:getY()
            local distSqr = (self.x+64 - ex)^2 + (self.y+64 -ey)^2
            if distSqr <closestDist then
                closestDist = distSqr
                closestEnemy = enemy
            end
        end
    end
    return closestEnemy
end

return tower