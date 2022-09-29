local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

local kristly = {}
local kristlyWS = { ws = nil }

----------------------------------------------------------------------------------
--                                 UTILS                                        --
----------------------------------------------------------------------------------

--- A basic JSON Post function to the krist api.
-- Decodes the response from json into a table.
-- @param endpoint The json endpoint. The first part of the url should not be included.
-- @param body A stringified body
-- @return table
local function basicJSONPOST(endpoint, body)
  expect(1, endpoint, "string")

  return textutils.unserializeJSON(http.post("https://krist.dev/" .. endpoint, body).readAll())
end

--- A basic Get function to the krist api.
-- Decodes the response from json into a table.
-- @param endpoint The GET endpoint. Do not include the first part of the url.
-- @return table
local function basicGET(endpoint)
  expect(1, endpoint, "string")

  return textutils.unserializeJSON(http.get("https://krist.dev/" .. endpoint).readAll())
end

----------------------------------------------------------------------------------
--                                ADDRESSES                                     --
----------------------------------------------------------------------------------

--- Gets information about the supplied krist address.
-- @param address The krist address
-- @return address table, with address, balance, totalin, totalout, and firstseen.
function kristly.getAddress(address)
  expect(1, address, "string")

  return basicGET("addresses/" .. address)
end

--- Lists initized krist addresses.
-- @param limit The amount of addresses to return. Between 1-1000. Default: 50
-- @param offset The amount of offset the results. Useful for pagination.
-- @return table with count, total, and a addresses table, which contains the same data you would get from getAddress()
function kristly.listAddresses(limit, offset)
  expect(1, limit, "nil", "number")
  expect(2, offset, "nil", "number")

  limit = limit or 50
  offset = offset or 0

  return basicGET("addresses?limit=" .. limit .. "&offset=" .. offset)
end

--- Lists the richest krist addresses
-- @param limit The amount of addresses to return. Between 1-1000. Default: 50
-- @param offset The amount of offset the results. Useful for pagination.
-- @return table with count, total, and a addresses table, which contains the same data you would get from getAddress()
function kristly.listRichestAddresses(limit, offset)
  expect(1, limit, "nil", "number")
  expect(2, offset, "nil", "number")

  limit = limit or 50
  offset = offset or 0

  return basicGET("addresses/rich?limit=" .. limit .. "&offset=" .. offset)
end

--- Lists the recent transactions for a address
-- @param address the address to get transactions from
-- @param excludeMined if we should exclude mined blocks from the transactions
-- @param limit The limit of transactions to return
-- @param offset The amount to offset the results, useful for pagination
-- @return table with count, total, and a table array with transactions
function kristly.getRecentTransactions(address, excludeMined, limit, offset)
  expect(1, address, "string")
  expect(2, excludeMined, "nil", "boolean")
  expect(3, limit, "nil", "number")
  expect(4, offset, "nil", "number")

  excludeMined = excludeMined or true
  limit = limit or 50
  offset = offset or 0

  return basicGET("addresses/" ..
    address .. "/transactions?limit=" .. limit .. "&offset=" .. offset .. "&excludeMined=" .. excludeMined)
end

--- Lists the names owned by a address
-- @param address the address to get names from
-- @param limit The limit of names to return
-- @param offset The amount to offset the results, useful for pagination
function kristly.getNames(address, limit, offset)
  expect(1, address, "string")
  expect(2, limit, "nil", "number")
  expect(3, offset, "nil", "number")

  limit = limit or 50
  offset = offset or 0

  return basicGET("addresses/" .. address .. "/names")
end

----------------------------------------------------------------------------------
--                                 BLOCKS                                       --
----------------------------------------------------------------------------------

-- MINING IS DISABLED, BUT THIS PART WILL BE ADDED LATER

----------------------------------------------------------------------------------
--                                 LOOKUP API                                   --
----------------------------------------------------------------------------------

-- LOOKUP API IS IN BETA, MAY BE ADDED TO kristly IN THE FUTURE

----------------------------------------------------------------------------------
--                                  MISC                                        --
----------------------------------------------------------------------------------

--- Gets the current work
-- @return a table with if it is ok and work which contains the current work.
function kristly.getCurrentWork()
  return basicGET("work")
end

--- Gets the work over the past 24h
-- @return a table with if it is ok and a table of work
function kristly.getLast24hWork()
  return basicGET("work/day")
end

--- Gets detailed information about work/blocks
-- @return a table with lots of information
function kristly.getDetailedWorkInfo()
  return basicGET("work/detailed")
end

--- Authenticates a address with a private key
-- @param privatekey The privatekey of the address you want to authenticate
-- @return a table with ok and authed key/value pairs
function kristly.authenticate(privatekey)
  return basicJSONPOST("https://krist.dev/login", "privatekey=" .. privatekey)
end

--- Gets information about the krist server (MOTD)
-- @return table with lots of information. Specifications are over at krist.dev/docs
function kristly.getMOTD()
  return basicGET("motd")
end

--- Gets the latest krist wallet version
-- @return a table with ok and walletVersion key/value pairs
function kristly.getKristWalletVersion()
  return basicGET("walletversion")
end

--- Gets the latests changes/commits to the krist project
-- @return a table with ok, commits and whatsNew
function kristly.getKristChanges()
  return basicGET("whatsnew")
end

--- Gets the current supply of krist
-- @return a table with ok and money_supply
function kristly.getKristSupply()
  return basicGET("supply")
end

--- Converts a private key into a krist address
-- @return a table with ok and address porperty
function kristly.addressFromKey(privateKey)
  return basicJSONPOST("v2", "privatekey=" .. privateKey)
end

----------------------------------------------------------------------------------
--                                  NAMES                                       --
----------------------------------------------------------------------------------

--- Gets info about a krist name
-- @return a table with information
function kristly.getNameInfo(name)
  return basicGET("names/" .. name)
end

--- Lists currently registered krist names
-- @param limit number The limit of results
-- @param offset The amount to offset the results
-- @returns table with count, total, and a tablearray of names
function kristly.getKristNames(limit, offset)
  limit = limit or 50
  offset = offset or 0

  return basicGET("names?limit=" .. limit .. "&offset=" .. offset)
end

--- Lists currently registered krist names sorted by newest
-- @param limit number The limit of results
-- @param offset The amount to offset the results
-- @returns table with count, total, and a tablearray of names
function kristly.getNewestKristNames(limit, offset)
  limit = limit or 50
  offset = offset or 0

  return basicGET("names/new?limit=" .. limit .. "&offset=" .. offset)
end

---Gets the price of a krist name
-- @return a table with ok and name_cost properties
function kristly.getNamePrice()
  return basicGET("names/cost")
end

--- Gets the current name bonus. Simply: Amount of names bought in the latest 500 blocks
-- @return a table with ok and name_bonus
function kristly.getCurrentNameBonus()
  return basicGET("names/bonus")
end

--- Check if the supplied krist name is available
-- @param name The krist name
-- @return a table with ok and available properties
function kristly.isNameAvailable(name)
  return basicGET("names/check/" .. name)
end

--- Tries to register a krist name
-- @param name The krist name that should be registered
-- @param privatekey The krist privatekey. This should never be shared.
-- @return a table with a propery named ok. If ok is false it also contains a error property
function kristly.purchaseName(name, privatekey)
  return basicJSONPOST("names/" .. name, "privatekey=" .. privatekey)
end

--- Tries to transfer a name from one krist address to another krist address
-- @param name The krist name that should be transferred
-- @param fromPrivatekey The krist privatekey of the krist address the name will be transferred from
-- @param addressTo The krist address that the name should be transferred to
-- @return A table with ok propery and a name property if ok was true, or else a error property
function kristly.transferName(name, addressTo, fromPrivatekey)
  return basicJSONPOST("names/" .. name .. "/transfer?name=", "address=" .. addressTo .. "&privatekey=" .. fromPrivatekey)
end

--- Updates the data of a name, also knows as a A record
-- @param name The krist name that should get A record changed
-- @param privatekey The krist private key that ownes the krist name
-- @param newData The new data of the krist private key
-- @return a table with a ok property
function kristly.updateDataOfName(name, privatekey, newData)
  newData = newData or "Powered by Kristly"

  return basicJSONPOST("names/" .. name .. "/update", "privatekey=" .. privatekey .. "&newData=" .. newData)
end

----------------------------------------------------------------------------------
--                                TRANSACTIONS                                  --
----------------------------------------------------------------------------------

--- Gets a list of transactions. This is not the latest transctions!
-- @param excludeMined If we should exclude transactions coming from mining
-- @param limit The max amount of transactions to return.
-- @param offset The amount to offset the transaction list. Useful for pagination.
-- @return a table with the following fields: count, total, transactions(tablearray of transactions).
function kristly.listAllTransactions(excludeMined, limit, offset)
  excludeMined = excludeMined or true
  limit = limit or 50
  offset = offset or 0

  return basicGET("transactions?excludeMined=" .. excludeMined .. "&limit=" .. limit .. "&offset=" .. offset)
end

--- Gets a list of the latesttransactions.
-- @param excludeMined If we should exclude transactions coming from mining
-- @param limit The max amount of transactions to return.
-- @param offset The amount to offset the transaction list. Useful for pagination.
-- @return a table with the following fields: count, total, transactions(tablearray of transactions).
function kristly.listLatestTransactions(excludeMined, limit, offset)
  excludeMined = excludeMined or true
  limit = limit or 50
  offset = offset or 0

  return basicGET("transactions/latest?excludeMined=" .. excludeMined .. "&limit=" .. limit .. "&offset=" .. offset)
end

--- Gets data about a specific transaction.
-- @param transactionID the ID of the transaction.
-- @return A table with one property: transaction
function kristly.getTransaction(transactionID)
  return basicGET("transactions/" .. transactionID)
end

--- Transfer the specified amount from the specified privatekey's address
-- @param privatekey the krist privatekey of the address that the transaction should be from
-- @param to the krist address of the person recieveing the krist
-- @param amount the amount of krist to send
-- @param metadata option parameter that will contain metadata
function kristly.makeTransaction(privatekey, to, amount, metadata)
  metadata = metadata or "Powered by = Kristify"

  return basicJSONPOST("transactions",
    "privatekey=" .. privatekey .. "&to=" .. to .. "&amount=" .. amount .. "&metadata=" .. metadata)
end

----------------------------------------------------------------------------------
--                                WEBSOCKETS                                    --
----------------------------------------------------------------------------------

local eventQueue = {} -- Event queue 🤮

--- Generates a krist websocket url.
-- @param privatekey Optional: Privatekey of a wallet
-- @return A url to connect to with websocket
function kristly.generateWSUrl(privatekey)
  privatekey = privatekey or ""
  return basicJSONPOST("ws/start", privatekey)
end

--- Creates a new Kristly Websocket.
-- @param privatekey Optional: the private key of the connection.
-- @return a kristly ws object. Have fun with it!
function kristly.websocket(privatekey)
  local url = kristly.generateWSUrl(privatekey)
  local ws = http.websocket(url.url)
  local kws = kristlyWS:new { ws = ws }

  return kws
end

--- Creates a new Kristly websocket object.
-- @param o object with ws object inside.
-- @return a instance of Kristly WS
function kristlyWS:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Sends a simple websocket message to the krist server
-- @param type The action you would like to take
-- @param table Optional arguments
-- @return id The ID to listen after
function kristlyWS:simpleWSMessage(type, table)
  local id = os.clock() * os.getComputerID() * 2.5 + #shell.dir() -- Worlds best way to do it :troll: TODO:  make it more random possibly?
  
  table = table or {}
  table.id = id
  table.type = type

  self.ws.send(textutils.serialiseJSON(table))

  return id
end

function kristlyWS:simpleWSReceive(id)
  local response = textutils.unserialiseJSON self.ws.receive(10)
  
  if response.id ~= id then -- If the id we got wasent what we was looking for
    if response.type then -- If there is a type prop
      table.insert(eventQueue, response); -- Add to event queue
    end

    return self:simpleWSReceive(id) -- Listen to the ID we got back? @EmeraldImpulse7 huh pls fix, i confused.
  elseif response == nil then -- If there was no proper response
    return nil, "Websocket timed out or disconnected."
  else
    return response -- If everything as expected return the result.
  end
end

function kristlyWS:getWork()
  return self:simpleWSReceive self:simpleWSMessage "work"
end

function kristlyWS:makeTransaction(recipient, amount, metadata)
  metadata = metadata or "Powered by = Kristify"
  return self:simpleWSReceive self:simpleWSMessage("make_transaction", {
    to = recipient,
    amount = amount,
    metadata = metadata
  }) 
end

function kristlyWS:getValidSubscriptionLevels()
  return self:simpleWSReceive self:simpleWSMessage "get_valid_subscription_levels"
end

function kristlyWS:getAddress(address, fetchNames)
  fetchNames = fetchNames or false
  return self:simpleWSReceive self:simpleWSMessage("address", {
    address = address,
    fetchNames = fetchNames
  })
end

function kristlyWS:getSelfInfo()
  return self:simpleWSReceive self:simpleWSMessage "me"
end

function kristlyWS:getSubscriptionLevel()
  return self:simpleWSReceive self:simpleWSMessage "get_subscription_level"
end

function kristlyWS:downgradeConnection()
  return self:simpleWSReceive self:simpleWSMessage "logout"
end

function kristlyWS:upgradeConnection(privateKey)
  return self:simpleWSReceive self:simpleWSMessage("login", {
    privatekey = privateKey
  })
end

function kristlyWS:toggleEvent(event)
  return self:simpleWSReceive self:simpleWSMessage("subscribe", {
    event = event
  })
end

return kristly
