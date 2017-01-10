-- Level assets (setDefaultFilter before loading any image resources)
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Enemy assets
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage('images/alien.png')

-- Enemy Particle system
particle_systems = {}
particle_systems.list = {}
particle_systems.img = love.graphics.newImage('images/particle.png')

-- Particle system
function particle_systems:spawn(x, y)
  local ps = {}
  ps.x = x
  ps.y = y
  ps.ps = love.graphics.newParticleSystem(particle_systems.img, 42)
  ps.ps:setParticleLifetime(2, 4)
  ps.ps:setEmissionRate(55)
  ps.ps:setSizeVariation(1)
  ps.ps:setLinearAcceleration(-20, -20, 20, 20)
  ps.ps:setColors(100, 255, 100, 255, 0, 255, 0, 255)
  
  table.insert(particle_systems.list, ps)
end

function particle_systems:draw()
  for _, v in pairs(particle_systems.list) do
    love.graphics.draw(v.ps, v.x, v.y)
  end
end

function particle_systems:update(dt)
  for _, v in pairs(particle_systems.list) do
    v.ps:update(dt)
  end
end

-- Remove particles
function particle_systems:cleanUp()
  -- Delete particles after an amount of time...
end

-- Check when player shoots enemy
function checkCollisions(enemies, bullets)
  
  for i, e in ipairs(enemies) do
    
    for _,b in pairs(bullets) do
      
      -- Calculate the enemies position with the bullet position. 
      if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
        -- Spawn particles
        particle_systems:spawn(e.x + 35, e.y + 45)
        -- Remove enemy on collision
        table.remove(enemies, i)
      end
      
    end
    
  end
  
end

-- Load game
function love.load()
  -- Load game entities
  background_image = love.graphics.newImage('images/background.png')
  game_over = false
  game_win = false
   
  -- Music config
  local music = love.audio.newSource('audio/level_one_soundtrack.mp3')
  music:setLooping(true)
  love.audio.play(music)
  
  -- Load player entities
  player(10)
  
  -- Load enemies entities
  spaceBetweenEnemies = function(space)
    return space
  end
  
  -- Set enemies quantity
  for count = 0, 6 do
    enemies_controller:spawnEnemies(count * 120, 0)
  end
end

-- Player keybindings
function player_keybindings()
  
  -- Player goes right
  if love.keyboard.isDown("right") then
    
    player.x = player.x + player.speed
    
  -- Player goes left
  elseif love.keyboard.isDown("left") then
    
    player.x = player.x - player.speed
    
  end

  -- Player fire laser
  if love.keyboard.isDown("space") then
    player.fire()
  end
end

-- Player object
function player(speed)
  player = {}
  -- Player x and y position
  player.x = 0 
  player.y = 520
  player.bullets = {}
  player.cooldown = 20
  player.speed = speed
  player.fire_sound = love.audio.newSource('audio/laser.wav')
  player.image = love.graphics.newImage('images/spaceship.png')
  player.bullet = love.graphics.newImage('images/bullet.png')
  
  player.fire = function()
    
    if player.cooldown <= 0 then
      
      love.audio.play(player.fire_sound)
      player.cooldown = 20
      bullet = {}
      -- Bullet x and y position
      bullet.x = player.x + 24
      bullet.y = player.y
      table.insert(player.bullets, bullet)
      
    end
    
  end
end

-- Enemies object
function enemies_controller:spawnEnemies(x, y)
  enemy = {}
  enemy.x = x
  enemy.y = y
  enemy.width = 35
  enemy.height = 35
  enemy.bullets = {}
  enemy.cooldown = 20
  enemy.speed = 0.5
  
  table.insert(self.enemies, enemy)
end

function enemy:fire()
  if self.cooldown <= 0 then
      
    love.audio.play(self.fire_sound)
    self.cooldown = 20
    bullet = {}
    bullet.x = player.x + 35
    bullet.y = player.y
    table.insert(self.bullets, bullet)
      
  end
end

-- Update by every frame
function love.update(dt)
  particle_systems:update(dt)
  player.cooldown = player.cooldown - 1

  -- Player movement
  player_keybindings()
  
   -- Set game_win to true if all enemies are defeated.
  if #enemies_controller.enemies == 0 then
    -- we win
    game_win = true
  end
  
  -- Enemies movement
  for _,e in pairs(enemies_controller.enemies) do
    
    -- Game over when enemies reached the bottom of the screen
    if e.y >= love.graphics.getHeight() - 80 then
      game_over = true
    end
    
    e.y = e.y + 1 * e.speed
  end

  -- Bullet movement
  for i,b in ipairs(player.bullets) do
    
    if b.y < -10 then
      table.remove(player.bullets, i)
    end
    
    b.y = b.y - 10
  end
  
  -- Collision
  checkCollisions(enemies_controller.enemies, player.bullets)
end

-- Draw game
function love.draw()
  -- Set background image (Must be first in the draw function)
  love.graphics.draw(background_image)
  setRotration = 0
  love.graphics.setColor(255, 255, 255)
  setScale = function(scale)
    -- Set player and enemy scale.
    return scale
  end
  
  -- draw the player
  love.graphics.draw(player.image, player.x, player.y, setRotration, setScale(0.5))
  
  -- draw enemies
  for _,e in pairs(enemies_controller.enemies) do
    love.graphics.draw(enemies_controller.image, e.x, e.y, setRotration, setScale(0.5))
  end

  -- draw bullets
  love.graphics.setColor(255, 255, 255)
  for _,b in pairs(player.bullets) do
    love.graphics.draw(player.bullet, b.x, b.y, setRotration, setScale(0.3))
  end
  
  -- draw particles
  particle_systems:draw()
  
  -- Return Message if the player wins or lose
  if game_over then
    love.graphics.print("GAME OVER!")
    return
  elseif game_win then
    love.graphics.print("YOU WON!")
  end
  
end