 -------------------------------------
-- vars --------------
-- Emerald Dream/Grobbulus --------

-- 
local vars = LibStub( 'AceAddon-3.0' ):GetAddon( 'vars' )
local tracked = vars:NewModule( 'tracked' )

-- parent persistence reference
--
-- returns table
function tracked:_geParenttDB( )
  return vars:getDB( )
end

-- persistence namespace
--
-- returns table
function tracked:getNameSpace( )

  return self:_geParenttDB( ):GetNamespace(
  	self:GetName( ) 
  )[ 'profile' ]

end

-- copy configuration
--
-- returns table
function tracked:getConfig( )

  local persistence = self:getNameSpace( )

  --self:_geParenttDB( ):ResetDB( )
  -- already built
  if persistence[ 'tracked' ] ~= nil then
    return persistence[ 'tracked' ]
  end

  -- needs building
  local known_vars  = vars:getConfig( )
  persistence[ 'tracked' ] = { }
  for category, category_rows in pairs( known_vars ) do
  	for i, row in pairs( category_rows ) do
      if persistence[ 'tracked' ][ category ] == nil then
        persistence[ 'tracked' ][ category ] = { }
      end
      local failed, default = pcall( GetCVarDefault, row[ 'command' ] )
      if not failed then
        default = ''
      end
      local default_value = default
      local current_value = GetCVar( row[ 'command' ] )
      local evaluation 		= default_value ~= '' and strlower( tostring( current_value ) ) ~= strlower( tostring( default_value ) )
      if evaluation then
      end
      tinsert( persistence[ 'tracked' ][ category ], { 
        help            = row[ 'help' ],
        command         = row[ 'command' ],
        category        = row[ 'category' ],
        scriptContents  = row[ 'scriptContents' ],
        commandType     = row[ 'commandType' ],
        info            = row[ 'info' ],
        tracked         = evaluation,
        value           = current_value,
      } )

    end
  end

  return persistence[ 'tracked' ]

end

-- refresh configuration
-- for a given changeset comprised of category|rowindex|var|value
-- determine if an update is needed within the persistence
--
-- returns bool, table
function tracked:refreshConfig( changeset )

  local persistence  	= self:getConfig( )
  local updated 		= false
  --self:_geParenttDB( ):ResetDB( )

  if changeset ~= nil then

  for category, category_rows in pairs( persistence ) do
    if changeset[ category ] then
      for i, row in pairs( category_rows ) do
        if changeset[ category ][ i ] then
          local updated_value = changeset[ category ][ i ][ row[ 'command' ] ]
          local current_value = row[ 'value' ]
          local evaluation 		= current_value ~= '' and strlower( tostring( updated_value ) ) ~= strlower( tostring( current_value ) )
          if evaluation then
            persistence[ category ][ i ][ 'value' ] = updated_value
            updated = true
          end
          persistence[ category ][ i ][ 'tracked' ] = evaluation
        end
      end
    end
  end

  end

  return updated, persistence

end

-- queue configuration
--
-- return bool
function tracked:queueConfig( category, var, value )
  
  local changeset = { }
  local persistence = self:getNameSpace( )
  for cat, rows in pairs( self:getConfig( ) ) do
  	if category == cat then
  	  for i, row in pairs( rows ) do
  	  	if row[ 'command' ] == var then
  	  	  changeset[ category ] = { }
  	  	  changeset[ category ][ i ] = { }
  	  	  changeset[ category ][ i ][ var ] = value
  		    tracked:refreshConfig( changeset )
		      if not tracked[ 'queue' ] then
		  	    tracked[ 'queue' ] = { }
		      end
  		    tinsert( tracked[ 'queue' ], changeset )
  	  	end
  	  end
  	end
  end

  return changeset ~= nil

end

-- update system
-- CVar and stats application
--
-- returns bool, number, string
function tracked:applyConfig( category )

  local tracked_count = 0
  local message       = ''
  local updated       = false
  local known_vars    = self:getConfig( )
  for cat, rows in pairs( known_vars ) do
    if type( rows ) == 'table' then
      for i, row in pairs( rows ) do
        if row[ 'tracked' ] == true then
          tracked_count = tracked_count + 1
        end
      end
    end
  end

  for i, pending in pairs( tracked[ 'queue' ] ) do
    for category, data in pairs( pending ) do
      for j, setting in pairs( data ) do
        for index, value in pairs( setting ) do
          if known_vars[ category ][ j ] then
            local current_value = GetCVar( index )
            if strlower( tostring( current_value ) ) ~= strlower( tostring( value ) ) then
              message = index .. ' updated from: ' .. current_value .. ' to: ' .. tostring( value )
              local list = vars:getProtected( 'combat' )
              if tContains( list, index ) ~= false and InCombatLockdown( ) == true then
                message = index .. ' can only be modified outside of combat'
              else
                SetCVar( index, value )
                if GetCVar( index ) ~= value then
                  message = 'failed'
                else
                  local default_value = GetCVarDefault( index )
                  local evaluation = strlower( tostring( value ) ) ~= strlower( tostring( default_value ) )
                  known_vars[ category ][ j ][ 'tracked' ] = evaluation
                  if not evaluation then
                    tracked_count = tracked_count - 1
                  end
                  updated = true
                end
              end
            else
              message = 'this setting is already applied'
            end
            tracked[ 'queue' ] = { }
          end
        end
      end
    end 
  end
  
  local persistence = self:getNameSpace( )
  if persistence[ 'options' ][ 'reloadgx' ] and updated then 
  	RestartGx( )
  end
  if persistence[ 'options' ][ 'reloadui' ] and updated then 
    ReloadUI( )
  end
  
  return updated, tracked_count, message

end

-- mark config rows as modified/tracked or not
-- 
-- return string
function tracked:indicate( value )
  if value == true then 
    return 'modified' 
  else 
    return 'default' 
  end
end

-- toggle synch to blizz hq
-- 
-- return bool
function tracked:cloudSync( state )

  local current_state = GetCVar( 'synchronizeConfig' )
  if state ~= current_state then
    SetCVar( 'synchronizeConfig', state )
    if GetCVar( 'synchronizeConfig' ) ~= state then
      return false
    else 
      return true
    end
  end

end

-- setup tracking
--
-- return void
function tracked:init( )
  self:getConfig( )
end

-- register persistence
--
-- returns void
function tracked:OnInitialize( )

  local defaults = { }
  defaults[ 'profile' ] = { }
  defaults[ 'profile' ][ 'search' ]   = { }
  defaults[ 'profile' ][ 'options' ]  = { }
  defaults[ 'profile' ][ 'search' ][ 'category_filter' ]  = 'Game'
  defaults[ 'profile' ][ 'search' ][ 'staus_filter' ]     = 'all'
  defaults[ 'profile' ][ 'search' ][ 'text' ]             = nil
  defaults[ 'profile' ][ 'search' ][ 'sort_direction' ]   = 'asc'
  defaults[ 'profile' ][ 'search' ][ 'remember' ]         = true

  defaults[ 'profile' ][ 'options' ]  = { }
  defaults[ 'profile' ][ 'options' ][ 'reloadgx' ]  = true
  defaults[ 'profile' ][ 'options' ][ 'reloadui' ]  = false
  defaults[ 'profile' ][ 'options' ][ 'cloudsync' ] = true

  self:_geParenttDB( ):RegisterNamespace(
  	self:GetName( ), defaults
  )
  self:Enable( )

end

-- activated module handler
--
-- returns void
function tracked:OnEnable( )

  if vars[ 'current' ] == false then
    return
  end
  self:init( )

end