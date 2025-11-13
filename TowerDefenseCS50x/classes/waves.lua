local waves = {}
waves.__index = waves

function waves:new(world,enemyBlueprint,waypoints,allEnemies)
    local instance = setmetatable({},waves)
    instance.world = world
    instance.blueprint = enemyBlueprint
    instance.waypoints = waypoints
    instance.totalEnemies = allEnemies

    instance.waves = {}
    instance.waves[1] = {count = 5, delay = 1.5}
    instance.waves[2] = {count = 10, delay = 1.0}
    instance.waves[3] = {count = 15, delay = 0.8}
    instance.waves[4] = {count = 20, delay = 0.8}
    instance.waves[5] = {count = 25, delay = 0.8}
    instance.waves[6] = {count = 25, delay = 0.5}
    instance.waves[7] = {count = 30, delay = 0.8}
    instance.waves[8] = {count = 35, delay = 0.8}
    instance.waves[9] = {count = 40, delay = 0.5}
    instance.waves[10] = {count = 50, delay = 0.3}

    instance.currentWave = 1
    instance.state = "waiting"
    instance.waveDelay = 10.0
    instance.waveTimer = 10.0
    instance.enemiesToSpawn = 0
    instance.spawnTimer = 0
    return instance
end

function waves:update(dt)
    if self.state == "waiting" then
        self.waveTimer = self.waveTimer-dt
        if self.waveTimer <= 0 then
            self.state = "spawning"
            local wave = self.waves[self.currentWave]
            self.enemiesToSpawn = wave.count
            self.spawnTimer = wave.delay
        end
    elseif self.state == "spawning" then
        if self.enemiesToSpawn <=0 then
            self.state = "waiting"
            self.currentWave = self.currentWave+1
            self.waveTimer = self.waveDelay
            if self.currentWave > #self.waves then
                self.state = "finished"
                return
            end
            return
        end
        self.spawnTimer = self.spawnTimer -dt
        if self.spawnTimer <= 0 then
            self:spawnEnemy()
            self.spawnTimer = self.waves[self.currentWave].delay
        end
    end
end


function waves:spawnEnemy()
    local newEnemy = self.blueprint:new(self.world,self.waypoints)
    table.insert(self.totalEnemies,newEnemy)
    self.enemiesToSpawn = self.enemiesToSpawn -1
end
return waves