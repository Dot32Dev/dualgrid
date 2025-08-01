local TILESIZE = 40
local EDIT_MODE = 1

local TILES = {}
for x=1, love.graphics.getWidth()/TILESIZE do
  table.insert(TILES, {})
  for y=1, love.graphics.getHeight()/TILESIZE do
    table.insert(TILES[x], 0)
  end
end

local TILESET = {}
local TILESET_IMAGE = love.graphics.newImage("tileset.png")
local TILESET_TILE_SIZE = 100
for i=1, TILESET_IMAGE:getWidth()/TILESET_TILE_SIZE do
  table.insert(
    TILESET, 
    love.graphics.newQuad((i-1) * TILESET_TILE_SIZE, 0, 100, 100, TILESET_IMAGE)
  )
end

function love.draw() 
  love.graphics.setColor(1,1,1, 0.1)

  drawGrid(
    0, 0,
    love.graphics.getWidth()/TILESIZE, 
    love.graphics.getHeight()/TILESIZE, 
    TILESIZE
  )

  drawTiles(0, 0, TILES, TILESIZE)

  love.graphics.setColor(1,1,1,1)
  love.graphics.print("Press space to switch edit mode", 10 , 10)
end

function drawGrid(xx, yy, width, height, tilesize) 
  for y = 0, height do
    for x = 0, width do
      love.graphics.rectangle(
        "line", 
        x * tilesize + xx, 
        y * tilesize + yy, 
        tilesize, tilesize
      ) 
    end
  end
end

function drawTiles(xx, yy, grid, tilesize) 
  for x = 1, #grid + 2 do
    for y = 1, #grid[1] + 2 do
      local tile = 0;

      if grid[x-1] and grid[x-1][y - 1] and grid[x-1][y - 1] == 1 
        then tile = tile + 1
      end
      if grid[x] and grid[x][y - 1] and grid[x][y - 1] == 1 
        then tile = tile + 2
      end
      if grid[x] and grid[x][y] and grid[x][y] == 1 then 
        tile = tile + 4 
      end
      if grid[x-1] and grid[x-1][y] and grid[x-1][y] == 1 then 
        tile = tile + 8
      end
      

      imageIdx, rot = lookup(tile)
      love.graphics.setColor(1,1,1,1)
      love.graphics.draw(
        TILESET_IMAGE, 
        TILESET[imageIdx], 
        (x - 1) * tilesize + xx, 
        (y - 1) * tilesize + yy, 
        math.pi/2 * rot, 
        tilesize / TILESET_TILE_SIZE, --scale
        tilesize / TILESET_TILE_SIZE,
        TILESET_TILE_SIZE / 2,
        TILESET_TILE_SIZE / 2
      )

      if imageIdx ~= 1 then
        love.graphics.setColor(0.2,0.1,0.8, 1)
        love.graphics.rectangle(
         "line",
         x * tilesize + xx - tilesize * 1.5,
         y * tilesize + yy - tilesize * 1.5,
         tilesize,
         tilesize
        )
      end
    end
  end
end

function love.keypressed(key)
  if key == "space" then
    EDIT_MODE = 1 - EDIT_MODE
  end
end

function love.update()
  if love.mouse.isDown(1) then
    local x = math.floor(love.mouse.getX() / TILESIZE) + 1
    local y = math.floor(love.mouse.getY() / TILESIZE) + 1

    TILES[x][y] = EDIT_MODE
  end 
end

function lookup(n) 
  -- 1 2
  -- 8 4

  -- maps tile neighbours to tile index and rotation
  local lookupTable = {
    [00] = {1, 0},
    -- corners
    [01] = {2, 0},
    [02] = {2, 1},
    [04] = {2, 2},
    [08] = {2, 3},
    -- sides
    [03] = {3, 0},
    [06] = {3, 1},
    [12] = {3, 2},
    [09] = {3, 3},
    -- opposite corners
    [05] = {4, 0},
    [10] = {4, 1},
    -- everything except one corner
    [07] = {5, 0},
    [14] = {5, 1},
    [13] = {5, 2},
    [11] = {5, 3},
    -- full
    [15] = {6, 0},
  }

  return lookupTable[n][1], lookupTable[n][2]
end