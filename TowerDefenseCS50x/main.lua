local function addPath(path)
    package.path = package.path .. ';' .. path .. '/?.lua;' .. path .. '/?/init.lua'
end
addPath(love.filesystem.getSource() .. '/../shared_libraries')
function love.load()
    anim8 = require 'anim8'
    love.graphics.setDefaultFilter("nearest","nearest")
    local wf = require 'windfield'
    world = wf.newWorld(0, 0)

    local sti = require 'sti'
    gameMap = sti('maps/pathOne.lua')

    local pathLayer = gameMap.layers["Path"]
    local pathObject = pathLayer.objects[1]
    waypoints = {}
    for i,point in ipairs(pathObject.polyline) do
        table.insert(waypoints,{
            x =point.x,
            y =point.y
        })
    end
    --local camera = require 'camera'
    --cam = camera()
    --cameras = {}
    --cameras.x = 700
    --cameras.y = 600
    --cameras.speed = 10
    local enemyBlueprint = require 'classes/enemy1'
    towerBlueprint = require 'classes/tower1'
    enemies = {}
    towers = {}
    local Player = require 'classes/player'
    playerStat = Player:new("Jorge LUO")
    local waves = require 'classes/waves'
    spawner = waves:new(world,enemyBlueprint,waypoints,enemies)
    gameState = "alive"
    fontpath = 'fonts/ARCADECLASSIC.TTF'
    loseFont = love.graphics.newFont(fontpath,60)
    winFont = love.graphics.newFont(fontpath,60)
    normalFont = love.graphics.newFont(fontpath, 30)

    notificationText = ""
    notificationTimer = 0

    ghostTower = {
        x = 0,
        y = 0,
        tileX = 0,
        tileY = 0,
        isValid = false
    }
    gameStart()
end

function love.update(dt)
    dt = math.min(0.1,dt)
    if notificationTimer > 0 then
        notificationTimer = notificationTimer-dt
        if notificationTimer <= 0 then
            notificationText = ""
        end
    end
    if gameState == "alive" then
        world:update(dt)
        spawner:update(dt)


        for i = #enemies ,1,-1 do
            local enemy = enemies[i]
            enemy:update(dt,playerStat)
            if not enemy:isAlive() or enemy.isFinished then
                enemy:destroy()
                table.remove(enemies,i)
            end
        end
        for i,tower in ipairs(towers) do
            tower:update(dt,enemies,playerStat)
        end
        if playerStat.lives <= 0 then
            gameState = "lose"
        end
        if spawner.state == "finished" and #enemies == 0 and playerStat.lives > 0 then
            gameState = "win"
        end
    elseif gameState == "placing" then
        local mouseX,mouseY = love.mouse:getPosition()
        ghostTower.tileX = math.floor(mouseX/64)+1
        ghostTower.tileY = math.floor(mouseY/64)+1
        ghostTower.x = (ghostTower.tileX-1)*64
        ghostTower.y = (ghostTower.tileY-1)*64
        ghostTower.isValid = isValidPath(ghostTower.tileX,ghostTower.tileY)
    end
end
function love.draw()
    gameMap:drawLayer(gameMap.layers['Ground'])
    gameMap:drawLayer(gameMap.layers['Objects'])
    for i,tower in ipairs(towers) do
        tower:draw()
    end

    for i,enemy in ipairs(enemies) do
    enemy:draw()
    end
    if notificationTimer > 0 then 
        love.graphics.setFont(normalFont)
        love.graphics.setColor(1,0,0)
        love.graphics.printf(notificationText,20,
            love.graphics.getHeight() -normalFont:getHeight() - 20,
            love.graphics.getWidth()-40,
            "left")
        love.graphics.setColor(1,1,1)
    end
    if gameState == "lose" then
        love.graphics.setColor(1, 0, 0) -- Red
        love.graphics.setFont(loseFont)
        love.graphics.printf("YOU LOSE", 0, love.graphics.getHeight()/2 - 50, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1)
    elseif gameState == "win" then
        love.graphics.setColor(0, 1, 0) -- Green
        love.graphics.setFont(winFont)
        love.graphics.printf("YOU WIN!", 0, love.graphics.getHeight()/2 - 50, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1)
    else
        if gameState == "placing" then
            if ghostTower.isValid then
                love.graphics.setColor(0,1,0,0.5)
            else
                love.graphics.setColor(1,0,0,0.5)
            end
            love.graphics.rectangle("line",ghostTower.x,ghostTower.y,128,128)
            love.graphics.circle("line",ghostTower.x+64,ghostTower.y+64,280)
            love.graphics.setColor(1,1,1)
        end
    end
        love.graphics.setFont(normalFont)
        love.graphics.print("Player  "..playerStat.name,100,10)
        love.graphics.print(playerStat.gold.."G",400,10)
        love.graphics.print(playerStat.lives.." Lives ",500,10)
        love.graphics.print("Current Wave IS "..spawner.currentWave,700,10)
        if #towers < playerStat.maxTower then
            love.graphics.print("Next Tower IS "..playerStat.towerPrice[#towers+1].price.."G",100,50)
        end
end

function love.keypressed(key)
    if key == "p" and (gameState == "alive" or gameState == "placing") then
        if gameState == "alive" then
            if #towers >=playerStat.maxTower then
                notificationText = "Maximum Ammount of towers Bought!"
                notificationTimer = 2
                return
            end
            local nextTower = #towers +1
            local nextCost = playerStat.towerPrice[nextTower].price
            if playerStat.gold < nextCost then
                notificationText = "Not enough gold to place Tower!"
                notificationTimer = 2
                return
            else
                gameState = "placing"
                return
            end
        else
            gameState = "alive"
        end
    end
end

function isValidPath(tileX,tileY)
    if tileX <1 or tileX > 19 or tileY <1 or tileY > 11 then
        return false
    end
    ground = gameMap.layers["Ground"].data
    for y = 0,1 do 
        for x = 0,1 do
            local tile = ground[tileY+y][tileX+x]
            if tile and tile.gid == 14 then
                return false
            end
        end
    end
    local pixelX,pixelY = (tileX-1)*64,(tileY-1)*64
    local size = 128
    for i,tower in ipairs(towers) do
        local towerX = tower.x
        local towerY = tower.y
        if pixelX <towerX+size and pixelX +size > towerX and pixelY <towerY+size and pixelY +size > towerY then
            return false
        end
    end
    return true
end
function love.mousepressed(x,y,button,isTouch)
    if button == 1 then
        if gameState == "placing" then
            if ghostTower.isValid then
                local cost = playerStat.towerPrice[(#towers+1)].price
                playerStat:gainGold(-cost)
                local newTower = towerBlueprint:new(world,ghostTower.x,ghostTower.y)
                table.insert(towers,newTower)
                gameState = "alive"
            else
                notificationText = "YOU CANNOT PLACE HERE!"
                notificationTimer = 2
            end
        end
    elseif button ==2 and gameState == "placing" then
        gameState ="alive"
    end
end

function gameStart()
    notificationText = "press P to start Placement mode"
    notificationTimer = 5
end