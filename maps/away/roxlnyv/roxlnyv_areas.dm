
/datum/map_template/ruin/away_site/roxlnyv/test_site
	name =  "\improper ROXLNYV-class"
	id = "awaysite_roxlnyv_test"
	description = "Independent ice miner."
	suffixes = list("roxlnyv_default.dmm")
	spawn_cost = 0
	player_cost = 0
	accessibility_weight = 10
	shuttles_to_initialise = list(
	)
	area_usage_test_exempted_root_areas = list(/area/roxlnyv)
	apc_test_exempt_areas = list(/area/roxlnyv)
	spawn_weight = 1
	template_flags = TEMPLATE_FLAG_SPAWN_GUARANTEED

/obj/effect/submap_landmark/joinable_submap/roxlnyv
	name =  "ROXLNYV"
	archetype = /decl/submap_archetype/derelict/roxlnyv

/decl/submap_archetype/derelict/roxlnyv
	descriptor = "Independent ice miner."
	map = "ROXLNYV"
	crew_jobs = list(
		/datum/job/submap/scavver_pilot,
		/datum/job/submap/scavver_doctor,
		/datum/job/submap/scavver_engineer
	)

/obj/effect/overmap/visitable/ship/roxlnyv
	name = "Unknown Vessel"
	desc = "Sensor array detects a medium-sized vessel of irregular shape. It is transmitting Terran-origin civilian transponder codes."
	vessel_mass = 5500
	fore_dir = NORTH
	burn_delay = 2 SECONDS
	hide_from_reports = TRUE
	known = 0
	initial_generic_waypoints = list(

	)
	initial_restricted_waypoints = list(

	)


/obj/effect/overmap/visitable/ship/roxlnyv/test
	name = "ITV Potato"


/area/roxlnyv
	icon = 'maps/away/scavver/scavver_gantry_sprites.dmi'

/area/roxlnyv/bridge
	name = "\improper ROXLNYV - Bridge"
	icon_state = "gantry_up_1"

/area/roxlnyv/corridor
	name = "\improper ROXLNYV - Main Corridor"
	icon_state = "gantry_up_2"

/area/roxlnyv/hydroponics
	name = "\improper ROXLNYV - Hydroponics"
	icon_state = "gantry_down_1"

/area/roxlnyv/atmosphere
	name = "\improper ROXLNYV - Gas Mixing"
	icon_state = "gantry_down_2"

/area/roxlnyv/airlock
	name = "\improper ROXLNYV - Airlock"
	icon_state = "gantry_lift"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/roxlnyv/common
	name = "\improper ROXLNYV - Commons"
	icon_state = "gantry_yacht_up"

/area/roxlnyv/sleeping
	name = "\improper ROXLNYV - Bunk"
	icon_state = "gantry_yacht_down"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/roxlnyv/engineering
	name = "\improper ROXLNYV - Engineering"
	icon_state = "gantry_yacht_up"

/area/roxlnyv/engineering_lockers
	name = "\improper ROXLNYV - Engineering Lockers"
	icon_state = "gantry_hab"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/roxlnyv/communication
	name = "\improper ROXLNYV - Communication"
	icon_state = "gantry_calypso"

/area/roxlnyv/cargo_bay
	name = "\improper ROXLNYV - Cargo Bay"
	icon_state = "gantry_lifepod"

/area/roxlnyv/shuttle
	name = "\improper ROXLNYV - GARRY"
	icon_state = "gantry_pod"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/roxlnyv/scoop
	name = "\improper ROXLNYV - Ramscoop"
	icon_state = "gantry_yacht_down"
	area_flags = AREA_FLAG_EXTERNAL

/area/roxlnyv/radiator
	name = "\improper ROXLNYV - Radiator"
	icon_state = "gantry_yacht_down"
	area_flags = AREA_FLAG_EXTERNAL
	has_gravity = 0

/area/roxlnyv/solar
	name = "\improper ROXLNYV - Solar Array"
	icon_state = "gantry_yacht_down"
	area_flags = AREA_FLAG_EXTERNAL
	has_gravity = FALSE
	requires_power = 1
	always_unpowered = 1
	base_turf = /turf/space

/obj/structure/closet/hydroponics
	name = "botanist's locker"
	req_access = null
	closet_appearance = /decl/closet_appearance/secure_closet/hydroponics

/obj/structure/closet/hydroponics/WillContain()
	return list(
		/obj/item/storage/plants,
		/obj/item/clothing/head/bandana/green,
		/obj/item/material/minihoe,
		/obj/item/material/hatchet,
		/obj/item/wirecutters/clippers,
	)


/obj/machinery/power/apc/roxlnyv
	cell_type = /obj/item/cell/crap
	locked = 0
	coverlocked = 0


/obj/machinery/alarm/roxlnyv
	target_temperature = T0C+16
	breach_pressure = 0.2
	breach_cooldown = 10
	req_access = list()
	locked = 0

/obj/machinery/alarm/roxlnyv/Initialize()
	. = ..()
	TLV["temperature"] = list(T0C-27, T0C+0, T0C+26, T0C+50) // K
	TLV["pressure"] = list(ONE_ATMOSPHERE*0.60,ONE_ATMOSPHERE*0.8,ONE_ATMOSPHERE*1.05,ONE_ATMOSPHERE*1.50) /* kpa */

/obj/machinery/alarm/roxlnyv/hydroponics
	target_temperature = T0C+24

/obj/machinery/alarm/roxlnyv/hydroponics/Initialize()
	. = ..()
	TLV["temperature"] = list(T0C, T0C+5, T0C+50, T0C+66) // K
	TLV["pressure"] = list(ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE,ONE_ATMOSPHERE*1.2,ONE_ATMOSPHERE*1.5) /* kpa */
	TLV[GAS_CO2] = list(0, 0.2, 10, 10) // Partial pressure, kpa
	TLV[GAS_OXYGEN] = list(10, 16, 100, 140) // Partial pressure, kpa

