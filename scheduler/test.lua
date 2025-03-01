local function tryTests(schedulername)
	local Scheduler = require(schedulername)
	local function test(name, a, b)
		local inp = a:serialize(true)
		local out = textutils.serializeJSON(b)
		local result = #inp == #out
		if result then
			print(schedulername .. ": Passed: " .. name)
		else
			local errmsg = schedulername .. ": Failed test!! - " .. name ..
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

	do
		local s = Scheduler.new(true)

		s:to("Main Station")
			:wait(10, "m")
			:OR():time(14, 30, "hourly")
			:OR():fluid("minecraft:water_bucket", ">", 5)
			:OR():item("minecraft:iron_ingot", "<", 100)
			:OR():getlink("minecraft:red_wool", "minecraft:red_wool", true)
			:OR():passengers("=", 2)
			:OR():cargoidle(15, "s")
			:OR():unloaded()
			:OR():powered()
			:OR():loaded()
			:OR():waitdynamic(10, 5, "s")
			:OR():energy(">", 1000)

		s:to("AND Station")
			:wait(10, "m")
			:time(14, 30, "hourly")
			:fluid("minecraft:water_bucket", ">", 5)
			:item("minecraft:iron_ingot", "<", 100)
			:getlink("minecraft:red_wool", "minecraft:red_wool", true)
			:passengers("=", 2)
			:cargoidle(15, "s")
			:unloaded()
			:powered()
			:loaded()
			:waitdynamic(10, 5, "s")
			:energy(">", 1000)

		s:rename("Express Line")
		s:section("Group A", "Line 1", true, true)
		s:throttle(75)
		s:through("Next Station")
		s:setlink("minecraft:red_wool", "minecraft:red_wool", 15)
		s:fixtimings()

		test("All the things", s, {
			cyclic = true,
			entries = { {
				instruction = {
					id = "create:destination",
					data = {
						text = "Main Station"
					}
				},
				conditions = { { {
					id = "create:delay",
					data = {
						value = 10,
						time_unit = 2
					}
				} }, { {
					id = "create:time_of_day",
					data = {
						hour = 14,
						minute = 30,
						rotation = 6
					}
				} }, { {
					id = "create:fluid_threshold",
					data = {
						operator = 0,
						measure = 0,
						threshold = "5",
						bucket = {
							id = "minecraft:water_bucket",
							count = 1
						}
					}
				} }, { {
					id = "create:item_threshold",
					data = {
						operator = 1,
						measure = 0,
						threshold = "100",
						bucket = {
							id = "minecraft:iron_ingot",
							count = 1
						}
					}
				} }, { {
					id = "create:redstone_link",
					data = {
						frequency = { {
							id = "minecraft:red_wool",
							count = 1
						}, {
							id = "minecraft:red_wool",
							count = 1
						} },
						inverted = 0
					}
				} }, { {
					id = "create:player_count",
					data = {
						count = 2,
						exact = 0
					}
				} }, { {
					id = "create:idle",
					data = {
						value = 15,
						time_unit = 1
					}
				} }, { {
					id = "create:unloaded",
					data = {}
				} }, { {
					id = "create:powered",
					data = {}
				} }, { {
					id = "railways:loaded",
					data = {}
				} }, { {
					id = "createrailwaysnavigator:dynamic_delay",
					data = {
						value = 10,
						min = 5,
						time_unit = 1
					}
				} }, { {
					id = "createaddition:energy_threshold",
					data = {
						operator = 0,
						measure = 0,
						threshold = 1000
					}
				} } }
			}, {
				instruction = {
					id = "create:destination",
					data = {
						text = "AND Station"
					}
				},
				conditions = { { {
					id = "create:delay",
					data = {
						value = 10,
						time_unit = 2
					}
				}, {
					id = "create:time_of_day",
					data = {
						hour = 14,
						minute = 30,
						rotation = 6
					}
				}, {
					id = "create:fluid_threshold",
					data = {
						operator = 0,
						measure = 0,
						threshold = "5",
						bucket = {
							id = "minecraft:water_bucket",
							count = 1
						}
					}
				}, {
					id = "create:item_threshold",
					data = {
						operator = 1,
						measure = 0,
						threshold = "100",
						bucket = {
							id = "minecraft:iron_ingot",
							count = 1
						}
					}
				}, {
					id = "create:redstone_link",
					data = {
						frequency = { {
							id = "minecraft:red_wool",
							count = 1
						}, {
							id = "minecraft:red_wool",
							count = 1
						} },
						inverted = 0
					}
				}, {
					id = "create:player_count",
					data = {
						count = 2,
						exact = 0
					}
				}, {
					id = "create:idle",
					data = {
						value = 15,
						time_unit = 1
					}
				}, {
					id = "create:unloaded",
					data = {}
				}, {
					id = "create:powered",
					data = {}
				}, {
					id = "railways:loaded",
					data = {}
				}, {
					id = "createrailwaysnavigator:dynamic_delay",
					data = {
						value = 10,
						min = 5,
						time_unit = 1
					}
				}, {
					id = "createaddition:energy_threshold",
					data = {
						operator = 0,
						measure = 0,
						threshold = 1000
					}
				} } }
			}, {
				instruction = {
					id = "create:rename",
					data = {
						text = "Express Line"
					}
				},
				conditions = {}
			}, {
				instruction = {
					id = "createrailwaysnavigator:travel_section",
					data = {
						usable = true,
						train_group = "Group A",
						include_previous_station = true,
						train_line = "Line 1"
					}
				},
				conditions = {}
			}, {
				instruction = {
					id = "create:throttle",
					data = {
						value = 75
					}
				},
				conditions = {}
			}, {
				instruction = {
					id = "railways:waypoint_destination",
					data = {
						text = "Next Station"
					}
				},
				conditions = {}
			}, {
				instruction = {
					id = "railways:redstone_link",
					data = {
						frequency = { {
							id = "minecraft:red_wool",
							count = 1
						}, {
							id = "minecraft:red_wool",
							count = 1
						} },
						power = 15
					}
				},
				conditions = {}
			}, {
				instruction = {
					id = "createrailwaysnavigator:reset_timings",
					data = {}
				},
				conditions = {}
			} }
		})
	end
end

tryTests("scheduler")
tryTests("schedulermin")
