 -------------------------------------
-- jvars --------------
-- fórsákén,  Emerald Dream --------

-- 
utility   = LibStub:GetLibrary( 'utility' )
local vars  = LibStub( 'AceAddon-3.0' ):NewAddon( 'vars' )

vars[ 'messenger' ] = _G[ 'DEFAULT_CHAT_FRAME' ]
vars[ 'theme' ] = {
  info = {
    hex = 'ff30f4', 
  },
  warn = {
    hex = 'ffbf00', 
  },
}
vars[ 'theme' ][ 'info' ][ 'r' ], 
vars[ 'theme' ][ 'info' ][ 'g' ], 
vars[ 'theme' ][ 'info' ][ 'b' ] 
= utility:hex2rgb( vars[ 'theme' ][ 'info' ][ 'hex'] )

vars[ 'theme' ][ 'warn' ][ 'r' ], 
vars[ 'theme' ][ 'warn' ][ 'g' ], 
vars[ 'theme' ][ 'warn' ][ 'b' ] 
= utility:hex2rgb( vars[ 'theme' ][ 'warn' ][ 'hex'] )

local systemv 
local enduserv

-- notice message handler
--
-- returns void
function vars:notify( ... )

  local prefix = CreateColor(
    self[ 'theme' ][ 'info' ][ 'r' ], 
    self[ 'theme' ][ 'info' ][ 'g' ], 
    self[ 'theme' ][ 'info' ][ 'b' ] 
  ):WrapTextInColorCode( self:GetName( ) )

  self[ 'messenger' ]:AddMessage( string.join( ' ', prefix, ... ) )

end

-- warning message handler
--
-- returns void
function vars:warn( ... )

  local prefix = CreateColor(
    self[ 'theme' ][ 'warn' ][ 'r' ], 
    self[ 'theme' ][ 'warn' ][ 'g' ], 
    self[ 'theme' ][ 'warn' ][ 'b' ] 
  ):WrapTextInColorCode( self:GetName( ) )

  self[ 'messenger' ]:AddMessage( string.join( ' ', prefix, ... ) )

end

-- compare versions
--
-- returns void
function vars:vtest( systemv, enduserv )

  if enduserv >= systemv then

    self[ 'current' ] = true
  
  else 

    self:warn( 'is outdated, an update is required to continue using!' )

    self[ 'current' ] = false

  end

end

-- outdated check
--
-- returns bool
function vars:isOutDated( )

  return not self[ 'current' ] == true

end

-- persistence reference
--
-- returns table
function vars:getDB( ) 

  return self[ 'db' ]

end

-- initializes persistence data
--
-- returns void
function vars:init( )

  local persistence = self:getDB( )
  if persistence[ 'profile' ][ 'vars' ] == nil then
    persistence[ 'profile' ][ 'vars' ] = { }
  end

  for v, i in pairs( self:getConfig( ) ) do
    persistence[ 'profile' ][ 'vars' ][ v ] = i
  end

end
--/script print( GetCVar( 'cameradistancemaxzoomfactor' ) );
-- set/get configuration
--
-- returns table
function vars:getConfig( )

  return {

    -- turn down BRIGHT nonsense
    ffxglow                                   = 0,
    maxlightcount                             = 12,
    maxlightdist                              = 100,

    -- make the world gloomy AF
    weatherdensity                            = 3,
    particledensity                           = 100,
    farclip                                   = 185,
    --nearclip                                  = 1300,
    SkyCloudLOD                               = 200,

    -- help FPS
    projectedtextures                         = 1,
    maxFPS                                    = 60,
    maxFPSBk                                  = 30,
    emphasizeMySpellEffects                   = 0,
    ffxDeath                                  = 0,
    groundEffectDensity                       = 16,
    shadowmode                                = 0,
    shadowtexturesize                         = 1024,

    -- make the world mysterious
    cameradistancemaxzoomfactor               = 1,
    groundeffectdist                          = 32,
    FootstepSounds                            = 1,

    -- make the world violent AF
    violencelevel                             = 5,
    profanityfilter                           = 0,

    -- don't interrupt me
    showtoastwindow                           = 0,
    showToastFriendRequest                    = 0,
    showToastOffline                          = 0,
    showToastOnline                           = 0,
    guildMemberNotify                         = 0,
    guildShowOffline                          = 0,
    --guildNewsFilter                           = 125,
    pendingInviteInfoShown                    = 0,
    spamFilter                                = 1,
    --Sound_MusicVolume                         = 0.2,
    --Sound_AmbienceVolume                      = 0.4,
    --Sound_DialogVolume                        = 0.3,
    BlockTrades                               = 1,
    blockChannelInvites                       = 1,
    --showGameTips                              = 0,
    autoClearAFK                              = 1,

    -- dialogs ui
    friendssmallview                          = 1,
    useCompactPartyFrames                     = 1, 
    guildRosterView                           = 'playerStatus',
    gxMaximize                                = 0,
    lfgAutoFill                               = 1,
    lfgAutoJoin                               = 1,
    wholeChatWindowClickable                  = 1,
    whisperMode                               = 'inline',
    findYourselfAnywhere                      = 1,
    --Outline                                   = nil,
    nameplateOtherAtBase                      = 0,
    nameplateOverlapV                         = 0.2,
    lockActionBars                            = 1,
    alwaysShowActionBars                      = 1,
    cameraView                                = 5,
    cameraPivot                               = 1,
    minimapTrackedInfov2                      = 229994,

    -- raid
    raidOptionIsShown                         = 1,
    raidOptionSortMode                        = 'group',
    raidOptionDisplayPets                     = 1,
    --raidFramesDisplayAggroHighlight           = 1,
    raidFramesDisplayClassColor               = 1,
    raidFramesDisplayOnlyDispellableDebuffs   = 1,
    raidFramesDisplayPowerBars                = 1,
    raidOptionKeepGroupsTogether              = 1,
    screenEdgeFlash                           = 0,
    doNotFlashLowHealthWarning                = 1,
    nameplateGlobalScale                      = 1.0,
    nameplateSelectedScale                    = 1.2,
    nameplateShowAll                          = 1,
    Sound_EnableErrorSpeech                   = 0,

    -- pvp
    showBattlefieldMinimap                    = 1,
    showTargetOfTarget                        = 1,
    showTargetCastbar                         = 1,
    showArenaEnemyCastbar                     = 1,
    showArenaEnemyPets                        = 1,

    -- save
    synchronizeMacros                         = 1,
    synchronizeConfig                         = 1,
    synchronizeSettings                       = 1,   

  }

end

-- apply config
--
-- returns void
function vars:apply( )

  for i, v in pairs( self:getDB( )[ 'profile' ][ 'vars' ] ) do
    SetCVar( i, v )
  end
  RestartGx( )
  self:notify( 'done' )

end

-- register persistence
--
-- returns void
function vars:OnInitialize( )

  local defaults = { 

    profile = { }

  }

  self[ 'db' ] = LibStub( 'AceDB-3.0' ):New(
    'persistence', defaults, true
  )

end

-- activated app handler
--
-- returns void
function vars:OnEnable( )

  local systemv = tonumber( select( 4, GetBuildInfo( ) ) ) or 0
  local enduserv  = tonumber( GetAddOnMetadata( self:GetName( ), 'X-Version' ) )

  self:vtest( systemv, enduserv )

  if self:isOutDated( ) == true then
    return
  end

  local persistence = self:getDB( )
  if persistence[ 'profile' ] == nil 
    or persistence[ 'profile' ][ 'registered' ] == nil 
    or persistence[ 'profile' ][ 'vars' ] == nil then

    self:notify( 'done' )
    persistence[ 'profile' ][ 'registered' ] = true

  elseif persistence[ 'profile' ][ 'registered' ] == true then
    vars:notify( 'running' )
    return
  end

  self:Enable( )
  self:init( )
  self:apply( )

end
