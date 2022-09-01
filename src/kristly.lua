local kristly = {}

----------------------------------------------------------------------------------
--                                 UTILS                                        --
----------------------------------------------------------------------------------

local function isOK(res, returnPath)
  if not res.ok then
    return {
      ok = false,
      error = res.error
    }
  end

  if returnPath then
    return res[returnPath]
  end

  return res
end

--- A basic JSON Post function to the krist api.
-- Decodes the response from json into a table.
-- @param endpoint The json endpoint. The first part of the url should not be included.
-- @param body A stringified body
-- @return table
local function basicJSONPOST(endpoint, body)
  return textutils.unserializeJSON(http.post("https://krist.dev/" .. endpoint, body).readAll())
end

--- A basic Get function to the krist api.
-- Decodes the response from json into a table.
-- @param endpoint The GET endpoint. Do not include the first part of the url.
-- @return table
local function basicGET(endpoint)
  return textutils.unserializeJSON(http.get("https://krist.dev/" .. endpoint).readAll())
end

----------------------------------------------------------------------------------
--                                ADDRESSES                                     --
----------------------------------------------------------------------------------

--- Gets information about the supplied krist address.
-- @param address The krist address
-- @return address table, with address, balance, totalin, totalout, and firstseen.
function kristly.getAddress(address)
  local res = basicGET("addresses/" .. address)
  return isOK(res, "address")
end

--- Lists initized krist addresses.
-- @param limit The amount of addresses to return. Between 1-1000. Default: 50
-- @param offset The amount of offset the results. Useful for pagination.
-- @return table with count, total, and a addresses table, which contains the same data you would get from getAddress()
function kristly.listAddresses(limit, offset)
  limit = limit or 50
  offset = offset or 0

  local res = basicGET("addresses?limit=" .. limit .. "&offset=" .. offset)
  return isOK(res)
end

--- Lists the richest krist addresses
-- @param limit The amount of addresses to return. Between 1-1000. Default: 50
-- @param offset The amount of offset the results. Useful for pagination.
-- @return table with count, total, and a addresses table, which contains the same data you would get from getAddress()
function kristly.listRichestAddresses(limit, offset)
  limit = limit or 50
  offset = offset or 0

  local res = basicGET("addresses/rich?limit=" .. limit .. "&offset=" .. offset)
  return isOK(res)
end

--- Lists the recent transactions for a address
-- @param address the address to get transactions from
-- @param excludeMined if we should exclude mined blocks from the transactions
-- @param limit The limit of transactions to return
-- @param offset The amount to offset the results, useful for pagination
-- @return table with count, total, and a table array with transactions
function kristly.getRecentTransactions(address, excludeMined, limit, offset)
  excludeMined = excludeMined or true
  limit = limit or 50
  offset = offset or 0

  local res = basicGET("addresses/" ..
    address .. "/transactions?limit=" .. limit .. "&offset=" .. offset .. "&excludeMined=" .. excludeMined)
  return res
end

--- Lists the names owned by a address
-- @param address the address to get names from
-- @param limit The limit of names to return
-- @param offset The amount to offset the results, useful for pagination
function kristly.getNames(address, limit, offset)
  limit = limit or 50
  offset = offset or 0

  return basicGET("addresses/" .. address .. "/names")
end

function kristly.addressFromKey(privateKey)
  local res = basicJSONPOST("v2", "privatekey=" .. privateKey)

  return res
end

----------------------------------------------------------------------------------
--                                 BLOCKS                                      --
----------------------------------------------------------------------------------

-- MINING IS DISABLED, BUT THIS PART WILL BE ADDED LATER

return kristly
