 -------------------------------------
-- jvars --------------
-- fórsákén,  Emerald Dream --------

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

  f:SetFrameStrata( 'DIALOG' )
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
  f:SetScript( 'OnDragStart', function( self )
    self:StartMoving( )
  end )
  f:SetScript( 'OnDragStop', function( self )
    self:StopMovingOrSizing( )
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

  --[[
  local c = self:createFrame( 'Frame', vars:GetName( ) .. 'Controls', f )
  c:SetSize( f:GetWidth( ) - 20, 45 )
  c:SetPoint( 'topleft', f[ 'titlearea' ], 'bottomleft', 5, 0 )
  local t = c:CreateTexture( nil, 'ARTWORK', nil, 2 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\frame' )
  t:SetAllPoints( )
  f[ 'controls' ] = c
  ]]
  local t = f:CreateTexture( nil, 'ARTWORK', nil, 2 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\frame' )
  t:SetSize( f:GetWidth( ) - 20, 45 )
  t:SetPoint( 'topleft', f, 'topleft', 10, -( f[ 'titlearea' ]:GetHeight( ) + 2 ) )
  f[ 'controls' ] = t

  local t = f:CreateTexture( nil, 'ARTWORK', nil, 3 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\AzeriteCenterBGGold' )
  t:SetSize( 65, f[ 'controls' ]:GetHeight( ) )
  t:SetVertTile( true )
  t:SetPoint( 'topright', f[ 'controls' ], 'topright', 0, 5 )
  f[ 'controlsart' ] = t

  local t = f:CreateTexture( nil, 'ARTWORK', nil, 2 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\frame' )
  t:SetSize( 
    f:GetWidth( ) - 20, 
    ( 
      f:GetHeight( ) - ( f[ 'titlearea' ]:GetHeight( ) + f[ 'controls' ]:GetHeight( ) )
    ) - 55 
  )
  t:SetPoint( 'topleft', f[ 'controls' ], 'bottomleft', 0, -10 )
  f[ 'browser' ] = t

  local t = f:CreateTexture( nil, 'ARTWORK', nil, 3 )
  t:SetTexture( 'Interface\\Addons\\vars\\textures\\AzeriteCenterBGGold' )
  t:SetSize( 65, f[ 'browser' ]:GetHeight( ) )
  t:SetPoint( 'topright', f[ 'browser' ], 'topright', 0, 0 )
  f[ 'browserart' ] = t

  local u = f:CreateTexture( nil, 'ARTWORK', nil, 2 )
  u:SetTexture( 'Interface\\Addons\\vars\\textures\\frame' )
  u:SetSize( f:GetWidth( ) - 20, 25 )
  u:SetPoint( 'topleft', f[ 'browser' ], 'bottomleft', 0, -5 )
  f[ 'updates' ] = u

  f[ 'scroll' ] = self:createFrame(
    'ScrollFrame', vars:GetName( ) .. 'Scroll', f, 'UIPanelScrollFrameTemplate' 
  )
  f[ 'scroll' ]:SetPoint( 'topleft', f[ 'browser' ], 'topleft', -25, -2 )
  f[ 'scroll' ]:SetPoint( 'bottomright', f[ 'browser' ], 'bottomright', -25, 2 )
  f[ 'content_region' ] = self:createFrame(
    'Frame', vars:GetName( ) .. 'Content', f[ 'scroll' ]
  )
  f[ 'content_region' ]:SetSize( f[ 'browser' ]:GetWidth( ), f[ 'browser' ]:GetHeight( ) - 20 )
  f[ 'content_region' ]:SetAllPoints( )
  f[ 'scroll' ]:SetScrollChild( f[ 'content_region' ] )
  local tab_names = {
    {
      text = 'Mod'
    },
    --[[{
      text = 'Sys'
    },]]
  }
  self:createTabs( f, tab_names )

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
  local b = self:createFrame( 'Button', 'asdf', f, 'UIPanelButtonNoTooltipTemplate' )
  b:DisableDrawLayer( 'BACKGROUND' )
  b:SetNormalTexture( 'Interface\\Addons\\vars\\textures\\button-normal' )
  b:SetPushedTexture( 'Interface\\Addons\\vars\\textures\\button-pushed' )
  b:SetDisabledTexture( 'Interface\\Addons\\vars\\textures\\button-disabled' )
  b:SetText( text )

  return b

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

-- creates tabs
--
-- returns table, table
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

end

-- tab click event
--
-- returns void
function frames:tabClick( self )
  PanelTemplates_SetTab( self:GetParent( ), self:GetID( ) )

  --self:GetParent( )[ 'browser' ]:Hide( )

  local scroll_child = self:GetParent( )[ 'scroll' ]:GetScrollChild( )
  if scroll_child then
    scroll_child:Hide( )
  end

  self:GetParent( )[ 'scroll' ]:SetScrollChild( self[ 'content' ] )
  self:GetParent( )[ 'scroll' ][ 'ScrollBar' ]:SetValue( 0 )
  self[ 'content' ]:Show( )

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
      -- @todo: figure out way to uncheck previously checked items
      -- before re-enabling this
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
    --b[ 'colorCode' ]   = '|cff' .. vars[ 'theme' ][ 'b' ][ 'hex' ]
    b[ 'func' ]          = function( self )

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