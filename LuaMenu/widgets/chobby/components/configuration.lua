Configuration = LCS.class{}

VFS.Include("libs/liblobby/lobby/json.lua")

LIB_LOBBY_DIRNAME = "libs/liblobby/lobby/"
MINIMAP_THUMB_DOWNLOAD_DIR = "LuaMenu/Images/MinimapThumbnails"


-- all configuration attribute changes should use the :Set*Attribute*() and :Get*Attribute*() methods in order to assure proper functionality
function Configuration:init()
	self.listeners = {}

	local fileConfig
	if VFS.FileExists(LUA_DIRNAME .. "configs/liblobby_configuration.lua") then
		fileConfig = VFS.Include(LUA_DIRNAME .. "configs/liblobby_configuration.lua", nil, VFS.RAW_FIRST)
	end
	if not fileConfig.game then
		Spring.Log("Chobby", LOG.WARNING, "Missing game in chobby_config.json file.")
		-- FIXME: This will be changed to "generic" in future versions.
		fileConfig.game = "zk"
	end

	--self.serverAddress = "localhost"
	self.serverAddress = WG.Server.address
	self.serverPort =  WG.Server.port

	local realWidth, realHeight = Spring.Orig.GetViewSizes()
	self.uiScale = math.floor(math.max(1, realHeight/950))
	self.defaultUiScale = self.uiScale
	self.maxUiScale = math.max(2, realWidth/1000)
	self.minUiScale = math.min(0.5, realWidth/4000)
	WG.uiScale = self.uiScale

	self.userListWidth = 205 -- Main user list width. Possibly configurable in the future.
	self.chatMaxNameLength = 185 -- Pixels
	self.statusMaxNameLength = 185
	self.friendMaxNameLength = 290
	self.notificationMaxNameLength = 230
	self.steamOverlayEnablable = true
	self.useChatTabBadges = false

	self.userName = false
	self.suggestedNameFromSteam = false
	self.password = false
	self.autoLogin = true
	self.firstLoginEver = true
	self.canAuthenticateWithSteam = false
	self.wantAuthenticateWithSteam = true
	self.useSteamBrowser = true
	self.steamLinkComplete = false
	self.alreadySeenFactionPopup4 = false
	self.firstBattleStarted = false
	self.hideWelcomeMessage = false
	self.lobbyTimeoutTime = 60 -- Seconds

	self.battleFilterPassworded3 = false
	self.battleFilterNonFriend = false
	self.battleFilterRunning = false

	self.manualBorderless = {
		game = {},
		lobby = {},
	}
	self.manualFullscreen = {
		game = {},
		lobby = {},
	}
	self.manualWindowed = {
		game = {},
		lobby = {},
	}

	self.settingsToSendExternal = {
		'HardwareCursor',
		'ShadowMapSize',
		'GroundDecals',
		'MaxParticles',
		'UnitLodDist',
		'UnitIconDist',
		'AdvUnitShading',
		'snd_volmaster',
		'snd_volbattle',
		'snd_volui',
		'snd_volunitreply',
		'snd_volgeneral',
	}

	self.ignoreLevel = false

	self.errorColor = "\255\255\0\0"
	self.warningColor = "\255\255\255\0"
	self.normalColor = "\255\255\255\255"
	self.successColor = "\255\0\255\0"
	self.partialColor = "\255\190\210\50"
	self.selectedColor = "\255\99\184\255"
	self.highlightedColor = "\255\125\255\0"
	self.meColor = "\255\0\190\190"

	self.moderatorColor = {0.68, 0.78, 1, 1}
	self.founderColor = {0.7, 1, 0.65, 1}
	self.ignoredUserNameColor = {0.6, 0.6, 0.6, 1}
	self.userNameColor = {1, 1, 1, 1}

	self.buttonFocusColor = {0.54,0.72,1,0.3}
	self.buttonSelectedColor = {0.54,0.72,1,0.95}--{1.0, 1.0, 1.0, 1.0}

	self.loadLocalWidgets = false
	self.displayBots = false
	self.displayBadEngines3 = true
	self.allEnginesRunnable = true
	self.doNotSetAnySpringSettings = false
	self.agressivelySetBorderlessWindowed = false

	self.useWrongEngine = false
	self.multiplayerLaunchNewSpring = false
	self.myAccountID = false
	self.lastAddedAiName = false

	self.noNaiveConfigOverride = {
		settingsMenuValues = true,
	}

	self.battleTypeToName = {
		[5] = "cooperative",
		[6] = "team",
		[3] = "oneVsOne",
		[4] = "freeForAll",
		[0] = "custom",
	}
	self.battleTypeToHumanName = {
		[5] = "Coop",
		[6] = "Team",
		[3] = "1v1",
		[4] = "FFA",
		[0] = "Custom",
	}

	-- Do not ask again tests.
	self.confirmation_mainMenuFromBattle = false
	self.confirmation_battleFromBattle = false

	self.leaveMultiplayerOnMainMenu = false

	self.backConfirmation = {
		multiplayer = {
			self.leaveMultiplayerOnMainMenu and {
				doNotAskAgainKey = "confirmation_mainMenuFromBattle",
				question = "You are in a battle and will leave it if you return to the main menu. Are you sure you want to return to the main menu?",
				testFunction = function ()
					local battleID = lobby:GetMyBattleID()
					if not battleID then
						return false
					end
					if self.showMatchMakerBattles then
						return true
					end
					local battle = lobby:GetBattle(battleID)
					return (battle and not battle.isMatchMaker) or false
				end
			} or nil
		},
		singleplayer = {
		}
	}
	local gameConfPath = LUA_DIRNAME .. "configs/gameConfig/"

	self.gameConfigName = fileConfig.game
	self:LoadGameConfig(gameConfPath .. self.gameConfigName .. "/mainConfig.lua")

	self.campaignPath = "campaign/sample"
	self.campaignConfigName = "sample"
	self.campaignConfig = VFS.Include("campaign/sample/mainConfig.lua")
	self.campaignSaveFile = nil -- Set by user
	self.nextCampaignSaveNumber = 1
	self.campaignConfigOptions = {
		"sample",
		"--dev"
	}
	self.campaignConfigHumanNames = {
		"Sample",
		--"Dev"
	}
	local gameConfigOptions = {}
	local subdirs = VFS.SubDirs(gameConfPath)
	for index, subdir in ipairs(subdirs) do
		-- get just the folder name
		subdir = string.gsub(subdir, gameConfPath, "")
		subdir = string.sub(subdir, 1, -2)	-- truncate trailing slash
		Spring.Log(LOG_SECTION, LOG.NOTICE, "Detected game config", subdir)
		gameConfigOptions[#gameConfigOptions+1] = subdir
	end

	self.gameConfigOptions = {}
	self.gameConfigHumanNames = {}
	for i = 1, #gameConfigOptions do
		local fileName = gameConfPath .. gameConfigOptions[i] .. "/mainConfig.lua"
		Spring.Log(LOG_SECTION, LOG.INFO, "Attempting to load game config: " .. fileName)
		if VFS.FileExists(fileName) then
			Spring.Log(LOG_SECTION, LOG.INFO, "Game config found:" .. fileName)
			local gameConfig = VFS.Include(fileName, nil, VFS.RAW_FIRST)
			if gameConfig.CheckAvailability() then
				self.gameConfigHumanNames[#self.gameConfigHumanNames + 1] = gameConfig.name
				self.gameConfigOptions[#self.gameConfigOptions + 1] = gameConfigOptions[i]
			end
		else
			Spring.Log(LOG_SECTION, LOG.WARNING, "Game config not found: " .. fileName)
		end
	end

	self.lastLoginChatLength = 25
	self.notifyForAllChat = true
	self.autosaveOnMatchmaker = true
	self.planetwarsNotifications = false -- Possibly too intrusive? See how it goes.
	self.ingameNotifcations = true -- Party, chat
	self.nonFriendNotifications = true -- Party, chat
	self.friendNotifyIngame = true
	self.simplifiedSkirmishSetup = true
	self.debugMode = false
	self.devMode = (VFS.FileExists("devmode.txt") and true) or false
	self.debugRawMessages = false
	self.enableProfiler = false
	self.showPlanetUnlocks = false
	self.showPlanetCodex = false
	self.showPlanetMinimap = false
	self.showPlanetEnemyUnits = false
	self.campaignSpawnDebug = false
	self.editCampaign = false
	self.activeDebugConsole = false
	self.debugLobbyGameChat = false
	self.onlyShowFeaturedMaps = true
	self.showFullModList = false
	self.simpleAiList2 = true
	self.enableDebugBuffer = false
	self.useSpringRestart = false
	self.menuMusicVolume = 0.5
	self.menuNotificationVolume = 0.8
	self.menuBackgroundBrightness = 1
	self.gameOverlayOpacity = 0.5
	self.coopConnectDelay = 5
	self.showMatchMakerBattles = false
	self.hideInterface = false
	self.enableTextToSpeech = true
	self.showOldAiVersions = false
	self.drawAtFullSpeed = false
	self.lobbyIdleSleep = false
	self.rememberQueuesOnStart2 = true
	self.blockedJoinBattles = false
	self.channels = {}
	if self.gameConfig.defaultChatChannels ~= nil then
		for _, channelName in ipairs(self.gameConfig.defaultChatChannels) do
			self.channels[channelName] = true
		end
	end

	self.language = "en"
	self.languages = {
		["en"] = {locale = "en", name="English"},
		["de"] = {locale = "de", name="Deutsch (unvollständig)"},
		["it"] = {locale = "it", name="Italiano"},
	}

	self.lobby_fullscreen = 1
	self.game_fullscreen = 1

	self.chatFontSize = 18

	self.fontName = "LuaMenu/widgets/chili/skins/Evolved/fonts/n019003l.pfb"
	self.fontRaw = {
		[0] = {size = 10, shadow = false},
		[1] = {size = 14, shadow = false},
		[2] = {size = 18, shadow = false},
		[3] = {size = 22, shadow = false},
		[4] = {size = 32, shadow = false},
		[5] = {size = 48, shadow = false},
	}
	
	self.fontSpecial = {}
	self.font = {}
	for i = 0, #self.fontRaw do
		self.font[i] = WG.Chili.Font:New {
			size         = self.fontRaw[i].size,
			font         = self.fontName,
			color        = {1,1,1,1},
			outlineColor = {0.05,0.05,0.05,0.9},
			outline      = false,
			shadow       = false,
		}
	end

	self.configParamTypes = {}
	for _, param in pairs(Spring.GetConfigParams()) do
		self.configParamTypes[param.name] = param.type
	end

	self.AtiIntelSettingsOverride = {
		AdvSky = 0,
		UsePBO = 0,
		VSync = 1,
	}

	self.countryShortnames = VFS.Include(LUA_DIRNAME .. "configs/countryShortname.lua")
	if self.gameConfig.springSettingsPath ~= nil then
		self.game_settings = VFS.Include(self.gameConfig.springSettingsPath)
	else
		self.game_settings = VFS.Include(LUA_DIRNAME .. "configs/springsettings/springsettings.lua")
	end
	self.forcedCompatibilityProfile = VFS.Include(LUA_DIRNAME .. "configs/springsettings/forcedCompatibilityProfile.lua")

	local default = self.gameConfig.SettingsPresetFunc and self.gameConfig.SettingsPresetFunc()
	if default then
		self.settingsMenuValues = {}
		for name, defValue in pairs(default) do
			self:SetSettingsConfigOption(name, defValue)
		end
	else
		self.settingsMenuValues = self.gameConfig.settingsDefault -- Only until configuration data is loaded.
	end

	self.animate_lobby = (gl.CreateShader ~= nil)
	self.minimapDownloads = {}
	self.minimapDownloadStarted = {}
	self.downloadRetryCount = 3

	local saneCharacterList = {
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "[", "]", "_",
	}
	self.saneCharacters = {}
	for i = 1, #saneCharacterList do
		self.saneCharacters[saneCharacterList[i]] = true
	end

	-- UI Styling globals that are really not config, but need to be somewhere.
	WG.TOP_LABEL_Y = 16
	WG.TOP_BUTTON_Y = 8
	WG.BUTTON_HEIGHT = 41
end

---------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------

function Configuration:LoadGameConfig(path)
	self.gameConfig = VFS.Include(path)
	if type(self.gameConfig) ~= 'table' then
		Spring.Log("Settings", LOG.ERROR, 'Chobby configuration error. Returned game config is not a table: ' .. tostring(path))
		return
	end
	local mandatoryFields = {"settingsNames"}
	for _, mandatoryField in ipairs(mandatoryFields) do
		if self.gameConfig[mandatoryField] == nil then
			Spring.Log("Settings", LOG.ERROR, "Chobby configuration error. Mandatory field is missing: " .. mandatoryField .. ". Check your game settings")
		end
	end
	localLobby.useTeamColor = not self.gameConfig.disableColorChoosing
end

function Configuration:SetSpringsettingsValue(key, value, compatOverride)
	if self.doNotSetAnySpringSettings then
		return
	end

	if not compatOverride then
		local compatProfile = self.forcedCompatibilityProfile
		if compatProfile and compatProfile[key] then
			return
		end
	end

	value = (self.fixedSettingsOverride and self.fixedSettingsOverride[key]) or value

	local configType = self.configParamTypes[key]
	if configType == "int" then
		Spring.Echo("SetSettings Int", key, value)
		Spring.SetConfigInt(key, value)
	elseif configType == "bool" or configType == "float" then
		Spring.Echo("SetSettings Value", key, value)
		Spring.SetConfigString(key, value)
	elseif configType == nil then
		Spring.Log("Settings", LOG.WARNING, "No such key: " .. tostring(key) .. ", but setting it as string anyway.")
		Spring.SetConfigString(key, value)
	else
		Spring.Log("Settings", LOG.WARNING, "Unexpected key type: " .. configType .. ", but setting it as string anyway.")
		Spring.SetConfigString(key, value)
	end
end

function Configuration:UpdateFixedSettings(newOverride)
	local gameSettings = self.game_settings

	-- Reset old
	local oldOverride = self.fixedSettingsOverride
	self.fixedSettingsOverride = nil
	if oldOverride then
		for key, value in pairs(oldOverride) do
			if gameSettings[key] then
				self:SetSpringsettingsValue(key, gameSettings[key])
			end
		end
	end

	-- Apply new
	self.fixedSettingsOverride = newOverride
	if newOverride then
		for key, value in pairs(newOverride) do
			self:SetSpringsettingsValue(key, value)
		end
	end
end

function Configuration:SetSettingsConfigOption(name, newValue)
	local setting = self.gameConfig.settingsNames[name]
	if not setting then
		return false
	end

	self.settingsMenuValues[name] = newValue

	if setting.isNumberSetting then
		local applyFunction = setting.applyFunction
		if applyFunction then
			local applyData = applyFunction(newValue, self)
			if applyData then
				for applyName, value in pairs(applyData) do
					self.game_settings[applyName] = value
					self:SetSpringsettingsValue(applyName, value)
				end
			end
		else
			local springValue = setting.springConversion(newValue)
			self.game_settings[setting.applyName] = springValue
			self:SetSpringsettingsValue(setting.applyName, springValue)
		end
	else
		if setting.optionNames == nil or (not setting.optionNames[newValue]) then
			return false
		end

		-- Selection from multiple options
		local selectedOption = setting.optionNames[newValue]
		if setting.fileTarget then
			self.settingsMenuValues[name .. "_file"] = selectedOption.file
			if setting.applyFunction then
				setting.applyFunction(selectedOption.file, self)
			else
				local sourceFile = VFS.LoadFile(selectedOption.file)
				local settingsFile = io.open(setting.fileTarget, "w")
				settingsFile:write(sourceFile)
				settingsFile:close()
			end
		else
			local applyData = selectedOption.apply or (selectedOption.applyFunction and selectedOption.applyFunction(nil, self))
			if not applyData then
				return true
			end
			for applyName, value in pairs(applyData) do
				self.game_settings[applyName] = value
				self:SetSpringsettingsValue(applyName, value)
			end
		end
	end
	return true
end

function Configuration:ApplySettingsConfigPreset(preset)
	for name, value in pairs(preset) do
		self:SetSettingsConfigOption(name, value)
	end
end

function Configuration:SetTutorialComplete()
	self.hideWelcomeMessage = true
end

---------------------------------------------------------------------------------
-- Widget interface callins
---------------------------------------------------------------------------------

function Configuration:SetConfigData(data)
	if data.campaignConfigName == "dev" then
		data.campaignConfigName = "sample"
	end

	if data ~= nil then
		for k, v in pairs(data) do
			if not self.noNaiveConfigOverride[k] then
				self:SetConfigValue(k, v)
			end
		end
	end

	-- Fix old channel memory.
	for key, value in pairs(self.channels) do
		if string.find(key, "debriefing") or string.find(key, "party_") then
			self.channels[key] = nil
		end
	end

	self.game_settings.XResolutionWindowed = nil
	self.game_settings.YResolutionWindowed = nil
	self.game_settings.WindowPosX = nil
	self.game_settings.WindowPosY = nil
	self.game_settings.WindowBorderless = nil
	self.game_settings.Fullscreen = nil

	-- Fix old memory
	self.game_settings.UnitIconDist = nil

	if self.serverAddress == "zero-k.com" then
		self.serverAddress = "zero-k.info"
	end

	local newSpringsettings, onlyIfMissingSettings, onlyIfOutdated, onlyIfValueBelow, settingsVersion = VFS.Include(LUA_DIRNAME .. "configs/springsettings/springsettingsChanges.lua")
	for key, value in pairs(newSpringsettings) do
		self.game_settings[key] = value
	end
	for key, value in pairs(onlyIfMissingSettings) do
		if self.game_settings[key] == nil then
			self.game_settings[key] = value
		end
	end

	for key, value in pairs(onlyIfValueBelow) do
		if self.game_settings[key] == nil then
			self.game_settings[key] = value
		end
		if self.game_settings[key] < value then
			self.game_settings[key] = value
		end
	end
	
	if (self.lobbySettingsVersion or 0) < 1 then
		self.settingsMenuValues.InterfaceScale = nil -- Reset the setting
	end
	self.lobbySettingsVersion = 1
	
	if (self.settingsVersion or 0) < settingsVersion then
		for key, value in pairs(onlyIfOutdated) do
			self.game_settings[key] = value
		end
		self.settingsVersion = settingsVersion
	end

	if data.settingsMenuValues then
		for name, value in pairs(data.settingsMenuValues) do
			self:SetSettingsConfigOption(name, value)
		end
	end
end

function Configuration:GetConfigData()
	return {
		serverAddress = self.serverAddress,
		serverPort = self.serverPort,
		userName = self.userName,
		suggestedNameFromSteam = self.suggestedNameFromSteam,
		uiScale = self.uiScale,
		password = self.password,
		autoLogin = self.autoLogin,
		firstLoginEver = self.firstLoginEver,
		wantAuthenticateWithSteam = self.wantAuthenticateWithSteam,
		hideWelcomeMessage = self.hideWelcomeMessage,
		useSteamBrowser = self.useSteamBrowser,
		steamLinkComplete = self.steamLinkComplete,
		alreadySeenFactionPopup4 = self.alreadySeenFactionPopup4,
		firstBattleStarted = self.firstBattleStarted,
		battleFilterPassworded3 = self.battleFilterPassworded3,
		battleFilterNonFriend = self.battleFilterNonFriend,
		battleFilterRunning = self.battleFilterRunning,
		channels = self.channels,
		gameConfigName = self.gameConfigName,
		language = self.language,
		game_fullscreen = self.game_fullscreen,
		panel_layout = self.panel_layout,
		lobby_fullscreen = self.lobby_fullscreen,
		manualBorderless = self.manualBorderless,
		manualFullscreen = self.manualFullscreen,
		manualWindowed = self.manualWindowed,
		animate_lobby = self.animate_lobby,
		game_settings = self.game_settings,
		notifyForAllChat = self.notifyForAllChat,
		planetwarsNotifications = self.planetwarsNotifications,
		ingameNotifcations = self.ingameNotifcations,
		nonFriendNotifications = self.nonFriendNotifications,
		friendNotifyIngame = self.friendNotifyIngame,
		simplifiedSkirmishSetup = self.simplifiedSkirmishSetup,
		debugMode = self.debugMode,
		debugAutoWin = self.debugAutoWin,
		debugRawMessages = self.debugRawMessages,
		enableProfiler = self.enableProfiler,
		showPlanetUnlocks = self.showPlanetUnlocks,
		showPlanetCodex = self.showPlanetCodex,
		showPlanetMinimap = self.showPlanetMinimap,
		showPlanetEnemyUnits = self.showPlanetEnemyUnits,
		campaignSpawnDebug = self.campaignSpawnDebug,
		editCampaign = self.editCampaign,
		confirmation_mainMenuFromBattle = self.confirmation_mainMenuFromBattle,
		confirmation_battleFromBattle = self.confirmation_battleFromBattle,
		drawAtFullSpeed = self.drawAtFullSpeed,
		lobbyIdleSleep = self.lobbyIdleSleep,
		rememberQueuesOnStart2 = self.rememberQueuesOnStart2,
		blockedJoinBattles = self.blockedJoinBattles,
		queue_handicap = self.queue_handicap,
		queue_wide = self.queue_wide,
		loadLocalWidgets = self.loadLocalWidgets,
		activeDebugConsole = self.activeDebugConsole,
		debugLobbyGameChat = self.debugLobbyGameChat,
		onlyShowFeaturedMaps = self.onlyShowFeaturedMaps,
		showFullModList = self.showFullModList,
		simpleAiList2 = self.simpleAiList2,
		coopConnectDelay = self.coopConnectDelay,
		useSpringRestart = self.useSpringRestart,
		displayBots = self.displayBots,
		displayBadEngines3 = self.displayBadEngines3,
		useWrongEngine = self.useWrongEngine,
		multiplayerLaunchNewSpring = self.multiplayerLaunchNewSpring,
		doNotSetAnySpringSettings = self.doNotSetAnySpringSettings,
		agressivelySetBorderlessWindowed = self.agressivelySetBorderlessWindowed,
		fixedSettingsOverride = self.fixedSettingsOverride,
		settingsMenuValues = self.settingsMenuValues,
		menuMusicVolume = self.menuMusicVolume,
		menuNotificationVolume = self.menuNotificationVolume,
		menuBackgroundBrightness = self.menuBackgroundBrightness,
		gameOverlayOpacity = self.gameOverlayOpacity,
		showMatchMakerBattles = self.showMatchMakerBattles,
		matchmakerRejectTime = self.matchmakerRejectTime,
		matchmakerRejectCount = self.matchmakerRejectCount,
		matchmakerPopupTime = self.matchmakerPopupTime,
		enableTextToSpeech = self.enableTextToSpeech,
		showOldAiVersions = self.showOldAiVersions,
		chatFontSize = self.chatFontSize,
		myAccountID = self.myAccountID,
		lastAddedAiName = self.lastAddedAiName,
		window_WindowPosX = self.window_WindowPosX,
		window_WindowPosY = self.window_WindowPosY,
		window_XResolutionWindowed = self.window_XResolutionWindowed,
		window_YResolutionWindowed = self.window_YResolutionWindowed,
		campaignSaveFile = self.campaignSaveFile,
		nextCampaignSaveNumber = self.nextCampaignSaveNumber,
		steamReleasePopupSeen = self.steamReleasePopupSeen,
		campaignConfigName = self.campaignConfigName,
		settingsVersion = self.settingsVersion,
		lobbySettingsVersion = self.lobbySettingsVersion,
	}
end

---------------------------------------------------------------------------------
-- Setters
---------------------------------------------------------------------------------

function Configuration:SetConfigValue(key, value)
	if self[key] == value then
		return
	end
	self[key] = value
	if key == "useSpringRestart" then
		lobby.useSpringRestart = value
		localLobby.useSpringRestart = value
	end
	if key == "disableColorChoosing" then
		localLobby.useTeamColor = not value
	end
	if key == "uiScale" then
		self[key] = math.max(self.minUiScale, math.min(self.maxUiScale, value))
		WG.uiScale = self[key]
		local screenWidth, screenHeight = Spring.GetViewSizes()
		screen0:Resize(screenWidth, screenHeight)
	end
	if key == "gameConfigName" then
		self:LoadGameConfig(LUA_DIRNAME .. "configs/gameConfig/" .. value .. "/mainConfig.lua")
	end
	if key == "campaignConfigName" then
		self.campaignPath = "campaign/" .. value
		self.campaignConfig = VFS.Include("campaign/" .. value .. "/mainConfig.lua")
	end
	self:_CallListeners("OnConfigurationChange", key, value)
end

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

function Configuration:IsLobbyVisible()
	return WG.Chobby.interfaceRoot.GetLobbyInterfaceHolder().visible
end

function Configuration:GetServerAddress()
	if self.ForceDefaultServer then
		return self.DefaultServerHost
	end
	return self.serverAddress
end

function Configuration:GetServerPort()
	if self.ForceDefaultServer then
		return self.DefaultServerPort
	end
	return self.serverPort
end

function Configuration:GetErrorColor()
	return self.errorColor
end

function Configuration:GetWarningColor()
	return self.warningColor
end

function Configuration:GetNormalColor()
	return self.normalColor
end

function Configuration:GetSuccessColor()
	return self.successColor
end

function Configuration:GetPartialColor()
	return self.partialColor
end

function Configuration:GetSelectedColor()
	return self.selectedColor
end

function Configuration:GetHighlightedColor()
	return self.highlightedColor
end

function Configuration:GetButtonFocusColor()
	return self.buttonFocusColor
end

function Configuration:GetModeratorColor()
	return self.moderatorColor
end

function Configuration:GetFounderColor()
	return self.founderColor
end

function Configuration:GetIgnoredUserNameColor()
	return self.ignoredUserNameColor
end

function Configuration:GetUserNameColor()
	return self.userNameColor
end

-- NOTE: this one is in opengl range [0,1]
function Configuration:GetButtonSelectedColor()
	return self.buttonSelectedColor
end

function Configuration:GetChannels()
	return self.channels
end

function Configuration:GetCross()
	return self:GetErrorColor() .. "X"
end

function Configuration:GetTick()
	return self:GetSuccessColor() .. "O"
end

function Configuration:GetFont(sizeScale, specialName, specialData, rawSize)
	if not specialName and not rawSize then
		return self.font[sizeScale]
	end
	local size = (rawSize and sizeScale) or self.fontRaw[sizeScale].size
	if not self.fontSpecial[size] then
		self.fontSpecial[size] = {}
	end
	if not self.fontSpecial[size][specialName] then
		specialData = specialData or {}
		specialData.font = self.fontName
		specialData.size = size
		
		specialData.color        = specialData.color or {1,1,1,1}
		specialData.outlineColor = specialData.outlineColor or {0.05,0.05,0.05,0.9}
		specialData.outline      = specialData.outline or false
		specialData.shadow       = specialData.shadow or false
		
		self.fontSpecial[size][specialName] = WG.Chili.Font:New(specialData)
	end
	return self.fontSpecial[size][specialName]
end

function Configuration:GetHintFont(sizeScale, specialName, specialData, rawSize)
	specialName = (specialName or "") .. "_hint_" .. sizeScale
	specialData = specialData or {}
	specialData.color = {1,1,1,0.48}
	return self:GetFont(sizeScale, specialName, specialData, rawSize)
end

function Configuration:GetButtonFont(sizeScale, specialName, specialData, rawSize)
	specialName = (specialName or "") .. "_button_" .. sizeScale
	specialData = specialData or {}
	specialData.outline = true
	specialData.outlineWidth = 2
	specialData.outlineHeight = 3
	return self:GetFont(sizeScale, specialName, specialData, rawSize)
end

function Configuration:AllowNotification(playerName, playerList)
	if (not self.ingameNotifcations) and (Spring.GetGameName() ~= "") then
		return false
	end
	if lobby and not self.nonFriendNotifications then
		if playerName then
			local userInfo = lobby:TryGetUser(playerName)
			if not userInfo.isFriend then
				return false
			end
		end

		if playerList then
			local foundFriend = false
			for i = 1, #playerList do
				local userInfo = lobby:TryGetUser(playerList[i])
				if userInfo.isFriend then
					foundFriend = true
					break
				end
			end
			if not foundFriend then
				return false
			end
		end
	end
	return true
end

function Configuration:ImageFileExists(filePath)
	if not VFS.FileExists(filePath) then
		return false
	end
	local data = gl.TextureInfo(filePath)
	return data and data.ysize ~= -1
end

function Configuration:GetMinimapSmallImage(mapName)
	mapName = string.gsub(mapName, "[^a-zA-Z0-9%-%(%)%.]", "_")

	local filePath = self.gameConfig.minimapThumbnailPath .. mapName .. ".png"
	if self:ImageFileExists(filePath) then
		return filePath, false
	end

	filePath = MINIMAP_THUMB_DOWNLOAD_DIR .. mapName .. ".jpg"
	if self:ImageFileExists(filePath) then
		return filePath, false
	end

	if not self.minimapDownloadStarted[mapName] and WG.WrapperLoopback and WG.WrapperLoopback.DownloadImage then
		Spring.CreateDir(MINIMAP_THUMB_DOWNLOAD_DIR)
		WG.WrapperLoopback.DownloadImage({ImageUrl = "https://zero-k.info/Resources/" .. mapName .. ".thumbnail.jpg", TargetPath = filePath})
		self.minimapDownloadStarted[mapName] = true
	end

	return filePath, true
end

function Configuration:GetMinimapImage(mapName)
	if not self.gameConfig.minimapOverridePath then
		return LUA_DIRNAME .. "images/minimapNotFound1.png"
	end
	mapName = string.gsub(mapName, "[^a-zA-Z0-9%-%(%)%.]", "_")
	local filePath = self.gameConfig.minimapOverridePath .. mapName .. ".jpg"
	if not self:ImageFileExists(filePath) then
		filePath = "LuaMenu/Images/Minimaps/" .. mapName .. ".jpg"
	end
	if WG.WrapperLoopback and WG.WrapperLoopback.DownloadImage and (not self:ImageFileExists(filePath)) then
		if not self.minimapDownloads[mapName] then
			Spring.CreateDir("LuaMenu/Images/Minimaps")
			WG.WrapperLoopback.DownloadImage({ImageUrl = "https://zero-k.info/Resources/" .. mapName .. ".minimap.jpg", TargetPath = filePath})
			self.minimapDownloads[mapName] = true
		end
		return filePath, true
	end
	return filePath
end

function Configuration:GetModoptions(gameName)
	if not (gameName and VFS.HasArchive(gameName)) then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Missing game archive, cannot fetch modoptions")
		return false
	end

	local function ReadModoptions()
		if not VFS.FileExists("modoptions.lua", VFS.ZIP) then
			return false
		end
		return VFS.Include("modoptions.lua", nil, VFS.ZIP)
	end

	local alreadyLoaded = false
	for _, archive in pairs(VFS.GetLoadedArchives()) do
		if archive == gameName then
			alreadyLoaded = true
			break
		end
	end
	if alreadyLoaded then
		return VFS.Include("modoptions.lua", nil, VFS.ZIP)
	end
	return VFS.UseArchive(gameName, ReadModoptions)
end

function Configuration:GetLoadingImage(size)
	if size == 1 then
		return LUA_DIRNAME .. "images/load_img_32.png"
	elseif size == 2 then
		return LUA_DIRNAME .. "images/load_img_128.png"
	elseif size == 3 then
		return LUA_DIRNAME .. "images/load_img_512.png"
	end
	return LUA_DIRNAME .. "images/load_img_128.png"
end

function Configuration:GetCountryLongname(shortname)
	if shortname and self.countryShortnames[shortname] then
		return self.countryShortnames[shortname]
	end
	return shortname
end

function Configuration:GetHeadingImage(fullscreenMode, title)
	local subheadings = self.gameConfig.subheadings
	if fullscreenMode then
		return (subheadings and subheadings.large and subheadings.large[title]) or self.gameConfig.headingLarge
	else
		return (subheadings and subheadings.small and subheadings.small[title]) or self.gameConfig.headingSmall
	end
end

function Configuration:GetTruncatedEngineVersion(overrideEngineName)
	local engineVer = overrideEngineName or Spring.Utilities.GetEngineVersion()
	if tonumber(engineVer) then
		-- Master releases lack the '.0' at the end. Who knows what other cases are wrong.
		-- Add as required.
		return (engineVer .. ".0")
	else
		return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(engineVer, " BAR105", ""), " BAR", ""), "Spring ", ""), " maintenance", ""), " develop", "")
	end
end

function Configuration:IsValidEngineVersion(engineVersion)
	return engineVersion == Spring.Utilities.GetEngineVersion() or engineVersion == self:GetTruncatedEngineVersion()
end

function Configuration:IsCurrentVersionNewerThan(rel, dev)
	-- Argument example, <rel>.0.1-<dev>-g5072695
	local thisVersion = self:GetTruncatedEngineVersion()
	local thisRel, thisDev
	local i = 1
	for word in thisVersion:gmatch("[^%-]+") do
		if i == 1 then
			local j = 1
			for subword in word:gmatch("[^%.]+") do
				if j == 1 then
					thisRel = tonumber(subword)
					if thisRel then
						if thisRel < rel then
							return false
						end
						if thisRel > rel then
							return true
						end
					end
				end
				j = j + 1
			end
		elseif i == 2 then
			thisDev = tonumber(word)
			if thisDev then
				return thisDev > dev
			end
		end
		i = i + 1
	end
	return false -- A newer version would not fail to return before now
end

function Configuration:SanitizeName(name, usedNames)
	local ret = ""
	local length = string.len(name)
	Spring.Echo("SanitizeName", name)
	for i = 1, length do
		local c = string.sub(name, i, i)
		if self.saneCharacters[c] then
			ret = ret .. c
		end
	end

	if ret == "" then
		ret = "Player"
	end
	if usedNames then
		while usedNames[ret] do
			ret = ret .. "1"
		end
		usedNames[ret] = true
	end

	return ret, usedNames
end

function Configuration:GetPlayerName(allowBlank)
	local suggest = (lobby and lobby.myUserName) or self.suggestedNameFromSteam or (allowBlank and "") or "Player"
	if (not allowBlank) and suggest == "" then
		return "Player"
	end
	return suggest
end

function Configuration:GetDefaultGameName()
	if not self.gameConfig then
		return false
	end

	local rapidTag = self.gameConfig._defaultGameRapidTag
	if rapidTag and VFS.GetNameFromRapidTag then
		local rapidName = VFS.GetNameFromRapidTag(rapidTag)
		if rapidName then
			return rapidName
		end
	end

	return self.gameConfig._defaultGameArchiveName
end

function Configuration:GetIsRunning64Bit()
	if self.isRunning64Bit ~= nil then
		return self.isRunning64Bit
	end
	-- if Platform then
		-- osWordSize is not the same as spring bit version.
		--return Platform.osWordSize == 64
	-- end
	local infologFile, err = io.open("infolog.txt", "r")
	if not infologFile then
		Spring.Echo("Error opening infolog.txt", err)
		return false
	end
	local line = infologFile:read()
	while line do
		if string.find(line, "Physical CPU Cores") then
			break
		end
		if string.find(line, "Word Size") then
			if string.find(line, "64%-bit") then
				self.isRunning64Bit = true
				infologFile:close()
				return true
			else
				self.isRunning64Bit = false
				infologFile:close()
				return false
			end
		end
		line = infologFile:read()
	end
	infologFile:close()
	return false
end

function Configuration:GetIsDevEngine(overrideEngineName)
	local engine = self:GetTruncatedEngineVersion(overrideEngineName)
	local splits = engine:split("-")
	for i = 1, #splits do
		splits[i] = splits[i]:split("%.")[1]
	end
	if splits and splits[1] and tonumber(splits[1]) then
		return tonumber(splits[1]) > 104
	end
	return false
end

function Configuration:GetIsNotRunningNvidia()
	if self.isNotRunningNvidia ~= nil then
		return self.isNotRunningNvidia
	end
	if Platform then
		return Platform.gpuVendor ~= "Nvidia"
	end
	local infologFile, err = io.open("infolog.txt", "r")
	if not infologFile then
		Spring.Echo("Error opening infolog.txt", err)
		return false
	end
	local line = infologFile:read()
	while line do
		if string.find(line, "PostInit") then
			-- We are past the part of the infolog where NVIDIA would appear
			infologFile:close()
			self.isNotRunningNvidia = true
			return true
		end
		if string.find(line, "NVIDIA") then
			infologFile:close()
			self.isNotRunningNvidia = false
			return false
		end
		line = infologFile:read()
	end
	infologFile:close()
	self.isNotRunningNvidia = true
	return true
end

---------------------------------------------------------------------------------
-- Listener handler
---------------------------------------------------------------------------------
local function ShallowCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function Configuration:AddListener(event, listener)
	if listener == nil then
		Log.Error("Event: " .. tostring(event) .. ", listener cannot be nil")
		return
	end
	local eventListeners = self.listeners[event]
	if eventListeners == nil then
		eventListeners = {}
		self.listeners[event] = eventListeners
	end
	table.insert(eventListeners, listener)
end

function Configuration:RemoveListener(event, listener)
	if self.listeners[event] then
		for k, v in pairs(self.listeners[event]) do
			if v == listener then
				table.remove(self.listeners[event], k)
				if #self.listeners[event] == 0 then
					self.listeners[event] = nil
				end
				break
			end
		end
	end
end

function Configuration:_CallListeners(event, ...)
	if self.listeners[event] == nil then
		return nil -- no event listeners
	end
	local eventListeners = ShallowCopy(self.listeners[event])
	local args = {...}
	local n = select("#", ...)
	for i = 1, #eventListeners do
		local listener = eventListeners[i]
		xpcall(function() listener(listener, unpack(args, 1, n)) end,
			function(err) self:_PrintError(err) end )
	end
	return true
end

function Configuration:_PrintError(err)
	-- FIXME: cleanup more
	Log.Error(err)
	Log.Error(debug.traceback(err))
end

---------------------------------------------------------------------------------
-- 'Initialization'
---------------------------------------------------------------------------------
-- shadow the Configuration class with a singleton
Configuration = Configuration()
