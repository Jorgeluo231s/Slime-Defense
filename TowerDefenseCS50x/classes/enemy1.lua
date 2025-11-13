local function addPath(path)
    package.path = package.path .. ';' .. path .. '/?.lua;' .. path .. '/?/init.lua'
end
addPath(love.filesystem.getSource() .. '/../shared_libraries')
anim8 = require 'anim8'
local enemy = {}
enemy.__index = enemy
function enemy:new(world,path)

    local instance = setmetatable({},enemy)

    instance.path = path
    instance.currentWaypointIndex = 1

    local startX = instance.path[1].x
    local startY = instance.path[1].y

    instance.collider = world:newRectangleCollider(startX,startY,60,35)
    instance.collider:setFixedRotation(true)
    instance.collider:setSensor(true)
    instance.x = startX
    instance.y = startY
    instance.speed = 100
    instance.angle = 0
    instance.isFinished = false
    instance.isTargeted = false
    instance.stat = {}
    instance.stat.hp = 100
    instance.stat.gold = 5
    instance.stat.damage = 1
    instance.stat.isAlive = true

    instance.animSlime = {
        love.graphics.newImage('sprites/slime/slime0.png'),
        love.graphics.newImage('sprites/slime/slime1.png'),
        love.graphics.newImage('sprites/slime/slime2.png'),
        love.graphics.newImage('sprites/slime/slime3.png')
    }
    instance.frameWidth = 32
    instance.frameHeight = 35

    instance.anim = anim8.newAnimation({1,2,3,4},0.15)
    return instance
end
function enemy:update(dt,player)
    if self.isFinished or not self.stat.isAlive then
        self.collider:setLinearVelocity(0,0)
        return
    end

    local target = self.path[self.currentWaypointIndex]
    if not target then
        self.isFinished = true
        self.collider:setLinearVelocity(0,0)
        return
    end
    self.x = self.collider:getX()
    self.y = self.collider:getY()

    local dx = target.x -self.x
    local dy = target.y -self.y
    local distance = math.sqrt(dx*dx +dy*dy)

    local arrivalThreshold = 10
    if distance < arrivalThreshold then

        self.currentWaypointIndex =self.currentWaypointIndex +1

        if self.currentWaypointIndex> #self.path then
            self.isFinished = true
            self.collider:setLinearVelocity(0,0)
            player:loselife()
            return
        end
        target = self.path[self.currentWaypointIndex]
        dx = target.x - self.x
        dy = target.y - self.y
        distance = math.sqrt(dx*dx + dy*dy)
    end
    local norm_x,norm_y = 0,0
    if distance > 1 then
        norm_x = dx/distance
        norm_y = dy/distance
    end
    local vx = norm_x * self.speed
    local vy = norm_y * self.speed
    self.collider:setLinearVelocity(vx,vy)
    --self.angle = math.atan2(dy,dx)
    self.anim:update(dt)
end
function enemy:draw()
    if (self.stat.isAlive) and (self.isFinished == false) then
        local frameIndex = self.anim.position
        local currentImage = self.animSlime[frameIndex]
        love.graphics.draw(currentImage,self.x,self.y,nil,2.5,2.5,16,17.5)
    end
end

function enemy:getX()
    return self.x
end
function enemy:getY()
    return self.y
end
function enemy:getVelocity()
    return self.collider:getLinearVelocity()
end
function enemy:takeDamage(projectileDamage,player)
    if not self.stat.isAlive then return end
    self.stat.hp = self.stat.hp-projectileDamage
    if self.stat.hp <= 0 then
        self.stat.isAlive = false
        self.isFinished = true
        player:gainGold(self.stat.gold)
        self.collider:setLinearVelocity(0,0)
    end
end
function enemy:getPosition()
    return self.x, self.y
end
function enemy:isAlive()
    return self.stat.isAlive
end
function enemy:destroy()
    self.collider:destroy()
end
return enemy