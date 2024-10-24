local function tryTests(Scheduler)
    local function test(name, a, b)
        local inp = a:serialize(true)
        local out = textutils.serializeJSON(b)
        local result = #inp == #out
        if result then
            print("Passed: " .. name)
        else
            local errmsg = "Failed test!! - " .. name ..
                "\nGot: " .. inp .. "\nExpected: " .. out .. "\n"
            local f = fs.open("test.err", "w")
            f.write(errmsg)
            f.close()
            textutils.pagedPrint(errmsg)
            error("Failed test: " .. name)
        end
    end

    test("Basic layout", Scheduler.new(false), { cyclic = false, entries = {} })
    test("Basic layout (cyclic)", Scheduler.new(true), { cyclic = true, entries = {} })

    test("Official example", Scheduler.new(true)
        :to("Station 1")
        :wait(5):powered()
        :OR():time(14, 0, "daily"), {
            cyclic = true,
            entries = {
                {
                    instruction = {
                        id = "create:destination",
                        data = {
                            text = "Station 1",
                        },
                    },
                    conditions = {
                        {
                            {
                                id = "create:delay",
                                data = {
                                    value = 5,
                                    time_unit = 1,
                                },
                            },
                            {
                                id = "create:powered",
                                data = {},
                            },
                        },
                        {
                            {
                                id = "create:time_of_day",
                                data = {
                                    rotation = 0,
                                    hour = 14,
                                    minute = 0,
                                },
                            },
                        },
                    },
                },
            },
        })

    -- https://github.com/SaharaRailways/Sahara/blob/main/camel/server.lua
    test("GitHub search result 1", Scheduler.new(false)
        :to("stationName")
        :cargoidle(5):wait(10, "s") -- this intentionally uses 's' instead of nil to check if that works
        :to("warehouse")
        :wait(10), {
            cyclic = false,
            entries = {
                {
                    instruction = {
                        id = "create:destination",
                        data = {
                            text = "stationName",
                        },
                    },
                    conditions = {
                        {
                            {
                                id = "create:idle",
                                data = {
                                    value = 5,
                                    time_unit = 1,
                                },
                            },
                            {
                                id = "create:delay",
                                data = {
                                    value = 10,
                                    time_unit = 1,
                                },
                            },
                        },
                    },
                },
                {
                    instruction = {
                        id = "create:destination",
                        data = {
                            text = "warehouse",
                        },
                    },
                    conditions = {
                        {
                            {
                                id = "create:delay",
                                data = {
                                    value = 10,
                                    time_unit = 1,
                                },
                            },
                        },
                    },
                },
            },
        })

    -- https://github.com/tizu69/mtn/blob/main/binaries/podzuServerThing.lua
    test("GitHub search result 2", Scheduler.new(false)
        :to("from")
        :wait(1, "m")
        :OR():passengers(">", 1):wait(5)
        :to("to")
        :passengers("=", 0):wait(5)
        :to("station.getStationName()")
        :powered(), {
            cyclic = false,
            entries = {
                {
                    instruction = {
                        id = "create:destination",
                        data = {
                            text = "from",
                        },
                    },
                    conditions = {
                        {
                            {
                                id = "create:delay",
                                data = {
                                    value = 1,
                                    time_unit = 2,
                                },
                            },
                        },
                        {
                            {
                                id = "create:player_count",
                                data = {
                                    count = 1,
                                    exact = 1,
                                },
                            },
                            {
                                id = "create:delay",
                                data = {
                                    value = 5,
                                    time_unit = 1,
                                },
                            },
                        },
                    },
                },
                {
                    instruction = {
                        id = "create:destination",
                        data = {
                            text = "to",
                        },
                    },
                    conditions = {
                        {
                            {
                                id = "create:player_count",
                                data = {
                                    count = 0,
                                    exact = 0,
                                },
                            },
                            {
                                id = "create:delay",
                                data = {
                                    value = 5,
                                    time_unit = 1,
                                },
                            },
                        },
                    },
                },
                {
                    instruction = {
                        id = "create:destination",
                        data = {
                            text = "station.getStationName()",
                        },
                    },
                    conditions = {
                        {
                            {
                                id = "create:powered",
                                data = {}
                            },
                        },
                    },
                }
            }
        })
end

tryTests(require "scheduler")
tryTests(require "schedulermin")
