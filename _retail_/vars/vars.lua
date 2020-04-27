 -------------------------------------
-- vars --------------
-- Emerald Dream/Grobbulus --------

-- 
utility   = LibStub:GetLibrary( 'utility' )
local vars  = LibStub( 'AceAddon-3.0' ):NewAddon( 'vars' )

vars[ 'messenger' ] = _G[ 'DEFAULT_CHAT_FRAME' ]
vars[ 'theme' ] = {
  text = {
    hex = 'ffffff',
  },
  info = {
    hex = 'ff30f4', 
  },
  warn = {
    hex = 'ffbf00', 
  },
  font = {
    family = 'Fonts\\FRIZQT__.TTF',
    flags = 'OUTLINE, MONOCHROME',
    large = 14,
    normal = 10,
    small = 8,
  },
}

local systemv 
local enduserv

for name, tdata in pairs( vars[ 'theme' ] ) do
  if name ~= 'font' then
    vars[ 'theme' ][ name ][ 'r' ], 
    vars[ 'theme' ][ name ][ 'g' ], 
    vars[ 'theme' ][ name ][ 'b' ] 
    = utility:hex2rgb( tdata[ 'hex' ] )
  end
end

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

-- persistence reference
--
-- returns table
function vars:getNameSpace( )
  return self:getDB( )[ 'profile' ]
end

-- persistence wipe handler
--
-- returns table
function vars:wipeDB( )
  return self:getDB( ):ResetDB( )
end

-- types reference
--
-- returns table
function vars:getTypes( )
  
  return {
    [ '0' ] = 'Debug',  [ '1' ] = 'Graphics', [ '2' ] = 'Console', 
    [ '3' ] = 'Combat', [ '4' ] = 'Game',     [ '5' ] = 'Default', 
    [ '6' ] = 'Net',    [ '7' ] = 'Sound',    [ '8' ] = 'Gm',
    [ '9' ] = 'Reveal', [ '10' ] = 'None',
  }

end

-- protected types reference
-- some variables can not be modified in certain circumstances (ptype)
--
-- returns table
function vars:getProtected( ptype )

  local list = {
    combat = {
      'alwaysShowActionBars',
      'bloatnameplates',
      'bloatTest',
      'bloatthreat',
      'consolidateBuffs',
      'fullSizeFocusFrame',
      'maxAlgoplates',
      'nameplateMotion',
      'nameplateOverlapH',
      'nameplateOverlapV',
      'nameplateShowEnemies',
      'nameplateShowEnemyGuardians',
      'nameplateShowEnemyPets',
      'nameplateShowEnemyTotems',
      'nameplateShowFriendlyGuardians',
      'nameplateShowFriendlyPets',
      'nameplateShowFriendlyTotems',
      'nameplateShowFriends',
      'repositionfrequency',
      'SetUIVisibility',
      'showArenaEnemyFrames',
      'showArenaEnemyPets',
      'showPartyPets',
      'showTargetOfTarget',
      'targetOfTargetMode',
      'uiScale',
      'useCompactPartyFrames',
      'useUiScale',
    }
  }

  if not ptype then
    ptype = 'combat'
  end

  if not list[ ptype ] then
    return { }
  else
    return list[ ptype ]
  end

end

-- set/get configuration
-- if it needs to be modified, a copy should be made
-- keep this copy pristine and in original condition
--
-- returns table
function vars:getConfig( )

  local persistence = self:getNameSpace( )
  if persistence[ 'vars' ] ~= nil then
    return persistence[ 'vars' ]
  end
  local known_vars      = C_Console.GetAllCommands( )
  local known_types     = self:getTypes( )
  persistence[ 'vars' ] = { }
  for i, row in pairs( known_vars ) do
    if( tonumber( row[ 'commandType' ] ) == 0 ) then
      local category  = known_types[ tostring( row[ 'category' ] ) ]
      if persistence[ 'vars' ][ category ] == nil then
        persistence[ 'vars' ][ category ] = { }
      end
      local failed, default = pcall( GetCVarDefault, row[ 'command' ] )
      if not failed then
        default = ''
      end
      tinsert( persistence[ 'vars' ][ category ], { 
        help            = row['help'],
        command         = row['command'],
        category        = row['category'],
        scriptContents  = row['scriptContents'],
        commandType     = known_types [ row['commandType'] ],
        info            = GetCVarInfo( row['command'] ),
        tracked         = false,
        value           = default
        --value           = GetCVar( row[ 'command' ] )
      } )
    end
  end
  return persistence[ 'vars' ]

end

-- build baseline data
--
-- returns void
function vars:init( )
  local known_vars = self:getConfig( )
end

-- gets blizzard default value
-- resets all possible vars
--
-- returns mixed
function vars:getDefault( index )
  return GetCVarDefault( index ) or false
end

-- applies blizzard defaults
--
-- returns void
function vars:applyDefaults( )

  DEFAULT_CHAT_FRAME.editBox:SetText( '/cvar_reset' )
  ChatEdit_SendText( DEFAULT_CHAT_FRAME.editBox, 0 )
  --ConsoleExec( 'cvar_reset' )

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

  self:Enable( )
  --self:wipeDB( )
  self:init( )

end