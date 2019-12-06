 -------------------------------------
-- jvars --------------
-- fórsákén,  Emerald Dream --------

-- 
local vars = LibStub( 'AceAddon-3.0' ):GetAddon( 'vars' )
local ui = vars:NewModule( 'ui', 'AceConsole-3.0' )
local frame = nil
local list = { } 

-- setup addon
--
-- returns void
function ui:init( )
  self:RegisterChatCommand( 'vars', 'processInput' )
  self[ 'registry'] = { }
end

-- process slash commands
--
-- returns void
function ui:processInput( input )
  
  input = gsub( input, ' ', '' )
  if input == 'config' then
  	self:toggle( )
  else
  	vars:warn( 'invalid input' )
  end

end

-- toggle slash handler
-- 
-- returns void
function ui:toggle( )

  local menu = frame or self:createMenu( )
  menu:SetShown( not menu:IsShown() )

end

-- create list of category vars 
-- index each with an integer
--
-- returns table
function ui:dataPreProcess( cat )

  local t = { }
  local tracked = vars:GetModule( 'tracked' )
  for category, category_data in pairs( tracked:getConfig( ) ) do
    if category == cat then
      for i, row in pairs( category_data ) do
        t[ i ] = row[ 'command' ]
      end
    end
  end

  return t

end

-- provide access to ui
--
-- returns table
function ui:createMenu( )

  -- setup the menu
  local frames = vars:GetModule( 'frames' )
  frame = frames:bootUI( )

  -- initialize
  self[ 'registry' ][ 'vars_count' ] = 0
  self[ 'registry' ][ 'tracked_count' ] = 0
  local direction = 'desc'
  local category = 'Game'
  local state = 'default'
  local search = ''
  local remember = true
  local reloadgx = true
  local reloadui = true

  local positions = { x = 30, y = 0 }
  local tracked   = vars:GetModule( 'tracked' )
  local persistence = vars:getNameSpace( )

  -- prefrences
  if persistence[ 'search' ] == nil then
    persistence[ 'search' ] = { }
  end
  if persistence[ 'search' ][ 'remember' ] == nil then
    persistence[ 'search' ][ 'remember' ] = remember
  end

  if persistence[ 'search' ][ 'remember' ] then
    if persistence[ 'search' ][ 'direction' ] == nil then
      persistence[ 'search' ][ 'direction' ] = direction
    elseif persistence[ 'search' ][ 'direction' ] ~= direction then
      persistence[ 'search' ][ 'direction' ] = direction
    end
    if persistence[ 'search' ][ 'category' ] == nil then
      persistence[ 'search' ][ 'category' ] = category
    elseif persistence[ 'search' ][ 'category' ] ~= category then
      persistence[ 'search' ][ 'category' ] = category
    end
    if persistence[ 'search' ][ 'state' ] == nil then
      persistence[ 'search' ][ 'state' ] = state
    elseif persistence[ 'search' ][ 'state' ] ~= state then
      persistence[ 'search' ][ 'state' ] = state
    end
    if persistence[ 'search' ][ 'search' ] == nil then
      persistence[ 'search' ][ 'search' ] = search
    elseif persistence[ 'search' ][ 'search' ] ~= search then
      persistence[ 'search' ][ 'search' ] = search
    end
  else
    persistence[ 'search' ][ 'direction' ]  = 'asc'
    persistence[ 'search' ][ 'category' ]   = 'Game'
    persistence[ 'search' ][ 'state' ]      = 'default'
    persistence[ 'search' ][ 'search' ]     = ''
  end

  -- list titles
  local vn = frames:createText( frame, 'var' )
  vn:SetJustifyH( 'right' )
  vn:SetSize( 225, 20 )
  vn:SetPoint( 'topleft', frame[ 'controls' ], 'topleft', 0, -25 )
  
  --[[
  -- we need a button next to vn and the button should...
  b:registerForClicks( 'LeftButtonDown' )
  b:SetScript( 'OnClick', function( self )
    if persistence[ 'search' ][ 'direction' ] == 'asc' then
      persistence[ 'search' ][ 'direction' ] = 'desc'
    else
      persistence[ 'search' ][ 'direction' ] = 'asc'
    end
  end )
  ]]

  -- list sort
  local t = { }
  local data = self:dataPreProcess( category )
  data = frames:sort( data, persistence[ 'search' ][ 'direction' ] )

  for o, name in pairs( data ) do
    for cat, category_data in pairs( tracked:getConfig( ) ) do
      if cat == category then
        for i, row in pairs( category_data ) do
          if row[ 'command' ] == name then
            if t[ category ] == nil then
              t[ category ] = { }
            end
            t[ category ][ o ] = row
          end
        end
      end
    end
  end

  local d = frames:createDropDown(
    'category', frame, frame[ 'controls' ], 1, tracked:getConfig( ) 
  )
  d:SetPoint( 'topright', frame[ 'controls' ], 'topright', -100, -10 )

  local s = frames:createText( frame, 'state' )
  s:SetJustifyH( 'left' )
  s:SetSize( 50, 20 )
  s:SetPoint( 'topleft', vn, 'topright', 5, 0 )

  local vv = frames:createText( frame, 'value' )
  vv:SetJustifyH( 'left' )
  vv:SetSize( 300, 20 )
  vv:SetPoint( 'topleft', s, 'topright', 5, 0 )

  -- list iterate
  self[ 'registry'][ 'possible_mouseovers' ] = { }
  for category, category_data in pairs( t ) do
  	for i, row in pairs( category_data ) do

      -- track mouseover possibilities
      -- https://www.wowinterface.com/forums/showthread.php?t=46017
      ui[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ] = { 
        var   = nil,
        state = nil,
        value = nil,
        help  = nil,
      }

      -- describe var
      local c = frames:createText( frame[ 'containers' ][ 1 ], row[ 'command' ] )
      ui[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ][ 'var' ] = c

      c[ 'c_identifier' ] = category .. '|' .. row[ 'command' ]
      c[ 'c_value' ]      = row[ 'command' ]
      c:SetJustifyH( 'right' )
      c:SetSize( 225, 20 )
      c:SetPoint( 'topleft', frame[ 'containers' ][ 1 ], 'topleft', positions[ 'x' ], positions[ 'y' ] )

      local t = frames:createText( frame[ 'containers' ][ 1 ], tracked:indicate( row[ 'tracked' ] ) )
      ui[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ][ 'state' ] = t

      t[ 't_identifier' ] = category .. '|' .. row[ 'command' ]
      t[ 't_value' ]      = tracked:indicate( row[ 'tracked' ] )
      ui[ 'registry'][ t[ 't_identifier' ] ] = t
      t:SetJustifyH( 'left' )
      t:SetSize( 50, 20 )
      t:SetPoint( 'topleft', c, 'topright', 5, 0 )

      local s = frames:createSeperator( frame[ 'containers' ][ 1 ] )
      s:SetPoint( 'topleft', c, 'bottomleft', 10, 0, 0 )

      if row[ 'tracked' ] then
        self[ 'registry' ][ 'tracked_count' ] = self[ 'registry' ][ 'tracked_count' ] + 1
      end

      local v = frames:createEditBox( frame[ 'containers' ][ 1 ], row[ 'value' ] )
      ui[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ][ 'value' ] = v

      v[ 'v_identifier' ] = category .. '|' .. row[ 'command' ]
      v[ 'v_value' ]      = row[ 'value' ]
      v:SetJustifyH( 'left' )
      v:SetSize( 50, 20 )
      v:SetPoint( 'topleft', t, 'topright', 5, 0 )
      v:SetAutoFocus( false )
      v:SetFocus( false )

      local d = frames:createText( frame[ 'containers' ][ 1 ], row[ 'help' ] or '-' )
      ui[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ][ 'help' ] = d

      d[ 'd_identifier' ] = category .. '|' .. row[ 'command' ]
      d[ 'd_value' ]      = row[ 'help' ]
      d:SetJustifyH( 'left' )
      d:SetSize( 300, 20 )
      d:SetPoint( 'topleft', v, 'topright', 5, 0 )
      d:SetNonSpaceWrap( true )
      d:SetMaxLines( 2 )
      
      -- handle modification
      v:SetScript( 'OnEnterPressed', function( self )

        local i = gsub( self:GetText(), ' ', '' )
        local c, v = strsplit( '|', self[ 'v_identifier' ] )
        local updated = ui:updateConfig( frame, c, v, i, true )
        if updated then
          local dv = vars:getDefault( v )
          if dv and dv == i then
            ui[ 'registry'][ c .. '|' .. v ]:SetText( 'default' )
          elseif dv and dv ~= i then
            ui[ 'registry'][ c .. '|' .. v ]:SetText( 'modified' )
          end
        end
        self:ClearFocus( )

      end )

      -- handle edit escape
      v:SetScript( 'OnEscapePressed', function( self )
        self:SetAutoFocus( false )
        self:ClearFocus( )
      end )

      -- udpate dynamic data
      positions[ 'y' ]  = positions[ 'y' ] - 25
      list[ category .. '|' .. row[ 'command' ] ] = t
      self[ 'registry' ][ 'vars_count' ]   = self[ 'registry' ][ 'vars_count' ] + 1

  	end
  end

  self:updateStats( frame, self[ 'registry' ][ 'vars_count' ], self[ 'registry' ][ 'tracked_count' ], nil )

  return frame

end

-- updates configuration
--
-- returns bool
function ui:updateConfig( f, cvar_category, cvar_name, cvar_value, reload_graphix )
  
  if not reload_graphix then reload_graphix = false end

  local tracked = vars:GetModule( 'tracked' )
  tracked:queueConfig( cvar_category, cvar_name, cvar_value )

  local updated, tracked_count, message = tracked:applyConfig( cvar_category, load_graphix )
  self[ 'registry' ][ 'tracked_count' ] = tracked_count
  self:updateStats( 
    f, 
    self[ 'registry' ][ 'vars_count' ], 
    self[ 'registry' ][ 'tracked_count' ], 
    message 
  )

  return updated

end

-- updates stats
--
-- returns void
function ui:updateStats( f, vars_count, tracked_count, message )
  
  if not self[ 'registry'][ 'stats' ] then
    ui[ 'registry'][ 'stats' ] = { }
    local frames = vars:GetModule( 'frames' )

    -- what happened
    local t = frames:createText(
      f, 
      nil,
      vars[ 'theme' ][ 'font' ][ 'small' ],
      'warn' 
    )
    t:SetPoint( 'topleft', f[ 'updates' ], 'topleft', 10, -5 )
    ui[ 'registry'][ 'stats' ][ 'message' ] = t

    -- # vars found
    local found_label = frames:createText( 
      f, 
      'Vars:', 
      vars[ 'theme' ][ 'font' ][ 'small' ] 
    )
    found_label:SetPoint( 
      'bottomright', 
      f[ 'updates' ], 
      'bottomright', 
      -( 
        ( 
          f[ 'scroll' ][ 'ScrollBar' ]:GetWidth( ) 
        ) + 10 
      ), 
    10 )
    local found_count = frames:createText( 
      f, 
      nil, 
      vars[ 'theme' ][ 'font' ][ 'small' ], 
      'info' 
    )
    found_count:SetPoint( 'topleft', found_label, 'topright', 0, 0 )
    ui[ 'registry'][ 'stats' ][ 'vars_count' ] = found_count

    -- # vars tracked
    local tracked_label = frames:createText( 
      f, 
      'Tracking:', 
      vars[ 'theme' ][ 'font' ][ 'small' ] 
    )
    tracked_label:SetPoint( 'topleft', found_label, 'topleft', -( ( found_label:GetWidth( ) + found_label:GetWidth( ) ) + 25 ), 0 )
    local tracked_count = frames:createText( 
      f, 
      nil, 
      vars[ 'theme' ][ 'font' ][ 'small' ], 
      'info' 
    )
    tracked_count:SetPoint( 'topleft', tracked_label, 'topright', 0, 0 )
    ui[ 'registry'][ 'stats' ][ 'tracked_count' ] = tracked_count
  end
  self[ 'registry'][ 'stats' ][ 'message' ]:SetText( message )
  self[ 'registry'][ 'stats' ][ 'message' ]:Show( )
  C_Timer.After( 7, function( )
    self[ 'registry'][ 'stats' ][ 'message' ]:Hide( )
  end )
  self[ 'registry'][ 'stats' ][ 'vars_count' ]:SetText( vars_count )
  self[ 'registry'][ 'stats' ][ 'tracked_count' ]:SetText( tracked_count )

end

-- register addon
--
-- returns void
function ui:OnInitialize( )
  self:Enable( )
end

-- activated addon handler
--
-- returns void
function ui:OnEnable( )
  self:init( )
end