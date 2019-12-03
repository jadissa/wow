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
  list[ 'count' ] = 0
  list[ 'tracked' ] = 0
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

  local s = frames:createText( frame, 'state' )
  s:SetJustifyH( 'left' )
  s:SetSize( 50, 20 )
  s:SetPoint( 'topleft', vn, 'topright', 5, 0 )

  local vv = frames:createText( frame, 'value' )
  vv:SetJustifyH( 'left' )
  vv:SetSize( 300, 20 )
  vv:SetPoint( 'topleft', s, 'topright', 5, 0 )

  -- list iterate
  frame[ 'registry'] = { }
  frame[ 'registry'][ 'possible_mouseovers' ] = { }
  for category, category_data in pairs( t ) do
  	for i, row in pairs( category_data ) do

      -- track mouseover possibilities
      -- https://www.wowinterface.com/forums/showthread.php?t=46017
      frame[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ] = { 
        var   = nil,
        state = nil,
        value = nil,
        help  = nil,
      }

      -- describe var
      local c = frames:createText( frame[ 'containers' ][ 1 ], row[ 'command' ] )
      frame[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ][ 'var' ] = c

      c[ 'c_identifier' ] = category .. '|' .. row[ 'command' ]
      c[ 'c_value' ]      = row[ 'command' ]
      c:SetJustifyH( 'right' )
      c:SetSize( 225, 20 )
      c:SetPoint( 'topleft', frame[ 'containers' ][ 1 ], 'topleft', positions[ 'x' ], positions[ 'y' ] )

      local t = frames:createText( frame[ 'containers' ][ 1 ], tracked:indicate( row[ 'tracked' ] ) )
      frame[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ][ 'state' ] = t

      t[ 't_identifier' ] = category .. '|' .. row[ 'command' ]
      t[ 't_value' ]      = tracked:indicate( row[ 'tracked' ] )
      frame[ 'registry'][ t[ 't_identifier' ] ] = t
      t:SetJustifyH( 'left' )
      t:SetSize( 50, 20 )
      t:SetPoint( 'topleft', c, 'topright', 5, 0 )

      local s = frames:createSeperator( frame[ 'containers' ][ 1 ] )
      s:SetPoint( 'topleft', c, 'bottomleft', 10, 0, 0 )

      if row[ 'tracked' ] then
        list[ 'tracked' ] = list[ 'tracked' ] + 1
      end

      local v = frames:createEditBox( frame[ 'containers' ][ 1 ], row[ 'value' ] )
      frame[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ][ 'value' ] = v

      v[ 'v_identifier' ] = category .. '|' .. row[ 'command' ]
      v[ 'v_value' ]      = row[ 'value' ]
      v:SetJustifyH( 'left' )
      v:SetSize( 50, 20 )
      v:SetPoint( 'topleft', t, 'topright', 5, 0 )
      v:SetAutoFocus( false )
      v:SetFocus( false )

      local d = frames:createText( frame[ 'containers' ][ 1 ], row[ 'help' ] or '-' )
      frame[ 'registry'][ 'possible_mouseovers' ][ category .. '|' .. row[ 'command' ] ][ 'help' ] = d

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
        print( 'updated', c, v, 'to', i )
        
        local updated = ui:updateConfig( c, v, i, true )
        if updated then
          local dv = vars:getDefault( v )
          if dv and dv == i then
            frame[ 'registry'][ c .. '|' .. v ]:SetText( 'default' )
          elseif dv and dv ~= i then
            frame[ 'registry'][ c .. '|' .. v ]:SetText( 'modified' )
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
      list[ 'count' ]   = list[ 'count' ] + 1

  	end
  end

  -- list stats
  local dd = frames:createText( 
    frame, 
    'Vars:', 
    vars[ 'theme' ][ 'font' ][ 'small' ] 
  )
  dd:SetPoint( 
    'bottomright', 
    frame[ 'updates' ], 
    'bottomright', 
    -( 
      ( 
        frame[ 'scroll' ][ 'ScrollBar' ]:GetWidth( ) 
      ) + 10 
    ), 
  10 )
  local dc = frames:createText( 
    frame, 
    list[ 'count' ], 
    vars[ 'theme' ][ 'font' ][ 'small' ], 
    'info' 
  )
  dc:SetPoint( 'topleft', dd, 'topright', 0, 0 )
  
  td = frames:createText( 
    frame, 
    'Tracking:', 
    vars[ 'theme' ][ 'font' ][ 'small' ] 
  )
  td:SetPoint( 'topleft', dd, 'topleft', -( ( dd:GetWidth( ) + dc:GetWidth( ) ) + 50 ), 0 )
  -- @todo: make tracked count pull and store from db
  tc = frames:createText( 
    frame, 
    list[ 'tracked' ], 
    vars[ 'theme' ][ 'font' ][ 'small' ], 
    'info' 
  )
  tc:SetPoint( 'topleft', td, 'topright', 0, 0 )

  return frame

end

-- updates configuration
--
-- returns bool
function ui:updateConfig( cvar_category, cvar_name, cvar_value, reload_graphix )
  
  if not reload_graphix then reload_graphix = false end

  local tracked = vars:GetModule( 'tracked' )
  tracked:queueConfig( cvar_category, cvar_name, cvar_value )
  local updated, text = tracked:applyConfig( reload_graphix )
  if text ~= nil then
    local frames = vars:GetModule( 'frames' )
    local t = frames:createText( frame, text )
    t:SetPoint( 'topleft', frame[ 'updates' ], 'topleft', 10, -5 )
    C_Timer.After( 7, function( )
      t:Hide( )
    end )
  end

  return updated

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