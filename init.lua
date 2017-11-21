local Q_KEY = 113
local BASE_CHAR_SPEED = 10
local BASE_SCROLL_SPEED = 5

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

--[[function moveSaraBackup(entity, eve, objs)
   local endRoad = yeGetInt(yeGet(entity, "road-end-idx"))
   local saraPos = yeGet(yeGet(objs, endRoad), "pos")
   if ywidEveKey(eve) == Y_UP_KEY then
      saraPos = ywPosCreate(0, - BASE_CHAR_SPEED)
      ywCanvasMoveObjByIdx(entity, endRoad, saraPos)
      return
   elseif ywidEveKey(eve) == Y_DOWN_KEY then
      saraPos = ywPosCreate(0, BASE_CHAR_SPEED)
      ywCanvasMoveObjByIdx(entity, endRoad, saraPos)
      return
   end 
   if ywidEveKey(eve) == Y_LEFT_KEY then
      saraPos = ywPosCreate(- BASE_CHAR_SPEED, 0)
      ywCanvasMoveObjByIdx(entity, endRoad, saraPos)
      return
   elseif ywidEveKey(eve) == Y_RIGHT_KEY then
      saraPos = ywPosCreate(BASE_CHAR_SPEED, 0)
      ywCanvasMoveObjByIdx(entity, endRoad, saraPos)
      return
   end
end]]

function moveSara(entity, eve, objs)
   local endRoad = yeGetInt(yeGet(entity, "road-end-idx"))
   local saraPos = yeGet(yeGet(objs, endRoad), "pos")

   saraPos = ywPosCreate(BASE_CHAR_SPEED * moveRight - BASE_CHAR_SPEED * moveLeft,
			 BASE_CHAR_SPEED * moveDown - BASE_CHAR_SPEED * moveUp)
   ywCanvasMoveObjByIdx(entity, endRoad, saraPos)   
end

function phsAction(entity, eve, arg)
   local objs = yeGet(entity, "objs")
   local endRoad = yeGetInt(yeGet(entity, "road-end-idx"))

   --   print("action !",
--	 yeGetString(yeGet(yeGet(yeGet(entity, "resources"), 0), "img")),
--	 yeGetInt(yeGet(entity, "road-end-idx")))
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
      
	    
--[[	 elseif ywidEveKey(eve) == Y_UP_KEY
	    or ywidEveKey(eve) == Y_DOWN_KEY
	    or ywidEveKey(eve) == Y_RIGHT_KEY
	    or ywidEveKey(eve) == Y_LEFT_KEY
	 then
	    moveSara(entity, eve, objs)
	 end
   end]]
      eve = ywidNextEve(eve)
--      moveSara(entity, eve, objs)
   end
   moveSara(entity, eve, objs)
   print("Up : ", moveUp)
   local pos = ywPosCreate(0, BASE_SCROLL_SPEED)
   local curPos = yeGet(yeGet(objs, 0), "pos")
--   ywPosPrint(curPos)
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
  -- ywCanvasMoveObjByIdx(entity, yeGetInt(yeGet(entity, "sara")), 0)
   yeDestroy(pos)
   return YEVE_ACTION
end

function initPhsWidget(entity)
   moveUp = 0
   moveDown = 0
   moveLeft = 0
   moveRight = 0

   print("new wid", yeGet(entity, "<type>"))
   yeCreateString("rgba: 0 0 0 255", entity, "background")
   yeCreateFunction("phsAction", entity, "action")
   yeCreateInt(150000, entity, "turn-length")
   local objs = yeCreateArray(entity, "objs");

   local screenH = 480
   local idx = -70;
   while idx < screenH do
      createStreetLine(entity, idx)
      --[[local obj = yeCreateArray(objs)
      ywPosCreate(0, idx, obj, "pos")
      yeCreateInt(0, obj, "id")
      obj = yeCreateArray(objs)
      ywPosCreate(70, idx, obj, "pos")
      yeCreateInt(1, obj, "id")
      jdx = 140
      while jdx < 500 do
	 obj = yeCreateArray(objs)
	 ywPosCreate(jdx, idx, obj, "pos")
	 yeCreateInt(3, obj, "id")
	 jdx = jdx + 60
      end
      obj = yeCreateArray(objs)
      ywPosCreate(500, idx, obj, "pos")
      yeCreateInt(2, obj, "id")
      obj = yeCreateArray(objs)
      ywPosCreate(570, idx, obj, "pos")
	 yeCreateInt(0, obj, "id")--]]
      idx = idx + 70
   end
   yeCreateInt(yeLen(objs), entity, "road-end-idx")
   ywCanvasNewObj(entity, 350, 250, 4)
--   yeCreateInt(yeLen(objs), entity, "sara")
   local canvas = ywidNewWidget(entity, "canvas")
   return canvas
end

function init(mod)
   local map = yeCreateArray(mod, "game")
   yeCreateString("phs", map, "<type>")
   yePushBack(map, ygGet("phs.resources"), "resources")
   local init = yeCreateArray()
   yeCreateString("phs", init, "name")
   yeCreateFunction("initPhsWidget", init, "callback")
   ywidAddSubType(init)
end
