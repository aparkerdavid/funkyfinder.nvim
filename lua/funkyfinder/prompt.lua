local prompt = {}
local function char_at(str, n)
  return str:sub(n, n)
end

function prompt.parse(prompt_str)
  local range_start = 1
  local range_end = 1
  local length = prompt_str:len()
  local substrings = {}
  local function take_substring(sub_start, sub_end)
    local substring = prompt_str:sub(sub_start, sub_end)
    if substring ~= '' then
      table.insert(substrings, substring)
    end
    range_start = range_end + 1
    range_end = range_start
  end

  while range_end <= length do
    if char_at(prompt_str, range_end) == ' ' then
      take_substring(range_start, range_end - 1)
    elseif range_end == length then
      take_substring(range_start, range_end)
    elseif char_at(prompt_str, range_end) == '\\' then
      range_end = range_end + 2
    else
      range_end = range_end + 1
    end
  end

  return substrings
end

function prompt.build_queries(prompt_str)
  local prompt_terms = prompt.parse(prompt_str)
  local queries = {}

  for _, term in pairs(prompt_terms) do
    table.insert(queries, vim.regex(term))
  end

  return queries
end

function prompt.match(queries, candidate)
  local match = {}

  for _, regex in pairs(queries) do
    local match_start, match_end = regex:match_str(candidate)
    if match_start and match_end then
      table.insert(match, { match_start, match_end })
    else
      return false
    end
  end

  return match
end

return prompt
