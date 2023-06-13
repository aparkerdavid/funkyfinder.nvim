local input = {}
local function char_at(str, n)
  return str:sub(n, n)
end

function input.parse(input_str)
  local range_start = 1
  local range_end = 1
  local length = input_str:len()
  local substrings = {}
  while range_end <= length do
    if char_at(input_str, range_end) == ' ' then
      local substring = input_str:sub(range_start, range_end - 1)
      table.insert(substrings, substring)
      range_start = range_end + 1
      range_end = range_start
    elseif range_end == length then
      local substring = input_str:sub(range_start, range_end)
      table.insert(substrings, substring)
      range_start = range_end + 1
      range_end = range_start
    else
      range_end = range_end + 1
    end
  end
  return substrings
end

return input
