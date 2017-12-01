local Q_KEY = 113
local BASE_CHAR_SPEED = 10
local BASE_SCROLL_SPEED = 5
local OBSTACLE_DENSITY = 10

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

   if niceGuyText2 then
      if niceGuyText2Duration == 0 then
	 ywCanvasRemoveObj(entity, niceGuyText2)
	 niceGuyText2 = nil
      else
	 niceGuyText2Duration = niceGuyText2Duration - 1
      end
   end

   if saraSong then
      if saraSongDuration == 0 then
	 ywCanvasRemoveObj(entity, saraSong)
	 saraSong = nil
      else
	 saraSongDuration = saraSongDuration - 1
      end
   end

   if (niceGuyText) then
      ywCanvasRemoveObj(entity, niceGuyText)
      niceGuyText = nil
   end

   if (isDieying >= 0) then
      if isDieying == 0 then
	 yCallNextWidget(entity);
      end
      if saraSong then
	 ywCanvasRemoveObj(entity, saraSong)
      end
      local txt = yeCreateString("Sara: I'm presently throwing back everyting I've drink on myself\n"..
      "but developers are too lazy to give me a proper puking animation")
      niceGuyText = ywCanvasNewText(entity, 50, 100, txt)
      yeDestroy(txt)

      isDieying = isDieying - 1
      ywCanvasObjSetResourceId(yeGet(entity, "sara"), yuiRand() % 6)
      return YEVE_ACTION
   end
   if (turnNb + (yuiRand() % (OBSTACLE_DENSITY / 2))) % OBSTACLE_DENSITY == 0 then
      createObstacle(entity)
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

   local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
   if  ywPosX(pbs) >= 620 then
      isDieying = 40
   end

   if (ywPosX(pbs) >= 550  and saraSongDuration == 0) then
      local songtxt = "Sara: arkk, let's sing\n"
      local randNb = yuiRand() % 5
      if randNb == 0 then
	 songtxt = songtxt ..
	    "spam spam spam spam, lovely spam, wonderful spam"
      elseif randNb == 1 then
	 songtxt = songtxt ..
	    "Ohh it's mauvaise chance to be you !\n" ..
	    "un choisie de many isn't new\n" ..
	    "when you think you plein de luck, soudainement tu devien stuck\n" ..
	    "don't pence for a second it's not vrais !!..."
      elseif randNb == 2 then
	 songtxt = songtxt ..
	    "saraba the eath that ship that go away it's\n"..
	    "uchuu senkan Yamablazer !!! \n" ..
	    "searching for a distant star heading off to lala...\n"
      elseif randNb == 3 then
	 songtxt = songtxt ..
	    "get it !, get it !, get it !\n" ..
	    "you can get it now\n" ..
	    "attack attack ore wa shenshi !\n" ..
	    "kikoeru ka ? kikoeru ka yo ?\n" ..
	    "show me the way to you lead me nowhere you are Heavy Metal !"
      elseif randNb == 4 then
	 songtxt = songtxt ..
	    "Oh you drink my orange juice\n" ..
	    "La lalala lalalala lalalala\n" ..
	    "I'ts creazy creazy night, havin orange here by my side!\n"
      end
      local txt = yeCreateString(songtxt)
      if saraSong then
	 ywCanvasRemoveObj(entity, saraSong)
      end
      if niceGuyText2 then
	 ywCanvasRemoveObj(entity, niceGuyText2)
      end
      if niceGuyText then
	 ywCanvasRemoveObj(entity, niceGuyText)
      end
      saraSongDuration = 40
      saraSong = ywCanvasNewText(entity, 70, 120, txt)
      yeDestroy(txt)
   end

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
      if ywPosY(ywCanvasObjPos(obstacle)) > 500 then
	 ywCanvasRemoveObj(entity, obstacle)
	 yeRemoveChild(yeGet(entity, "obstacles"), obstacle)
      end
   end
end

function dealDomage(entity, obstacle)
   local txt = yeCreateString("Sara: Ohh a giant trash bin attacks me, go away pile of trash")
   if niceGuyText then
      ywCanvasRemoveObj(entity, niceGuyText)
   end
   niceGuyText = ywCanvasNewText(entity, 50, 100, txt)
   yeDestroy(txt)
   local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
   ywPosSet(pbs, ywPosX(pbs) + 30, ywPosY(pbs))
end

function createGarbage(entity)
   local garbage = ywCanvasNewObj(entity, yuiRand() % 600, -70, 4)

   yeCreateFunction("dealDomage", garbage, "onTouch")
   return garbage
end

function meatNiceGuy(entity)
   local txt = yeCreateString("Nice Guy: You want some orange juice ?, here's some Orange Juice\n"..
			      "Sara: glou glou...")
   if niceGuyText then
      ywCanvasRemoveObj(entity, niceGuyText)
   end
   niceGuyText = ywCanvasNewText(entity, 50, 100, txt)
   yeDestroy(txt)
   score = score + 2
   local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
   ywPosSet(pbs, ywPosX(pbs) + 4, ywPosY(pbs))
end

function meatCharmingGuy(entity)
   local txt = yeCreateString("Charming Guy: hejj ! mademoiselle you'e cute, give me you phone(BURPP)\n"..
			      "                I'll give you some free juice at my home\n"..
			      "Sara: hummm this guy devinitively know how to talk to a girl\n"..
			      "        I will absolutely give him my number")

   if niceGuyText then
      ywCanvasRemoveObj(entity, niceGuyText)
   end
   niceGuyText = ywCanvasNewText(entity, 50, 100, txt)
   yeDestroy(txt)
   score = score - 3
   local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
   ywPosSet(pbs, ywPosX(pbs) - 2, ywPosY(pbs))
end

function createSuiteGuy(entity)
   local ret = ywCanvasNewObj(entity, yuiRand() % 600, -70, 7)

   yeCreateFunction("meatNiceGuy", ret, "onTouch")
   return ret
end

function createCharmingGuy(entity)
   local ret = ywCanvasNewObj(entity, yuiRand() % 600, -70, 9)

   yeCreateFunction("meatCharmingGuy", ret, "onTouch")
   return ret
end

function eatBurger(entity, obstacle)
   local txt = yeCreateString("Sara: yum yum, some anti vomit pills, American gastronomy is soo Good !")
   if (niceGuyText2) then
      ywCanvasRemoveObj(entity, niceGuyText2)
   end
   niceGuyText2 = ywCanvasNewText(entity, 50, 80, txt)
   niceGuyText2Duration = 20
   yeDestroy(txt)
   local pbs = ywCanvasObjSize(entity, yeGet(entity, "pukeBar"))
   ywPosSet(pbs, ywPosX(pbs) - 50, ywPosY(pbs))
   ywCanvasRemoveObj(entity, obstacle)
   yeRemoveChild(yeGet(entity, "obstacles"), obstacle)
end

function createAntiPukePile(entity)
--   local txt = yeCreateString("Burger !!!")
--   ret = ywCanvasNewText(entity, yuiRand() % 600, -70, txt)
--   yeDestroy(txt)
   local ret = ywCanvasNewObj(entity, yuiRand() % 600, -70, 8)
   
   yeCreateFunction("eatBurger", ret, "onTouch")
   return ret
end

function createObstacle(entity)
   local garbage
   local nb = yuiRand() % 9

   if nb <= 5 then
      garbage = createGarbage(entity)
   elseif nb == 6 then
      garbage = createSuiteGuy(entity)
   elseif nb == 7 then
      garbage = createAntiPukePile(entity)
   elseif nb == 8 then
      garbage = createCharmingGuy(entity)
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
   niceGuyText2 = nil
   niceGuyText2Duration = 0
   saraSong = nil
   saraSongDuration = 0
   isDieying = -1

   ySoundPlayLoop(ySoundLoad("./Mars.wav"))
   yeCreateString("rgba: 0 0 0 255", entity, "background")
   yeCreateFunction("phsAction", entity, "action")
   yeCreateInt(50000, entity, "turn-length")
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

function getHightscore(wid, eve, args)
   local hs = ygFileToEnt(YJSON, "phs-hightscore.json")

   yeCreateString("das best meilleur score\n" ..
		     "with more points that other players is:\n"..
		     "[no name implemented yet] : " .. yeGetInt(hs),
		  wid, "text");
end

function scoreInit(wid, eve, args)
   -- Get the score from the snake module
   local hs = ygFileToEnt(YJSON, "phs-hightscore.json")
   local scoreStrEntity = yeGet(wid, "text")
   --yeSetString(scoreStrEntity, yeGetString(scoreStrEntity) .. score)
   local scoreStr = yeGetString(scoreStrEntity) .. score

   if (yeGetInt(hs) > score) then
      scoreStr = scoreStr .. "\nhightscore:" .. yeGetInt(hs)
   else
      scoreStr = scoreStr .. "\nnew Hightscore !"
      local scoreEnt = yeCreateInt(score)
      ygEntToFile(YJSON, "phs-hightscore.json", scoreEnt)
      yeDestroy(scoreEnt)
   end
   yeSetString(yeGet(wid, "text"), scoreStr)
   yeDestroy(hs)
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
   yeCreateFunction("scoreInit", mod, "scoreInit")
   yeCreateFunction("getHightscore", mod, "getHightscore")
   ywidAddSubType(init)
end
