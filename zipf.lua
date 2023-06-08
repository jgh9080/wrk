-- Define the list of web page URLs

-- Distribution parameter
s = 1.1

-- Function to generate a Zipf-like random number
function zipf(s, N)
    -- Calculate the sum of the series 1/n^s
    local B = 0.0
    for i = 1, N do
        B = B + 1/math.pow(i, s)
    end

    -- Generate a uniform random number
    local r = math.random()

    -- Find the index that corresponds to this random number
    local sum = 0.0
    for i = 1, N do
        sum = sum + 1/math.pow(i, s)
        if r <= sum/B then
            return i
        end
    end

    return N
end

-- Create a table to store items with priorities
local priorityTable = {}

-- Function to add an item with a priority to the table
local function addItem(item, priority)
  -- Create a new table entry with the item and its priority
  local entry = {item = item, priority = priority}
  
  -- Add the entry to the priorityTable
  table.insert(priorityTable, entry)
end

-- Function to shuffle the priorities of all items
local function shufflePriorities()
  -- Create a temporary table to hold the shuffled priorities
  local shuffledPriorities = {}
  math.randomseed(os.time())

  -- Copy the priorities to the temporary table
  for _, entry in ipairs(priorityTable) do
    table.insert(shuffledPriorities, entry.priority)
  end
  
  -- Shuffle the priorities using the Fisher-Yates algorithm
  local n = #shuffledPriorities
  for i = n, 2, -1 do
    local j = math.random(i)
    shuffledPriorities[i], shuffledPriorities[j] = shuffledPriorities[j], shuffledPriorities[i]
  end
  
  -- Assign the shuffled priorities back to the items
  for i, entry in ipairs(priorityTable) do
    entry.priority = shuffledPriorities[i]
  end
end

-- Function to get an item from the priorityTable based on priority
local function getItemByPriority(priority)
  for _, entry in ipairs(priorityTable) do
    if entry.priority == priority then
      return entry.item
    end
  end
  return nil -- Item not found for the given priority
end



-- Add some items to the table with different priorities
addItem("/page1.txt", 1)
addItem("/page2.txt", 2)
addItem("/page3.txt", 3)
addItem("/page4.txt", 4)
addItem("/page5.txt", 5)
addItem("/page6.txt", 6)
addItem("/page7.txt", 7)
addItem("/page8.txt", 8)
addItem("/page9.txt", 9)
addItem("/page10.txt", 10)
--[[
-- Output the initial priority order
for _, entry in ipairs(priorityTable) do
  print(entry.item .. ": " .. entry.priority)
end

shufflePriorities()

-- Output the updated priority order
print("Updated priority order:")
for _, entry in ipairs(priorityTable) do
  print(entry.item .. ": " .. entry.priority)
end
]]--

-- This function is called by wrk for each request
function request()
    -- Get the URL index for this request
    local url_index = zipf(s, #priorityTable)
    -- Get the URL for this request
    local url = getItemByPriority(url_index)

    -- Return the request that will be made
    return wrk.format(nil, url)
end
