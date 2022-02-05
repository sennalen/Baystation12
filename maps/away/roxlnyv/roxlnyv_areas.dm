

/datum/map_template/ruin/away_site/roxlnyv/test_site
	name =  "\improper ROXLNYV-class"
	id = "awaysite_roxlnyv_test"
	description = "Independent ice miner."
	suffixes = list("roxlnyv_default.dmm")
	spawn_cost = 190
	player_cost = 0
	accessibility_weight = 10
	shuttles_to_initialise = list(
	)
	area_usage_test_exempted_root_areas = list(/area/roxlnyv)
	apc_test_exempt_areas = list(/area/roxlnyv)
	spawn_weight = 1

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

/obj/effect/overmap/visitable/ship/roxlnyv/test
	name = "Unknown Vessel"
	desc = "Sensor array detects a medium-sized vessel of irregular shape. It is transmitting Terran-origin civilian transponder codes."
	vessel_mass = 6000
	fore_dir = NORTH
	burn_delay = 2 SECONDS
	hide_from_reports = TRUE
	known = 0
	initial_generic_waypoints = list(

	)
	initial_restricted_waypoints = list(

	)


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
	has_gravity = 0

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
