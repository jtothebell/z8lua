#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include <cstdio>

int main(int argc, char** argv) {
    if (argc != 2) return 2;
    lua_State* state = luaL_newstate();
    luaL_openlibs(state);
    const int result = luaL_dofile(state, argv[1]);
    if (result) std::fprintf(stderr, "%s\n", lua_tostring(state, -1));
    lua_close(state);
    return result ? 1 : 0;
}
