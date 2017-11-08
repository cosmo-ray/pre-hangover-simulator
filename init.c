/*
**Copyright (C) 2016 Matthias Gatto
**
**This program is free software: you can redistribute it and/or modify
**it under the terms of the GNU Lesser General Public License as published by
**the Free Software Foundation, either version 3 of the License, or
**(at your option) any later version.
**
**This program is distributed in the hope that it will be useful,
**but WITHOUT ANY WARRANTY; without even the implied warranty of
**MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**GNU General Public License for more details.
**
**You should have received a copy of the GNU Lesser General Public License
**along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <yirl/game.h>
#include <yirl/menu.h>
#include <yirl/map.h>
#include <yirl/container.h>
#include <yirl/rect.h>
#include <yirl/text-screen.h>

void *init(int nbArgs, void **args)
{
  Entity *mod = args[0];
  Entity *init;
  Entity *map = yeCreateArray(mod, "game");

  yeCreateString("phs", map, "<type>");
  yePushBack(map, yeGetByStr(mod, "resources.map"), "resources");

  yeCreateFunction("scoreInit", ygGetManager("tcc"), mod, "scoreInit");
  init = yeCreateArray(NULL, NULL);
  yeCreateString("vapz", init, "name");
  yeCreateFunction("vapzInit", ygGetManager("tcc"), init, "callback");
  ywidAddSubType(init);
  return NULL;
}


void *vapzInit(int nbArgs, void **args)
{
  return NULL;
}
