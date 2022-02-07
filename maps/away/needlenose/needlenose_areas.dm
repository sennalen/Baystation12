
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
	template_flags = TEMPLATE_FLAG_SPAWN_GUARANTEED

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
	name = "Needlenose - Generator Annulus"
	icon_state = "engineering"

/area/needlenose/rads_port
	name = "Needlenose - Port Radiation Collectors"
	icon_state = "pmaint"

/area/needlenose/rads_starboard
	name = "Needlenose - Port Radiation Collectors"
	icon_state = "smaint"

/area/needlenose/pipes
	name = "Needlenose - Gas Routing"
	icon_state = "atmos"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/needlenose/bluespace
	name = "Needlenose - Bluespace Annulus"
	icon_state = "engineering"

/area/needlenose/control
	name = "Needlenose - Primary Control"
	icon_state = "ai_upload"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/needlenose/backstage
	name = "Needlenose - Maintenance Corridor"
	icon_state = "maintcentral"

/area/needlenose/public
	name = "Needlenose - Public Corridor"
	icon_state = "hallA"

/area/needlenose/airlock
	name = "Needlenose - Fore Airlock"
	icon_state = "fmaint"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/needlenose/holo1
	name = "Needlenose - Crew Compartment 1"
	icon_state = "medbay"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/needlenose/holo2
	name = "Needlenose - Crew Compartment 2"
	icon_state = "cafeteria"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/needlenose/holo3
	name = "Needlenose - Crew Compartment 3"
	icon_state = "crew_quarters"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/needlenose/docking
	name = "Needlenose - Reception"
	icon_state = "hangar"

/area/needlenose/pod
	name = "Needlenose - Excursion Bubble"
	icon_state = "shuttle"
	area_flags = AREA_FLAG_EXTERNAL
	has_gravity = 0

/area/needlenose/airlock_pod
	name = "Needlenose - Pod Airlock"
	icon_state = "amaint"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/needlenose/airlock_visitor
	name = "Needlenose - Visitor Airlock"
	icon_state = "pmaint"
	area_flags = AREA_FLAG_RAD_SHIELDED


/area/needlenose/exterior
	name = "Needlenose - Exterior Structure"
	icon_state = "construction"
	area_flags = AREA_FLAG_EXTERNAL
	has_gravity = 0

/area/needlenose/pod_scaffold
	name = "Needlenose - Pod Umbilicals"
	icon_state = "maintcentral"
	area_flags = AREA_FLAG_EXTERNAL
	has_gravity = 0

/area/needlenose/mast
	name = "Needlenose - Sensor Mast"
	icon_state = "maintcentral"
	area_flags = AREA_FLAG_EXTERNAL
	has_gravity = 0