--- go: coroutine helper
--- NOT MEANT FOR PRODUCTION USE.

local expect = require("cc.expect").expect

if _ENV.go then return end

local goroutines = {}

--- Start a goroutine.
--- @param func function The function to use for the coroutine
--- @return function abort Call to stop the goroutine early (can be discarded with no side effects)
function _ENV.go(func)
    expect(1, func, "function")
    local tbl = { f = coroutine.create(func), t = nil }
    table.insert(goroutines, 1, tbl)
    return function()
        tbl.f = coroutine.create(function() end)
    end
end

--- Runs the goroutine loop until all goroutines stop, or the catcher returns true.
--- @param pull function The handler, like `os.pullEvent`.
--- @param catcher? (fun(goroutines: {f:function,t:string?}[], ev: table): true?) If this returns true, stops the loop.
return function(pull, catcher)
    expect(1, pull, "function")
    expect(2, catcher, "function", "nil")

    if #goroutines == 0 then error("No goroutines to run") end

    os.queueEvent("go:start")
    while true do
        local ev = { pull() }
        for id = #goroutines, 1, -1 do
            local v = goroutines[id]
            if coroutine.status(v.f) == "suspended" and (v.t == nil or v.t == ev[1]) then
                local succ, next = coroutine.resume(v.f, table.unpack(ev))
                if succ then
                    v.t = next
                else
                    printError("<go>" .. tostring(next))
                    table.remove(goroutines, id)
                end
            end
            if coroutine.status(v.f) == "dead" then
                table.remove(goroutines, id)
            end
        end

        if #goroutines == 0 then break end
        if catcher and catcher(goroutines, ev) == true then break end
    end

    _ENV.go = nil
end
