 -------------------------------------
-- jvars --------------
-- fórsákén,  Emerald Dream --------

-- 
local vars = LibStub( 'AceAddon-3.0' ):GetAddon( 'vars' )
local ui = vars:NewModule( 'ui', 'AceConsole-3.0' )
local tracked = vars:GetModule( 'tracked' )
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
function ui:dataPreProcess( )

  local t = { }
  local persistence = tracked:getNameSpace( )
  self[ 'registry' ][ 'tracked_count' ] = 0
  self[ 'registry' ][ 'vars_count' ] = 0

  for category, category_data in pairs( tracked:getConfig( ) ) do
    for i, row in pairs( category_data ) do
      if ui[ 'registry'][ category .. '|' .. row[ 'command' ] ] ~= nil then
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'var' ]:Hide( )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'state' ]:Hide( )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'sep' ]:Hide( )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ]:Hide( )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ]:UnregisterAllEvents( )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'help' ]:Hide( )
      end
      if row[ 'tracked' ] == true then
        self[ 'registry' ][ 'tracked_count' ] = self[ 'registry' ][ 'tracked_count' ] + 1
      end
      self[ 'registry' ][ 'vars_count' ] = self[ 'registry' ][ 'vars_count' ] + 1
    end

    if category == persistence[ 'search' ][ 'category_filter' ] then
      for i, row in pairs( category_data ) do
        if persistence[ 'search' ][ 'staus_filter' ] == 'all' then
          t[ i ] = row[ 'command' ]
        end
        if persistence[ 'search' ][ 'staus_filter' ] == 'tracked' and row[ 'tracked' ] == true then
          t[ i ] = row[ 'command' ]
        elseif persistence[ 'search' ][ 'staus_filter' ] == 'default' and row[ 'tracked' ] == false then
          t[ i ] = row[ 'command' ]
        end
      end
    end
  end

  return t

end

function ui:filterList( )

  local t = { }

  local persistence = tracked:getNameSpace( )
  local category    = persistence[ 'search' ][ 'category_filter' ]
  local data        = self:dataPreProcess( )
  local frames      = vars:GetModule( 'frames' )
  local var_names   = frames:sort( data, persistence[ 'search' ][ 'sort_direction' ] ) 

  for o, var_name in pairs( var_names ) do
    for cat, category_data in pairs( tracked:getConfig( ) ) do
      if cat == category then
        for i, row in pairs( category_data ) do
          if row[ 'command' ] == var_name then
            if t[ category ] == nil then
              t[ category ] = { }
            end
            t[ category ][ o ] = row
          end
        end
      end
    end
  end

  return t

end

function ui:iterateList( list )

  local positions   = { x = 30, y = 0 }
  local frames      = vars:GetModule( 'frames' )
  for category, category_data in pairs( list ) do
    for i, row in pairs( category_data ) do

      if type( row ) == 'table' then

        if ui[ 'registry'][ category .. '|' .. row[ 'command' ] ] == nil then

          local c = frames:createText( self[ 'menu' ][ 'containers' ][ 1 ], row[ 'command' ] )
          c[ 'c_identifier' ] = category .. '|' .. row[ 'command' ]
          c[ 'c_value' ]      = row[ 'command' ]
          c:SetJustifyH( 'right' )
          c:SetSize( 225, 20 )

          local t = frames:createText( self[ 'menu' ][ 'containers' ][ 1 ], tracked:indicate( row[ 'tracked' ] ) )
          t[ 't_identifier' ] = category .. '|' .. row[ 'command' ]
          t[ 't_value' ]      = tracked:indicate( row[ 'tracked' ] )
          ui[ 'registry'][ t[ 't_identifier' ] ] = t
          t:SetJustifyH( 'left' )
          t:SetSize( 50, 20 )

          local s = frames:createSeperator( self[ 'menu' ][ 'containers' ][ 1 ] )
          s:SetPoint( 'topleft', c, 'bottomleft', 10, 0, 0 )

          if row[ 'tracked' ] then
            self[ 'registry' ][ 'tracked_count' ] = self[ 'registry' ][ 'tracked_count' ] + 1
          end

          local v = frames:createEditBox( self[ 'menu' ][ 'containers' ][ 1 ], row[ 'value' ] )
          v[ 'v_identifier' ] = category .. '|' .. row[ 'command' ]
          v[ 'v_value' ]      = row[ 'value' ]
          v:SetCursorPosition( 0 )
          v:SetJustifyH( 'left' )
          v:SetSize( 50, 20 )
          v:SetAutoFocus( false )
          v:SetFocus( false )

          local d = frames:createText( self[ 'menu' ][ 'containers' ][ 1 ], row[ 'help' ] or '-' )
          d[ 'd_identifier' ] = category .. '|' .. row[ 'command' ]
          d[ 'd_value' ]      = row[ 'help' ]
          d:SetJustifyH( 'left' )
          d:SetSize( 300, 20 )
          d:SetNonSpaceWrap( true )
          d:SetMaxLines( 2 )

          ui[ 'registry'][ category .. '|' .. row[ 'command' ] ] = { }
          ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'var' ] = c
          ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'state' ] = t
          ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'sep' ] = s
          ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ] = v
          ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'help' ] = d
          
        end

        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'var' ]:SetPoint( 
          'topleft', self[ 'menu' ][ 'containers' ][ 1 ], 'topleft', positions[ 'x' ], positions[ 'y' ]
        )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'var' ]:Show( )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'state' ]:SetPoint(
          'topleft', ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'var' ], 'topright', 20, 0
        )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'state' ]:Show( )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'sep' ]:SetPoint(
          'topleft', ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'var' ], 'bottomleft', 10, 0, 0
        )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'sep' ]:Show( )

        --handle focus
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ]:SetScript( 
          'OnEditFocusGained', function( self )
          self:HighlightText( )
        end )
        -- or loss thereof
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ]:SetScript(
          'OnEditFocusLost', function( self )
          self:HighlightText( 0,0 )
        end )
        
        -- handle modification
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ]:SetScript(
          'OnEnterPressed', function( self )

          local i = gsub( self:GetText(), ' ', '' )
          local c, v = strsplit( '|', self[ 'v_identifier' ] )
          local updated = ui:updateConfig( ui[ 'menu' ], c, v, i )
          if updated then
            local dv = vars:getDefault( v )
            if dv and dv == i then
              ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'state' ]:SetText( 'default' )
            elseif dv and dv ~= i then
              ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'state' ]:SetText( 'modified' )
            end
          end
          self:ClearFocus( )

        end )

        -- handle edit escape
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ]:SetScript(
          'OnEscapePressed', function( self )
          self:SetAutoFocus( false )
          self:ClearFocus( )
        end )

        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ]:SetPoint(
          'topleft', ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'state' ], 'topright', 20, 0
        )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ]:Show( )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'help' ]:SetPoint(
          'topleft', ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'edit' ], 'topright', 20, 0
        )
        ui[ 'registry'][ category .. '|' .. row[ 'command' ] ][ 'help' ]:Show( )

        -- udpate dynamic data
        positions[ 'y' ]  = positions[ 'y' ] - 25
        list[ category .. '|' .. row[ 'command' ] ] = t

      end

    end
  end

  self:updateStats( self[ 'menu' ], self[ 'registry' ][ 'vars_count' ], self[ 'registry' ][ 'tracked_count' ], nil )

end

-- provide access to ui
--
-- returns table
function ui:createMenu( )
  
  local persistence = tracked:getNameSpace( )
  local frames = vars:GetModule( 'frames' )
  self[ 'menu' ] = self[ 'menu' ] or frames:bootUI( )
  
  local vn = frames:createText( self[ 'menu' ], 'var' )
  vn:SetJustifyH( 'right' )
  vn:SetSize( 225, 20 )
  vn:SetPoint( 'topleft', self[ 'menu' ][ 'controls' ], 'topleft', 0, -25 )

  local s = frames:createButton( self[ 'menu' ], '^', 'sorted' )
  s:SetSize( 10, 10 )
  s:SetPoint( 'topleft', vn, 'topright', 0, 0 )
  s:SetFrameLevel( 5 )
  s:RegisterForClicks( 'LeftButtonDown' )
  s:SetScript( 'OnClick', function( self )
    if persistence[ 'search' ][ 'sort_direction' ] == 'asc' then
      persistence[ 'search' ][ 'sort_direction' ] = 'desc'
    else
      persistence[ 'search' ][ 'sort_direction' ] = 'asc'
    end
    ui:iterateList( ui:filterList( ) )
  end )

  local vs = frames:createText( self[ 'menu' ], 'state' )
  vs:SetJustifyH( 'left' )
  vs:SetSize( 50, 20 )
  vs:SetPoint( 'topleft', vn, 'topright', 20, 0 )

  local vv = frames:createText( self[ 'menu' ], 'value' )
  vv:SetJustifyH( 'left' )
  vv:SetSize( 50, 20 )
  vv:SetPoint( 'topleft', vs, 'topright', 20, 0 )

 local vh = frames:createText( self[ 'menu' ], 'help' )
  vh:SetJustifyH( 'left' )
  vh:SetSize( 50, 20 )
  vh:SetPoint( 'topleft', vv, 'topright', 20, 0 )

  self:iterateList( self:filterList( ) )

  local i   = 1
  local ddl = { }
  for category, _ in pairs( tracked:getConfig( ) ) do
    
    ddl[ i ] = { }
    if category == persistence[ 'search' ][ 'category_filter' ] then
      ddl[ i ][ 'checked' ] = true
    end
    ddl[ i ][ 'text' ]   = category
    ddl[ i ][ 'value' ]  = category
    i = i + 1
  end
  local d = frames:createDropDown( self, 'category', self[ 'menu' ], ddl )
  d:SetPoint( 'topleft', vh, 'topright', -15, 8 )

  return self[ 'menu' ]

end

function ui:dropdownOnChange( dropdown_frame )
  
  local persistence     = tracked:getNameSpace( )
  local selected_value  = UIDropDownMenu_GetSelectedValue( dropdown_frame )

  if persistence[ 'search' ][ 'category_filter' ] ~= selected_value then
    persistence[ 'search' ][ 'category_filter' ] = selected_value

    UIDropDownMenu_ClearAll( dropdown_frame )
    UIDropDownMenu_SetSelectedValue( dropdown_frame, selected_value )

    self:iterateList( self:filterList( ) )
  end

  CloseDropDownMenus( )

end

-- updates configuration
--
-- returns bool
function ui:updateConfig( f, cvar_category, cvar_name, cvar_value )

  tracked:queueConfig( cvar_category, cvar_name, cvar_value )

  local updated, tracked_count, message = tracked:applyConfig( cvar_category )
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
    tracked_label:SetPoint(
      'topleft', 
      found_label, 
      'topleft', 
      -( ( found_label:GetWidth( ) + found_label:GetWidth( ) ) + 25 ), 
      0 
    )
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