-- Run with: tests/run-eris-test.sh
-- Restore a thread before the closure that shares its open local variable.
-- Stop collection to isolate reference linking from Eris prototype GC issues.
collectgarbage("stop")
local perms = {[_G] = "globals", [coroutine.yield] = "yield"}
local unperms = {globals = _G, yield = coroutine.yield}
for order = 1, 2 do
  local change
  local thread = coroutine.create(function()
    local value = 1
    change = function() value = value + 10 end
    coroutine.yield()
    value = value + 1
    coroutine.yield(value)
  end)
  assert(coroutine.resume(thread))
  local root = order == 1 and {thread, change} or {change, thread}
  local saved = eris.persist(perms, root)
  local restored = eris.unpersist(unperms, saved)
  local restoredThread = restored[order == 1 and 1 or 2]
  local restoredChange = restored[order == 1 and 2 or 1]
  restoredChange()
  local ok, value = coroutine.resume(restoredThread)
  assert(ok and value == 12, "restored closure lost its shared open upvalue")
end
collectgarbage("restart")
print("Eris open-upvalue tests passed")
