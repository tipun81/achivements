-- Copied from:
-- https://github.com/Stepets/utf8.lua/blob/acf4a19/primitives/dummy.lua

Infinity_DoFile('utf8data')

utf8 = utf8 or {}

local gsub = string.gsub
local utf8charpattern = '[%z\1-\127\194-\244][\128-\191]*'

local function utf8replace(s, mapping)
  if type(s) ~= "string" then
    error("bad argument #1 to 'utf8replace' (string expected, got ".. type(s).. ")")
  end
  if type(mapping) ~= "table" then
    error("bad argument #2 to 'utf8replace' (table expected, got ".. type(mapping).. ")")
  end
  local result = gsub(s, utf8charpattern, mapping)
  return result
end

function utf8.upper(s)
  return utf8replace(s, utf8.lc_uc)
end

function utf8.lower(s)
  return utf8replace(s, utf8.uc_lc)
end

string.lower = utf8.lower 
string.upper = utf8.upper 

