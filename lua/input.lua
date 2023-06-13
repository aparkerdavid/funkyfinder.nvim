local input = {}
local function char_at(str, n)
  return str:sub(n, n)
end

function input.parse(input_str)
  local range_start = 1
  local range_end = 1
  local length = input_str:len()
  local substrings = {}
  local take_substring = function(sub_start, sub_end)
    local substring = input_str:sub(sub_start, sub_end)
    if substring ~= '' then
      table.insert(substrings, substring)
    end
    range_start = range_end + 1
    range_end = range_start
  end
  while range_end <= length do
    if char_at(input_str, range_end) == ' ' then
      take_substring(range_start, range_end - 1)
    elseif range_end == length then
      take_substring(range_start, range_end)
    elseif char_at(input_str, range_end) == '\\' then
      range_end = range_end + 2
    else
      range_end = range_end + 1
    end
  end
  return substrings
end

return input
