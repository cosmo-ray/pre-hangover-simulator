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

function phsAction(entity, eve, arg)
   local objs = yeGet(entity, "objs")
   local endRoad = yeGetInt(yeGet(entity, "road-end-idx"))

   print("action !",
	 yeGetString(yeGet(yeGet(yeGet(entity, "resources"), 0), "img")),
	 yeGetInt(yeGet(entity, "road-end-idx")))
   while ywidEveIsEnd(eve) == false do
      if ywidEveType(eve) == YKEY_DOWN then
	 if ywidEveKey(eve) == Q_KEY then
	    yFinishGame()
	 end
      end
      eve = ywidNextEve(eve)
   end

   local idx = 0
   local pos = ywPosCreate(0, BASE_SCROLL_SPEED)
   while (idx < endRoad) do
      ywCanvasMoveObjByIdx(entity, idx, pos)
      idx = idx + 1
      print (idx)
--      if (idx % 70 == 0) then
	 --print(idx)
	 --createStreetLine(entity, 0, objs)
--      end
   end
   yeDestroy(pos)
   return YEVE_ACTION
end

function initPhsWidget(entity)
   print("new wid", yeGet(entity, "<type>"))
   yeCreateString("rgba: 0 0 0 255", entity, "background")
   yeCreateFunction("phsAction", entity, "action")
   yeCreateInt(150000, entity, "turn-length")
   local objs = yeCreateArray(entity, "objs");

   local screenH = 480
   local idx = 0;
   while idx < screenH do
      createStreetLine(entity, idx, objs)
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
