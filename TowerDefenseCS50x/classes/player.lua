player = {}
player.__index = player

function player:new(name)
    local instance = setmetatable({},player)
    instance.gold = 5
    instance.maxTower = 5
    instance.name = name
    instance.towers = {}
    instance.towerPrice = {}
    instance.towerPrice[1] = {price = 5}
    instance.towerPrice[2] = {price = 35}
    instance.towerPrice[3] = {price = 100}
    instance.towerPrice[4] = {price = 240}
    instance.towerPrice[5] = {price = 400}
    instance.lives = 15
    return instance
end
function player:update(dt)

end
function player:loselife()
    self.lives = self.lives-1
end
function player:gainGold(enemyGold)
    self.gold = self.gold+ enemyGold
end
return player
