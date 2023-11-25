local _, Plus = ...

Plus.PlusOneOptions = {
	type = "group",
	args = {
		minimap = { 
			name = "Minimap Icon",
			order = 7,
			desc = "Enables / disables the Minimap Icon",
			type = "toggle",
			set = function(info,val) Plus.One:MinimapButton() end,
			get = function(info) return not Plus.One.db.profile.minimap.hide end,
		}, 
		rollDuration = { 
			name = "Loot Roll Duration",
			order = 1,
			desc = "Number of seconds a loot roll should take",
			type = "input",
			set = function(info,val) Plus.One.db.profile.rollDuration = tonumber(val) end,
			get = function(info) return tostring(Plus.One.db.profile.rollDuration) end,
			pattern = "^(%d*)$",
			usage = "Input must be only whole numbers."
		},
		SR = {
			name = "Soft Reserve Options",
			order = 4,
			type = "group",
			inline = true,
			args = {
				trackSR = { 
					name = "Track",
					order = 2,
					desc = "Should Soft Reserve Rolls be tracked",
					type = "toggle",
					set = function(info,val) Plus.One.db.profile.trackSR = val end,
					get = function(info) return Plus.One.db.profile.trackSR end,
				},
				rollSR = { 
					name = "Max Roll value",
					order = 1,
					desc = "Roll value for Soft Reserve, /roll 1 <val>",
					type = "input",
					set = function(info,val) Plus.One.db.profile.rollSR = tonumber(val) end,
					get = function(info) return tostring(Plus.One.db.profile.rollSR) end,
					pattern = "^(%d*)$",
					usage = "Input must be only whole numbers."
				},
			}
		},
		MS = {
			name = "Mainspec Options",
			order = 3,
			type = "group",
			inline = true,
			args = {
				rollSR = { 
					name = "Max Roll value",
					desc = "Roll value for Mainspec, /roll 1 <val>",
					type = "input",
					set = function(info,val) Plus.One.db.profile.rollMS = tonumber(val) end,
					get = function(info) return tostring(Plus.One.db.profile.rollMS) end,
					pattern = "^(%d*)$",
					usage = "Input must be only whole numbers."
				},
			}
		},
		OS = {
			name = "Offspec Options",
			order = 5,
			type = "group",
			inline = true,
			args = {
				trackSR = { 
					name = "Track",
					order = 2,
					desc = "Should Offspec Rolls be tracked",
					type = "toggle",
					set = function(info,val) Plus.One.db.profile.trackOS = val end,
					get = function(info) return Plus.One.db.profile.trackOS end,
				},
				rollSR = { 
					name = "Max Roll value",
					order = 1,
					desc = "Roll value for Offspec, /roll 1 <val>",
					type = "input",
					set = function(info,val) Plus.One.db.profile.rollOS = tonumber(val) end,
					get = function(info) return tostring(Plus.One.db.profile.rollOS) end,
					pattern = "^(%d*)$",
					usage = "Input must be only whole numbers."
				},
			}
		},
		trackedPlayers = {
			name = "Reset Tracked Players",
			order = 6,
			desc = "Will reset all tracked +1s",
			type = "execute",
			func = function() Plus.One.db.profile.trackedPlayers = {} end,
			confirm = true
		},
		minquality = {
			name = "Minimum Item Quality",
			order = 2,
			desc = "The minimum item quality to show in loot tracker",
			type = "select",
			values = {
				[2] = "|cFF1eff00Uncommon|r",
				[3] = "|cFF0070ddRare|r",
				[4] = "|cFFa335eeEpic|r",
				[5] = "|cFFff8000Legendary|r"
			},
			sorting = {2, 3, 4, 5},
			set = function(info,val) Plus.One.db.profile.minquality = val end,
			get = function(info) return Plus.One.db.profile.minquality end,
			style = "dropdown",
		},
	}
}

