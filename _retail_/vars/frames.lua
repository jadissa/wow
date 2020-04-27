 -------------------------------------
-- vars --------------
-- Emerald Dream/Grobbulus --------

-- 
local vars = LibStub( 'AceAddon-3.0' ):GetAddon( 'vars' )
local frames = vars:NewModule( 'frames', 'AceHook-3.0', 'AceEvent-3.0' )

-- parent persistence reference
--
-- returns table
function frames:_geParenttDB( )
  return vars:getDB( )
end

-- persistence namespace
--
-- returns table
function frames:getNameSpace( )

  return self:_geParenttDB( ):GetNamespace(
  	self:GetName( ) 
  )[ 'profile' ]

end

-- generate main frame
--
-- returns table
function frames:createFrame( ftype, fname, fparent, ftemplate )

  assert( ftype ~= nil and fname ~= nil, 'frames need both, a type and name' )

  if self[ fname ] ~= nil then
  	return self[ fname ]
  end
  self[ fname ] = CreateFrame(
  	ftype or nil, 
  	fname or nil, 
  	fparent or nil,
  	ftemplate or nil 
  )
  return self[ fname ]

end

-- creates UI
-- 
-- returns table
function frames:bootUI( )

  local f = self:createFrame( 'Frame', vars:GetName( ) .. 'Main', UIParent, 'UIPanelDialogTemplate' )

  f:SetFrameStrata( 'HIGH' )
  
  --f:SetFrameLevel( )
  f:SetClampedToScreen( true )
  f:SetSize( 700, 400 )
  f:DisableDrawLayer( 'OVERLAY' )
  f:DisableDrawLayer( 'BACKGROUND' )

  local t = f:CreateTexture( nil, 'ARTWORK', nil, 0 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\frame' )
  t:SetAllPoints( f )
  f[ 'background' ] = t

  local t = f:CreateTexture( nil, 'ARTWORK', nil, 1 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\bar-disabled-new' )
  t:SetSize( f:GetWidth( ), 32 )
  t:SetPoint( 'topleft', f, 'topleft', 0, 0 )
  f[ 'titlearea' ] = t

  f:EnableKeyboard( true )
  f:EnableMouse( true )
  f:SetResizable( false )
  f:SetMovable( true )
  f:RegisterForDrag( 'LeftButton' )  
  local s = frames:getNameSpace( )[ 'scale' ]
  if s ~= nil then
    f:SetScale( s )
  else
    f:SetScale( 1 )
  end
  local d = frames:getNameSpace( )[ 'dropzone' ]
  if d ~= nil then
    if d[ 'x' ] ~= nil and d[ 'y' ] ~= nil
    then
      f:ClearAllPoints( )
      f:SetPoint(
        d[ 'p' ], 
        d[ 'rt' ], 
        d[ 'rp' ], 
        d[ 'x' ], 
        d[ 'y' ] 
      )
      f:SetUserPlaced( true )
    end
  else
    f:SetPoint( 'center', 0, 0 )
  end
  f[ 'x' ] = f:GetLeft( ) 
  f[ 'y' ] = ( f:GetTop( ) - f:GetHeight( ) )

  f:SetScript( 'OnDragStart', function( self )
    self[ 'moving' ] = true
    self:StartMoving( )
  end )

  f:SetScript( 'OnDragStop', function( self )
    self[ 'moving' ] = false
    self:StopMovingOrSizing( )
    self[ 'x' ] = self:GetLeft( ) 
    self[ 'y' ] = ( self:GetTop( ) - self:GetHeight( ) ) 
    self:SetUserPlaced( true )
    local p, rt, rp, x, y = self:GetPoint( )
    local d = {
      p   = p,
      rt  = rt, 
      rp  = rp,
      x   = x,
      y   = y,
    }
    frames:getNameSpace( )[ 'dropzone' ] = d
  end )

  f:SetScript( 'OnUpdate', function( self ) 
    if self[ 'moving' ] == true then
      self[ 'x' ] = self:GetLeft( ) 
      self[ 'y' ] = ( self:GetTop( ) - self:GetHeight( ) ) 
    end
  end )

  f[ 'controls' ] = self:createFrame( 'Frame', 'controls', f )
  f[ 'controls' ]:SetSize( f:GetWidth( ) - 20, 45 )
  f[ 'controls' ]:SetPoint( 'topleft', f[ 'titlearea' ], 'topleft', 10, -( f[ 'titlearea' ]:GetHeight( ) + 2 ) )
  local t = f:CreateTexture( nil, 'ARTWORK', nil, 0 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\frame' )
  t:SetAllPoints( f[ 'controls' ] )
  f[ 'controls' ][ 'background' ] = t

  local t = f:CreateTexture( nil, 'ARTWORK', nil, 3 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\AzeriteCenterBGGold' )
  t:SetSize( 65, f[ 'controls' ]:GetHeight( ) )
  t:SetVertTile( true )
  t:SetPoint( 'topright', f[ 'controls' ], 'topright', 0, 5 )
  f[ 'controls' ][ 'controlsart' ] = t

  f[ 'browser' ] = self:createFrame( 'Frame', 'browser', f )
  f[ 'browser' ]:SetSize( 
    f:GetWidth( ) - 20, 
    ( 
      f:GetHeight( ) - ( f[ 'titlearea' ]:GetHeight( ) + f[ 'controls' ]:GetHeight( ) )
    ) - 8 
  )
  f[ 'browser' ]:SetPoint( 'topleft', f[ 'controls' ], 'bottomleft', 0, -10 )
  local t = f:CreateTexture( nil, 'ARTWORK', nil, 0 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\frame' )
  t:SetAllPoints( f[ 'browser' ] )
  f[ 'browser' ][ 'background' ] = t

  local t = f:CreateTexture( nil, 'ARTWORK', nil, 3 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\AzeriteCenterBGGold' )
  t:SetSize( 65, f[ 'browser' ]:GetHeight( ) )
  t:SetPoint( 'topright', f[ 'browser' ], 'topright', 0, 0 )
  f[ 'browser' ][ 'browserart' ] = t

  f[ 'updates' ] = self:createFrame( 'Frame', 'updates', f )
  f[ 'updates' ]:SetSize( f:GetWidth( ) - 20, 25 )
  f[ 'updates' ]:SetPoint( 'topleft', f[ 'browser' ], 'bottomleft', 0, -5 )
  local t = f:CreateTexture( nil, 'ARTWORK', nil, 0 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\frame' )
  t:SetAllPoints( f[ 'updates' ] )
  f[ 'updates' ][ 'background' ] = t

  f[ 'scroll' ] = self:createFrame(
    'ScrollFrame', vars:GetName( ) .. 'Scroll', f, 'UIPanelScrollFrameTemplate' 
  )
  f[ 'scroll' ]:SetPoint( 'topleft', f[ 'browser' ], 'topleft', -25, -2 )
  f[ 'scroll' ]:SetPoint( 'bottomright', f[ 'browser' ], 'bottomright', -25, 2 )

  local tab_names = { { text = 'Mod' }, { text = 'Sys' } }
  f[ 'containers' ] = self:createTabs( f, tab_names )

  f[ 'resizer' ] = self:createFrame( 'Button', 'resize', f )
  f[ 'resizer' ]:SetSize( 16, 16 )
  f[ 'resizer' ]:SetPoint( 'bottomright' )
  f[ 'resizer' ]:SetNormalTexture( 'Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up' )
  f[ 'resizer' ]:SetHighlightTexture( 'Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight' )
  f[ 'resizer' ]:SetPushedTexture( 'Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down' )
  f[ 'resizer' ]:SetScript( 'OnMouseDown', function( self, b )
    if b == 'LeftButton' then
      self[ 'scaling' ] = true
    end
  end )
  f[ 'resizer' ]:SetScript( 'OnMouseUp', function( self, b )
    if b == 'LeftButton' then
      self[ 'scaling' ] = false
      frames:getNameSpace( )[ 'scale' ] = self:GetParent( ):GetScale( )
    end
  end )
  f[ 'resizer' ]:SetScript( 'OnUpdate', function( self, b )
    if self[ 'scaling' ] == true then
      local cx, cy = GetCursorPosition( )
      cx = cx / self:GetEffectiveScale( ) - self:GetParent( ):GetLeft( ) 
      cy = self:GetParent( ):GetHeight( ) - ( cy / self:GetEffectiveScale( ) - self:GetParent( ):GetBottom( ) )

      local s = cx / self:GetParent( ):GetWidth( )
      local tx, ty = self:GetParent( )[ 'x' ] / s, self:GetParent( )[ 'y' ] / s
      
      self:GetParent( ):ClearAllPoints( )
      self:GetParent( ):SetScale( self:GetParent( ):GetScale() * s )
      self:GetParent( ):SetPoint( 'bottomleft', UIParent, 'bottomleft', tx, ty )
      self:GetParent( )[ 'x' ], self:GetParent( )[ 'y' ] = tx, ty
    end
  end )

  f:Hide( )

  return f

end

-- creates line element
-- 
-- returns table
function frames:createSeperator( f )

  local s = f:CreateTexture( nil, 'ARTWORK', nil, 2 )
  s:SetTexture( 'Interface\\Addons\\vars\\textures\\seperator' )
  s:SetSize( f:GetWidth( ), 2 )
  s:SetAlpha( 0.1 )
  
  return s

end

-- creates button
-- 
-- returns table
function frames:createButton( f, text, name )

  if name == nil then name = random( 0, 9999 ) end
  local b = self:createFrame( 'Button', name, f, 'UIPanelButtonNoTooltipTemplate' )
  b:DisableDrawLayer( 'BACKGROUND' )
  b:SetNormalTexture( 'Interface\\Addons\\vars\\textures\\button-normal' )
  b:SetPushedTexture( 'Interface\\Addons\\vars\\textures\\button-pushed' )
  b:SetDisabledTexture( 'Interface\\Addons\\vars\\textures\\button-disabled' )
  b:SetText( text )

  return b

end

function frames:createCheckbox( f, text, name )

  if name == nil then name = random( 0, 9999 ) end
  local c = self:createFrame( 'CheckButton', name, f, 'UICheckButtonTemplate' )
  c:SetNormalTexture( 'Interface\\Buttons\\UI-Button-Outline' )
  c:SetPushedTexture( 'Interface\\Buttons\\UI-CheckBox-Down' )
  c:SetHighlightTexture( 'Interface\\Buttons\\CheckButtonHilight-Blue' )
  c:SetCheckedTexture( 'Interface\\Buttons\\UI-CheckBox-Check' )
  c:SetDisabledTexture( 'Interface\\Buttons\\UI-CheckBox-Check-Disabled' )
  
  c[ 'text' ] = self:createText( f, text )
  c[ 'text' ]:SetPoint( 'topleft', c, 'topright', 1, -6 )

  --c:SetChecked( true )

  return c

end

-- creates var editor
-- 
-- returns table
function frames:createEditBox( f, text, name, theme )

  if text == nil then text = '-' end
  if name == nil then name = random( 0, 9999 ) end
  if theme == nil then theme = 'warn' end
  local e = self:createFrame( 'EditBox', name, f )
  e:SetFontObject( GameFontHighlightSmall )
  e:SetMultiLine( false )
  e:SetMaxLetters( 25 )
  e:SetText( text )
  e:SetTextColor( 
    vars[ 'theme' ][ theme ][ 'r' ],
    vars[ 'theme' ][ theme ][ 'g' ],
    vars[ 'theme' ][ theme ][ 'b' ],
    0.7
  )

  return e

end

-- creates text
-- 
-- returns table
function frames:createText( f, text, size, theme )

  if size == nil then size = vars[ 'theme' ][ 'font' ][ 'normal' ] end
  if theme == nil then theme = 'text' end
  local t = f:CreateFontString( nil, 'ARTWORK', 'GameFontHighlightSmall' )
  t:SetFont( vars[ 'theme' ][ 'font' ][ 'family' ], size, vars[ 'theme' ][ 'font' ][ 'flags' ] )
  t:SetText( text )
  t:SetTextColor( 
    vars[ 'theme' ][ theme ][ 'r' ],
    vars[ 'theme' ][ theme ][ 'g' ],
    vars[ 'theme' ][ theme ][ 'b' ],
    0.7
  )
  t:SetJustifyH( 'left' )
  t:SetJustifyV( 'top' )

  return t

end

-- creates tabs
--
-- returns table
function frames:createTabs( f, tab_names )

  f[ 'containers' ] = { }
  f[ 'numTabs' ]    = #tab_names

  for i, tab_name in pairs( tab_names ) do
    local name = f:GetName( ) .. 'Tab' .. i
    local t = self:createFrame( 'Button', f:GetName( ) .. 'Tab' .. i, f, 'CharacterFrameTabButtonTemplate' )
    f[ f:GetName( ) .. 'Tab' .. i ] = f:GetName( ) .. 'Tab' .. i
    local font = frames:createText( 
      t, 
      tab_name[ 'text' ], 
      vars[ 'theme' ][ 'font' ][ 'normal' ], 
      'info' 
    )
    font:SetPoint( 'topleft', t, 'topleft', 25, -10 )
    t:SetID( i )
    _G[ f:GetName( ) .. 'Tab' .. i .. 'Text' ]:SetTextColor( 
      vars[ 'theme' ] ['info' ][ 'r' ], 
      vars[ 'theme' ][ 'info' ][ 'g' ], 
      vars[ 'theme' ][ 'info' ][ 'b' ]
    )
    t[ 'content' ] = self:createFrame( 'Frame', name .. 'Content', f[ 'scroll' ] )
    t[ 'content' ]:SetSize( f[ 'browser' ]:GetWidth( ), f[ 'browser' ]:GetHeight( ) )
    t[ 'content' ]:Hide( )
    t:SetScript( 'OnClick', function( self )

      frames:tabClick( self )

    end )
    if i == 1 then
      t:SetPoint( 'topleft', f, 'bottomleft', 5, 7 )
    else
      t:SetPoint( 'topleft', _G[ f:GetName( ) .. 'Tab' .. ( i - 1 ) ], 'topright', -14, 0 )
    end
    f[ 'containers' ][ i ] = t[ 'content' ]
  end
  self:tabClick( _G[ f:GetName( ) .. 'Tab1' ] )

  return f[ 'containers' ]

end

-- tab click event
--
-- returns void
function frames:tabClick( self )
  PanelTemplates_SetTab( self:GetParent( ), self:GetID( ) )

  local scroll_child = self:GetParent( )[ 'scroll' ]:GetScrollChild( )
  if scroll_child then
    scroll_child:Hide( )
  end
  self:GetParent( )[ 'scroll' ]:SetScrollChild( self[ 'content' ] )
  self:GetParent( )[ 'scroll' ][ 'ScrollBar' ]:SetValue( 0 )
  self[ 'content' ]:Show( )

  local s = frames:getNameSpace( )[ 'sizes' ]
  if s == nil then

    local size = { 
      w = self:GetParent( )[ 'controls' ]:GetWidth( ),
      h = self:GetParent( )[ 'controls' ]:GetHeight( ),
    }

    frames:getNameSpace( )[ 'sizes' ] = { }
    frames:getNameSpace( )[ 'sizes' ][ 'controls' ] = size

    size = { 
      w = self:GetParent( )[ 'browser' ]:GetWidth( ),
      h = self:GetParent( )[ 'browser' ]:GetHeight( ),
    }
    frames:getNameSpace( )[ 'sizes' ][ 'browser' ] = size

  end

  s = frames:getNameSpace( )[ 'sizes' ]

  if self:GetID( ) == 1 then
    self:GetParent( )[ 'controls' ]:Show( )
    self:GetParent( )[ 'controls' ][ 'background' ]:Show( )
    self:GetParent( )[ 'controls' ][ 'controlsart' ]:Show( )
    self:GetParent( )[ 'browser' ]:SetSize(
      s[ 'browser' ][ 'w' ], 
      s[ 'browser' ][ 'h' ] - s[ 'controls' ][ 'h' ] + 45
    )
    self:GetParent( )[ 'browser' ]:ClearAllPoints( )
    self:GetParent( )[ 'browser' ]:SetPoint(
      'topleft', self:GetParent( )[ 'controls' ], 'bottomleft', 0, -5
    )
    self:GetParent( )[ 'browser' ][ 'browserart' ]:SetSize(
      65, self:GetParent( )[ 'browser' ]:GetHeight( )
    )
    self:GetParent( )[ 'scroll' ][ 'ScrollBar' ][ 'ScrollDownButton' ]:Enable( )
    self:GetParent( )[ 'scroll' ][ 'ScrollBar' ][ 'ScrollUpButton' ]:Enable( )
  elseif self:GetID( ) == 2 then
    self:GetParent( )[ 'controls' ]:Hide( )
    self:GetParent( )[ 'controls' ][ 'background' ]:Hide( )
    self:GetParent( )[ 'controls' ][ 'controlsart' ]:Hide( )
    self:GetParent( )[ 'browser' ]:SetSize(
      s[ 'browser' ][ 'w' ], 
      s[ 'browser' ][ 'h' ] + s[ 'controls' ][ 'h' ] + 5
    )
    self:GetParent( )[ 'browser' ]:ClearAllPoints( )
    self:GetParent( )[ 'browser' ]:SetPoint(
      'topleft', self:GetParent( )[ 'controls' ], 'topleft', 0, 0
    )
    self:GetParent( )[ 'browser' ][ 'browserart' ]:SetSize(
      65, self:GetParent( )[ 'browser' ]:GetHeight( ) 
    )
    self:GetParent( )[ 'scroll' ][ 'ScrollBar' ][ 'ScrollDownButton' ]:Disable( )
    self:GetParent( )[ 'scroll' ][ 'ScrollBar' ][ 'ScrollUpButton' ]:Disable( )
  end
end

-- sorts table in direction
--
-- returns table
function frames:sort( t, direction )
  
  if direction == nil then direction = 'asc' end
  local sorted = { }
  for k, v in pairs( t ) do
    tinsert( sorted, v )
  end
  if direction == 'asc' then
    table.sort( sorted )
  else
    table.sort( sorted, function( a,b ) return 
      strlower( a ) > strlower( b )
    end )
  end

  return sorted

end

-- creates dropdown
--
-- returns table
function frames:createDropDown( calling_instance, name, parent, list )
  
  local f = self:createFrame(
    'Frame', name, parent, 'UIDropDownMenuTemplate'
  )
  f[ 'calling_instance' ] = calling_instance
  f[ 'list' ] = list

  UIDropDownMenu_Initialize( f, function( self )
    frames:dropdownInitialize( f, self[ 'list' ], self[ 'calling_instance' ] )
  end )

  return f

end

function frames:dropdownInitialize( frame, list_items, calling_instance )
  
  local list = { }
  local selected_index = 1
  for i, v in pairs( list_items ) do
    local b = UIDropDownMenu_CreateInfo()
    if v[ 'checked' ] == true then
      selected_index     = i
    else
      b[ 'checked' ]     = false
    end
    --b[ 'customFrame' ]   = someframe -- inherits UIDropDownCustomMenuEntryTemplate
    
    b[ 'isTitle' ]       = false
    b[ 'text' ]          = v[ 'text' ]
    b[ 'value' ]         = v[ 'text' ]
    b[ 'isNotRadio' ]    = true
    b[ 'notClickable' ]  = false
    b[ 'noClickSound' ]  = true
    b[ 'leftPadding' ]   = nil
    b[ 'padding' ]       = nil
    b[ 'justifyH' ]      = nil
    b[ 'colorCode' ]     = '|cff' .. vars[ 'theme' ][ 'text' ][ 'hex' ]
    b[ 'func' ]          = function( self )
    --CreateFont
    --[[
    local font = CreateFont( vars[ 'theme' ][ 'font' ][ 'family' ] );
    font:SetFontObject( 'GameFontHighlightSmall' );
    font:SetTextColor( 0, 1, 0 );

    b[ 'fontObject' ]    = font
    ]]

    UIDropDownMenu_SetSelectedValue( frame, self[ 'value' ] )
    UIDropDownMenu_RefreshAll( frame, self[ 'value' ] )

      -- this is a probably a terrible hack
      calling_instance:dropdownOnChange( frame )
    end 
    list[ i ] = b
    UIDropDownMenu_AddButton( b )
  end
  local selected_value  = UIDropDownMenu_GetSelectedValue( frame )
  if selected_value == nil then
    UIDropDownMenu_SetSelectedValue( frame, list[ selected_index ][ 'value' ] )
  end
  UIDropDownMenu_JustifyText( frame, 'LEFT' )

end

-- setup forms
--
-- return void
function frames:init( )

  local persistence = self:getNameSpace( )
  if not persistence[ 'dropzone' ] then
    persistence[ 'dropzone' ] = nil
  end

end

-- register persistence
--
-- returns void
function frames:OnInitialize( )

  local defaults = { 
    profile = { }
  }
  self:_geParenttDB( ):RegisterNamespace(
  	self:GetName( ), defaults
  )
  self:Enable( )

end

-- activated module handler
--
-- returns void
function frames:OnEnable( )

  if vars[ 'current' ] == false then
    return
  end
  self:init( )

end