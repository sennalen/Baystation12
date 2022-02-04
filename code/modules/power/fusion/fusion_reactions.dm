var/list/fusion_reactions

var/list/thermal_fusion_reactions


/decl/fusion_reaction
	var/p_react = "" // Primary reactant.
	var/s_react = "" // Secondary reactant.
	var/minimum_energy_level = 1
	var/energy_consumption = 0
	var/energy_production = 0
	var/radiation = 0
	var/instability = 0
	var/list/products = list()
	var/minimum_reaction_temperature = 100
	var/priority = 100

/decl/fusion_reaction/proc/handle_reaction_special(var/obj/effect/fusion_em_field/holder)
	return 0

proc/get_fusion_reaction(var/p_react, var/s_react, var/m_energy)
	if(!fusion_reactions)
		fusion_reactions = list()
		for(var/rtype in typesof(/decl/fusion_reaction) - /decl/fusion_reaction)
			var/decl/fusion_reaction/cur_reaction = new rtype()
			if(!fusion_reactions[cur_reaction.p_react])
				fusion_reactions[cur_reaction.p_react] = list()
			fusion_reactions[cur_reaction.p_react][cur_reaction.s_react] = cur_reaction
			if(!fusion_reactions[cur_reaction.s_react])
				fusion_reactions[cur_reaction.s_react] = list()
			fusion_reactions[cur_reaction.s_react][cur_reaction.p_react] = cur_reaction

	if(list_find(fusion_reactions, p_react))
		var/list/secondary_reactions = fusion_reactions[p_react]
		if(list_find(secondary_reactions, s_react))
			return fusion_reactions[p_react][s_react]



// Material fuels
//  deuterium
//  tritium
//  phoron
//  supermatter

// Gaseous/reagent fuels
// hydrogen
//  helium
//  lithium
//  boron

// Basic power production reactions.
// This is not necessarily realistic, but it makes a basic failure more spectacular.
/decl/fusion_reaction/hydrogen_hydrogen
	p_react = GAS_HYDROGEN
	s_react = GAS_HYDROGEN
	energy_consumption = 1
	energy_production = 2
	products = list(GAS_HELIUM = 1)
	priority = 10

/decl/fusion_reaction/deuterium_deuterium
	p_react = GAS_DEUTERIUM
	s_react = GAS_DEUTERIUM
	energy_consumption = 1
	energy_production = 2
	priority = 0

// Advanced production reactions (todo)
/decl/fusion_reaction/deuterium_helium
	p_react = GAS_DEUTERIUM
	s_react = GAS_HELIUM
	energy_consumption = 1
	energy_production = 5
	radiation = 2

/decl/fusion_reaction/deuterium_tritium
	p_react = GAS_DEUTERIUM
	s_react = GAS_TRITIUM
	energy_consumption = 1
	energy_production = 1
	products = list(GAS_HELIUM = 1)
	instability = 0.5
	radiation = 3

/decl/fusion_reaction/deuterium_lithium
	p_react = GAS_DEUTERIUM
	s_react = "lithium"
	energy_consumption = 2
	energy_production = 0
	radiation = 3
	products = list(GAS_TRITIUM= 1)
	instability = 1

// Unideal/material production reactions
/decl/fusion_reaction/oxygen_oxygen
	p_react = GAS_OXYGEN
	s_react = GAS_OXYGEN
	energy_consumption = 10
	energy_production = 0
	instability = 5
	radiation = 5
	products = list("silicon"= 1)

/decl/fusion_reaction/iron_iron
	p_react = "iron"
	s_react = "iron"
	products = list("silver" = 10, "gold" = 10, "platinum" = 10) // Not realistic but w/e
	energy_consumption = 10
	energy_production = 0
	instability = 2
	minimum_reaction_temperature = 10000

/decl/fusion_reaction/phoron_hydrogen
	p_react = GAS_HYDROGEN
	s_react = GAS_PHORON
	energy_consumption = 10
	energy_production = 0
	instability = 5
	products = list("mhydrogen" = 1)
	minimum_reaction_temperature = 8000

// VERY UNIDEAL REACTIONS.
/decl/fusion_reaction/phoron_supermatter
	p_react = "supermatter"
	s_react = GAS_PHORON
	energy_consumption = 0
	energy_production = 5
	radiation = 40
	instability = 20

/decl/fusion_reaction/phoron_supermatter/handle_reaction_special(var/obj/effect/fusion_em_field/holder)

	wormhole_event(GetConnectedZlevels(holder))

	var/turf/origin = get_turf(holder)
	holder.Rupture()
	qdel(holder)
	var/radiation_level = rand(100, 200)

	// Copied from the SM for proof of concept. //Not any more --Cirra //Use the whole z proc --Leshana
	SSradiation.z_radiate(locate(1, 1, holder.z), radiation_level, 1)

	for(var/mob/living/mob in GLOB.living_mob_list_)
		var/turf/T = get_turf(mob)
		if(T && (holder.z == T.z))
			if(istype(mob, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = mob
				H.hallucination(rand(100,150), 51)

	for(var/obj/machinery/fusion_fuel_injector/I in range(world.view, origin))
		if(I.cur_assembly && I.cur_assembly.fuel_type == MATERIAL_SUPERMATTER)
			explosion(get_turf(I), 1, 2, 3)
			spawn(5)
				if(I && I.loc)
					qdel(I)

	sleep(5)
	explosion(origin, 1, 2, 5)

	return 1


// High end reactions.
/decl/fusion_reaction/boron_hydrogen
	p_react = "boron"
	s_react = GAS_HYDROGEN
	minimum_energy_level = 15000
	energy_consumption = 3
	energy_production = 12
	radiation = 3
	instability = 2.5



//tweaked reactions for the thermal reactor
//not a subclass so the existing code doesn't iterate over these

/decl/thermal_fusion_reaction
	var/list/reagents = list()
	var/list/products = list()
	var/minimum_temperature = 0 //K
	var/base_rate = 0.0
	var/temperature_coeff = 0.0
	var/temperature_quad = 0.0
	var/density_coeff = 0.0
	var/energy_delta = 0 //MeV
	var/release_always = FALSE //Always do this 100% when turning back into XGM gas
	var/release_only = FALSE //Only do this when turning back into XGM gas

proc/get_thermal_fusion_reactions()
	if(!thermal_fusion_reactions)
		thermal_fusion_reactions = list()
		for(var/rtype in typesof(/decl/thermal_fusion_reaction))
			LAZYADD(thermal_fusion_reactions, rtype)

	return thermal_fusion_reactions


/decl/thermal_fusion_reaction/free_neutron
	reagents = list("neutron")
	energy_delta = 14.1
	products = list()
	release_always = TRUE
	base_rate = 0.999

/decl/thermal_fusion_reaction/beta_decay
	reagents = list("neutron")
	energy_delta = 0.78
	products = list(GAS_HYDROGEN)
	base_rate = 1.0/877.0

/decl/thermal_fusion_reaction/deuterium_xgm
	reagents = list("deuterium")
	energy_delta = 12e-6
	products = list(GAS_HYDROGEN)
	release_always = TRUE
	release_only = TRUE

/decl/thermal_fusion_reaction/tritium_xgm
	reagents = list("tritium")
	energy_delta = 24e-6
	products = list(GAS_HYDROGEN)
	release_always = TRUE
	release_only = TRUE

/decl/thermal_fusion_reaction/helium3_xgm
	reagents = list("helium3")
	energy_delta = 12e-6
	products = list(GAS_HELIUM)
	release_always = TRUE
	release_only = TRUE

/decl/thermal_fusion_reaction/hydrogen_hydrogen
	reagents = list(GAS_HYDROGEN, GAS_HYDROGEN)
	energy_delta = 1.44
	products = list("deuterium")
	minimum_temperature = 14e6
	temperature_coeff = 1e-8

/decl/thermal_fusion_reaction/hydrogen_deuterium
	reagents = list(GAS_HYDROGEN, "deuterium")
	energy_delta = 5.49
	products = list("helium3")
	minimum_temperature = 1e6
	temperature_coeff = 1e-6

/decl/thermal_fusion_reaction/deuterium_deuterium
	reagents = list("deuterium", "deuterium")
	energy_delta = 3.27
	products = list("helium3", "neutron")
	minimum_temperature = 1e6
	temperature_coeff = 1e-6
	temperature_quad = -1e-10

/decl/thermal_fusion_reaction/deuterium_deuterium_alt
	reagents = list("deuterium", "deuterium")
	energy_delta = 4.03
	products = list("tritium", GAS_HYDROGEN)
	minimum_temperature = 1e6
	temperature_coeff = 1e-6

/decl/thermal_fusion_reaction/deuterium_tritium
	reagents = list("deuterium", "tritium")
	energy_delta = 17.59
	products = list("helium4", "neutron")
	minimum_temperature = 1e6
	temperature_coeff = 1e-6
	temperature_quad = -6e-8

/decl/thermal_fusion_reaction/tritium_tritium
	reagents = list("tritium", "tritium")
	energy_delta = 11.3
	products = list("helium4", "neutron", "neutron")
	minimum_temperature = 1e6
	temperature_coeff = 0.8e-6
	temperature_quad = -1e-10

/decl/thermal_fusion_reaction/deuterium_helium3
	reagents = list("deuterium", "helium3")
	energy_delta = 18.3
	products = list(GAS_HELIUM, GAS_HYDROGEN)
	minimum_temperature = 5e6
	temperature_coeff = 4.26e-7
	temperature_quad = -2e-9

/decl/thermal_fusion_reaction/tritium_helium3
	reagents = list("tritium", "helium3")
	energy_delta = 18.3
	products = list(GAS_HELIUM, GAS_HYDROGEN)
	minimum_temperature = 5e6
	temperature_coeff = 4.26e-7
	temperature_quad = -2e-9

/decl/thermal_fusion_reaction/helium3_helium3
	reagents = list("helium3", "helium3")
	energy_delta = 12.86
	products = list(GAS_HELIUM, GAS_HYDROGEN, GAS_HYDROGEN)
	minimum_temperature = 5e6
	temperature_coeff = 4.26e-7
	temperature_quad = -2e-9

/decl/thermal_fusion_reaction/helium_helium
	reagents = list(GAS_HELIUM, GAS_HELIUM)
	energy_delta = 7.28
	products = list(GAS_OXYGEN)
	minimum_temperature = 10e8
	temperature_coeff = 1e-8