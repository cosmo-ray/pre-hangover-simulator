local Q_KEY = 113

function phsAction(entity, eve, arg)
   print("action !",
	 yeGetString(yeGet(yeGet(yeGet(entity, "resources"), 0), "img")))
   while ywidEveIsEnd(eve) == false do
      if ywidEveType(eve) == YKEY_DOWN then
	 if ywidEveKey(eve) == Q_KEY then
	    yFinishGame()
	 end
      end
      eve = ywidNextEve(eve)
   end
   return YEVE_ACTION
end

function initPhsWidget(entity)
   print("new wid", yeGet(entity, "<type>"))
   yeCreateString("rgba: 0 0 0 255", entity, "background")
   yeCreateFunction("phsAction", entity, "action")
   yeCreateInt(150000, entity, "turn-length")
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
