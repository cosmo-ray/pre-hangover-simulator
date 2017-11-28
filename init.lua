local Q_KEY = 113
local BASE_CHAR_SPEED = 10
local BASE_SCROLL_SPEED = 5
local OBSTACLE_DENSITY = 26

function createStreetLine(wid, idx)
   ywCanvasNewObj(wid, 0, idx, 0)
   ywCanvasNewObj(wid, 70, idx, 1)
   jdx = 140
   while jdx < 500 do
      ywCanvasNewObj(wid, jdx, idx, 3)
      jdx = jdx + 60
   end
   ywCanvasNewObj(wid, 500, idx, 2)
   ywCanvasNewObj(wid, 570, idx, 0)
end

function moveSara(entity, eve, objs)
   local endRoad = yeGetInt(yeGet(entity, "road-end-idx"))
   local sara = yeGet(entity, "sara")
   local saraIdx = ywCanvasIdxFromObj(entity, sara)
   local saraPos = ywPosCreate(BASE_CHAR_SPEED * moveRight - BASE_CHAR_SPEED * moveLeft,
			       BASE_CHAR_SPEED * moveDown - BASE_CHAR_SPEED * moveUp)
   ywCanvasMoveObjByIdx(entity, saraIdx, saraPos)
   yeDestroy(saraPos)
   if (turnNb % 2) == 0 then
      if saraId == 5 then
      	 saraId = 6
      else
         saraId = 5
      end
      ywCanvasObjSetResourceId(sara, saraId)
   end
end

function checkColisions(entity)
   local sara = yeGet(entity, "sara")
   local touchBySara = ywCanvasNewColisionsArray(entity, sara)
   for i = 0, yeLen(touchBySara) do
      local touched = yeGet(touchBySara, i)
      if yeGetInt(yeGet(touched, "type")) == 1 then
        print("she touch me")
        local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
        ywPosSet(pbs, ywPosX(pbs) + 30, ywPosY(pbs))
        if  ywPosX(pbs) >= 640 then
          local nextWidget = ygGet("phs:scenes.lose")
          local scoreStrEntity = yeGet(nextWidget, "text")

          yeSetString(scoreStrEntity, yeGetString(scoreStrEntity) .. score)
          yCallNextWidget(entity)
        end
        print(ywPosX(pbs))
      end
   end
   --print(touchBySara, yeLen(touchBySara))
end

function phsAction(entity, eve, arg)
   local objs = yeGet(entity, "objs")
   local endRoad = yeGetInt(yeGet(entity, "road-end-idx"))
   
   while ywidEveIsEnd(eve) == false do
      if ywidEveType(eve) == YKEY_DOWN and ywidEveKey(eve) == Q_KEY then yFinishGame() end
      if ywidEveType(eve) == YKEY_DOWN and ywidEveKey(eve) == Y_UP_KEY then moveUp = 1 end
      if ywidEveType(eve) == YKEY_DOWN and ywidEveKey(eve) == Y_DOWN_KEY then moveDown = 1 end
      if ywidEveType(eve) == YKEY_DOWN and ywidEveKey(eve) == Y_LEFT_KEY then moveLeft = 1 end
      if ywidEveType(eve) == YKEY_DOWN and ywidEveKey(eve) == Y_RIGHT_KEY then moveRight = 1 end
      if ywidEveType(eve) == YKEY_UP and ywidEveKey(eve) == Y_UP_KEY then moveUp = 0 end
      if ywidEveType(eve) == YKEY_UP and ywidEveKey(eve) == Y_DOWN_KEY then moveDown = 0 end
      if ywidEveType(eve) == YKEY_UP and ywidEveKey(eve) == Y_LEFT_KEY then moveLeft = 0 end
      if ywidEveType(eve) == YKEY_UP and ywidEveKey(eve) == Y_RIGHT_KEY then moveRight = 0 end
      
      eve = ywidNextEve(eve)
   end
   --if (turnNb + (yuiRand() % (OBSTACLE_DENSITY / 2))) % OBSTACLE_DENSITY == 0 then
   createObstacle(entity)
   --end
   moveObstacles(entity)
   moveSara(entity, eve, objs)
   checkColisions(entity)
   local pos = ywPosCreate(0, BASE_SCROLL_SPEED)
   local curPos = yeGet(yeGet(objs, 0), "pos")
   yeDestroy(pos)
   if ywPosY(curPos) % 70 == 0 and ywPosY(curPos) > -70 then
      local pos = ywPosCreate(0, -65 - ywPosY(curPos))
   else
      local pos = ywPosCreate(0, BASE_SCROLL_SPEED)
   end
   local idx = 0
   while (idx < endRoad) do
      ywCanvasMoveObjByIdx(entity, idx, pos)
      idx = idx + 1
   end
   yeDestroy(pos)
   turnNb = turnNb +1
   -- score update:
   score = score + 1
   return YEVE_ACTION
end

function moveObstacles(entity)
   local obstacles = yeGet(entity, "obstacles")
   local endObstacles = yeLen(obstacles)

   for i = 0, endObstacles do
      local obstacle = yeGet(obstacles, i)
      local obstacleIdx = ywCanvasIdxFromObj(entity, obstacle)
      local pos = ywPosCreate(0, BASE_SCROLL_SPEED)

      if obstacleIdx ~= -1 then
	 ywCanvasMoveObjByIdx(entity, obstacleIdx, pos)
	 yeDestroy(pos)
      end
   end
end

function createObstacle(entity)
   local garbage = ywCanvasNewObj(entity, yuiRand() % 600, -70, 4)

   yeCreateInt(1, garbage, "type")
   local touchByGarbage = ywCanvasNewColisionsArray(entity, garbage)
   for i = 0, yeLen(touchByGarbage) do
      local touched = yeGet(touchByGarbage, i)
      if yeGetInt(yeGet(touched, "type")) == 1 then
	 yeRemoveChild(yeGet(entity, "objs"), garbage)
	 return
      end
   end
   yePushBack(yeGet(entity, "obstacles"), garbage)
end

function initPhsWidget(entity)
   moveUp = 0
   moveDown = 0
   moveLeft = 0
   moveRight = 0
   turnNb = 0
   score = 0;

   yeCreateString("rgba: 0 0 0 255", entity, "background")
   yeCreateFunction("phsAction", entity, "action")
   yeCreateInt(100000, entity, "turn-length")
   local objs = yeCreateArray(entity, "objs");

   local screenH = 480
   local idx = -70;
   while idx < screenH do
      createStreetLine(entity, idx)
      idx = idx + 70
   end
   yeCreateInt(yeLen(objs), entity, "road-end-idx")
   saraId = 6
   local sara = ywCanvasNewObj(entity, 350, 250, saraId)
   yePushBack(entity, sara, "sara")
   yeCreateArray(entity, "obstacles")
   
   createObstacle(entity)

   local obj = yeCreateArray(objs)
   yeCreateInt(1, obj)
   ywPosCreate(10, 10, obj)
   local rect = yeCreateArray(obj)
   ywPosCreate(100, 10, rect)
   yeCreateString("rgba: 180 50 10 160", rect)
   yePushBack(entity, obj, "pukeBar")

   local canvas = ywidNewWidget(entity, "canvas")
   return canvas
end

function init(mod)
   local map = yeCreateArray(mod, "game")
   yuiRandInit()
   yeCreateString("phs", map, "<type>")
   yeCreateString("phs:scenes.lose", map, "next")
   yePushBack(map, ygGet("phs.resources"), "resources")
   local init = yeCreateArray()
   yeCreateString("phs", init, "name")
   yeCreateFunction("initPhsWidget", init, "callback")
   ywidAddSubType(init)
end
