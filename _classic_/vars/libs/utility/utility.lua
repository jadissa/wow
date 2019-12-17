local utility = _G.LibStub:NewLibrary( 'utility', 1.0 )

function utility:dump( t, rows )

  if t == nil then
    print( 'empty' )
    return
  end

  if type( t ) == 'string' or type( t ) == 'number' then
    print( t )
    return

  end

  done = done or {}
  indent = indent or ''
  local nextIndent
  local i = 1
  if( type( t ) == 'table' ) then
    for key, value in pairs( t ) do
      if type(value) == 'table' and not done [value] then
        nextIndent = nextIndent or
          ( indent .. string.rep(' ', string.len( tostring( key ) ) +2 ) )
          done [value] = true
          print( indent .. '[' .. tostring(key) .. '] => {' );
          print( nextIndent .. '{' )
          self:dump( value, nextIndent .. string.rep( ' ', 2 ), done )
          print( nextIndent .. '}' )
          if( rows == i ) then
            return
          end
      else
        print( indent .. '[' .. tostring(key) .. '] => ' .. tostring(value) .. '' )
      end
      i = i + 1
    end
    print( "\n" )
  end

end

function utility:array_flip( array )

  local newarray = { }
  for k, v in ipairs( array ) do
    newarray[ v ] = k
  end
  return newarray
end

function utility:hex2rgb( hex )

  hex = hex:gsub( '#', '' )
  
  return tonumber( '0x' .. hex:sub( 1,2 ) ) / 255, 
    tonumber( '0x' .. hex:sub( 3,4 ) ) / 255, 
    tonumber( '0x' .. hex:sub( 5,6 ) ) / 255

end