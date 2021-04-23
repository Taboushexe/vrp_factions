local cfg = {}

cfg.factions = {
   ["SMURD"] = {
		fType = "Lege", -- Acest tip este pentru factiuni guvernamentale
		fSlots = 25, -- sloturi limita
		fRanks = {
			[1] = {rank = "Asistent", salary = 1001},
			[2] = {rank = "Paramedic", salary = 1201},
			[3] = {rank = "Medic", salary = 1401},
			[4] = {rank = "Sef Spital", salary = 1601},
			[5] = {rank = "Director", salary = 2001}
		}
	},
   ["Politie"] = {
	fType = "Lege",
	fSlots = 25,
	fRanks = {
		[1] = {rank = "Cadet", salary = 701},
		[2] = {rank = "Agent", salary = 801},
		[3] = {rank = "Agent Principal", salary = 901},
		[4] = {rank = "Inspector", salary = 1101},
		[5] = {rank = "Inspector Principal", salary = 1201},
		[6] = {rank = "Comisar", salary = 1401},
		[7] = {rank = "Chestor", salary = 1601},
		[8] = {rank = "Chestor General", salary = 2001}
	}
},
	["SRI"] = {
		fSlots = 10,
		fType = "Lege",
		fRanks = {
			[1] = {rank = "SRI", salary = 1001},
			[2] = {rank = "Lider SRI", salary = 1501}
		}
	},

	["Roso"] = {
		fSlots = 8,
		fType = "Mafie",
		fRanks = {
			[1] = {rank = "Membru Roso", salary = 1},
			[2] = {rank = "Lider Roso", salary = 1}
		}
	},

	["AlQaida"] = {
		fSlots = 8,
		fType = "Mafie",
		fRanks = {
			[1] = {rank = "Membru AlQaida", salary = 1},
			[2] = {rank = "Lider AlQaida", salary = 1}
		}
	},

	["Cartelul Medelin"] = {
		fSlots = 8,
		fType = "Mafie",
		fRanks = {
			[1] = {rank = "Membru Cartelul Medelin", salary = 1},
			[2] = {rank = "Lider Cartelul Medelin", salary = 1}
		}
	},

	["Crips"] = {
		fSlots = 15,
		fType = "Mafie",
		fRanks = {
			[1] = {rank = "Membru Crips", salary = 1},
			[2] = {rank = "Lider Crips", salary = 1}
		}
	}
}

return cfg