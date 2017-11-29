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
   local curPos = ywCanvasObjPos(sara)
   local saraPos = ywPosCreate(BASE_CHAR_SPEED * moveRight - BASE_CHAR_SPEED * moveLeft,
			       BASE_CHAR_SPEED * moveDown - BASE_CHAR_SPEED * moveUp)
   if ywPosX(saraPos) + ywPosX(curPos) > 610 or ywPosX(saraPos) + ywPosX(curPos) < 0 then
      ywPosSet(saraPos, 0, ywPosY(saraPos))
   end
   if ywPosY(saraPos) + ywPosY(curPos) > 430 or ywPosY(saraPos) + ywPosY(curPos) < 0 then
      ywPosSet(saraPos, ywPosX(saraPos), 0)
   end
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
	 yesCall(yeGet(touched, "onTouch"), entity, touched)
        local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
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
   if (turnNb + (yuiRand() % (OBSTACLE_DENSITY / 2))) % OBSTACLE_DENSITY == 0 then
      createObstacle(entity)
   end
   if (niceGuyText) then
      ywCanvasRemoveObj(entity, niceGuyText)
      niceGuyText = nil
   end
   local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
   ywPosSet(pbs, ywPosX(pbs) + 1, ywPosY(pbs))
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
   yeSetString(yeGet(entity, "scoreTxt"), "score " .. score)
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

function dealDomage(entity, obstacle)
   print("dealDomage", entity, obstacle)
   local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
   ywPosSet(pbs, ywPosX(pbs) + 30, ywPosY(pbs))
end

function createGarbage(entity)
   local garbage = ywCanvasNewObj(entity, yuiRand() % 600, -70, 4)

   yeCreateFunction("dealDomage", garbage, "onTouch")
   return garbage
end

function meatNiceGuy(entity)
   local txt = yeCreateString("Nice Guy: You want some orange juice ?, here's some Orange Juice")
   niceGuyText = ywCanvasNewText(entity, 50, 100, txt)
   yeDestroy(txt)
   score = score + 2
   local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
   ywPosSet(pbs, ywPosX(pbs) + 4, ywPosY(pbs))
end

function createSuiteGuy(entity)
   local ret = ywCanvasNewObj(entity, yuiRand() % 600, -70, 7)

   yeCreateFunction("meatNiceGuy", ret, "onTouch")
   return ret
end

function createObstacle(entity)
   local garbage
   if (yuiRand() % 2) == 0 then
      garbage = createGarbage(entity)
   else
      garbage = createSuiteGuy(entity)
   end

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
   score = 0
   niceGuyText = nil

   ySoundPlay(ySoundLoad("sara_song.mp3"))
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
   local scoreText = "score " .. score
   local scoreTxtEnt = yeCreateString(scoreText, entity, "scoreTxt")
   ywCanvasNewText(entity, 10, 30, scoreTxtEnt)

   scoreTxtEnt = yeCreateString("Puking Bar, also know as Vomit Bar")
   yeDestroy(scoreText)
   ywCanvasNewText(entity, 10, 5, scoreTxtEnt)

   local obj = yeCreateArray(objs)
   yeCreateInt(1, obj)
   ywPosCreate(10, 20, obj)
   local rect = yeCreateArray(obj)
   ywPosCreate(10, 10, rect)
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
