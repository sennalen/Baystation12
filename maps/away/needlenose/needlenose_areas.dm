
/datum/map_template/ruin/away_site/needlenose/test_site
	name =  "\improper Needlenose class"
	id = "awaysite_needlenose_test"
	description = "State-of-the art and mysterious."
	suffixes = list("needlenose_default.dmm")
	spawn_cost = 0
	player_cost = 0
	accessibility_weight = 10
	shuttles_to_initialise = list(
	)
	area_usage_test_exempted_root_areas = list(/area/needlenose)
	apc_test_exempt_areas = list(/area/needlenose)
	spawn_weight = 1

/obj/effect/submap_landmark/joinable_submap/needlenose
	name =  "Needlenose"
	archetype = /decl/submap_archetype/derelict/needlenose

/decl/submap_archetype/derelict/needlenose
	descriptor = "State-of-the art and mysterious."
	map = "Needlenose"
	crew_jobs = list(
		/datum/job/submap/scavver_pilot,
		/datum/job/submap/scavver_doctor,
		/datum/job/submap/scavver_engineer
	)

/obj/effect/overmap/visitable/ship/needlenose/test
	name = "Unknown Vessel"
	desc = "Sensor array detects an elongated tube emitting strong EM radiation in a broad spectrum."
	vessel_mass = 4000
	fore_dir = WEST
	burn_delay = 1 SECONDS
	hide_from_reports = TRUE
	known = 0
	initial_generic_waypoints = list(

	)
	initial_restricted_waypoints = list(

	)


/area/needlenose
	name = "Needlenose"


/area/needlenose/power
	name = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA Power Room AAAAAA"
	icon_state = "storage"


/area/needlenose/intensive
	name = "Intensive"
	icon_state = "surgery"

/area/needlenose/physician1
	name = "Physician's Office"
	icon_state = "surgery"
