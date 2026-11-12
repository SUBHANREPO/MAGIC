-- ============================================================================
-- SUBHAN VIP — ONLINE LOGIN + MAGIC BULLET + AUTO-HEAD + ULTIMATE BYPASS
-- Owner: @DR_SUBHAN
-- ============================================================================

-- ============================================================
-- 1) LICENSE CONFIG
-- ============================================================
local YtMursleenLicenseConfig = {
    url = 'https://api.6nnn.store/connect', game = 'PUBG',
    timeout = 10, clockSkew = 120, expiryPath = {'data', 'expired_date'},
    manualExpiry = nil, tamperTolerance = 5,
    secret = 'Vm8Lk7Uj2JmsjCPVPVjrLa7zgfx3uz9E',
}

-- ============================================================
-- 2) LICENSE CORE (MD5 + session cache + auth state machine)
-- ============================================================
local YtMursleenLicenseCore = (function()
    local Primitives = (function()
        local floor, abs, max = math.floor, math.abs, math.max
        local byte, char, format = string.byte, string.char, string.format
        local U32 = 4294967296
        local AND, XOR = {}, {}
        for a = 0, 15 do for b = 0, 15 do
            local av, bv, both, different, place = a, b, 0, 0, 1
            for _ = 1, 4 do
                local x, y = av % 2, bv % 2
                if x == 1 and y == 1 then both = both + place end
                if x ~= y then different = different + place end
                av, bv, place = floor(av / 2), floor(bv / 2), place * 2
            end
            AND[a * 16 + b], XOR[a * 16 + b] = both, different
        end end
        local function bitop(a, b, lookup)
            local value, place = 0, 1
            for _ = 1, 8 do
                value = value + lookup[(a % 16) * 16 + b % 16] * place
                a, b, place = floor(a / 16), floor(b / 16), place * 16
            end
            return value
        end
        local band = function(a, b) return bitop(a, b, AND) end
        local bxor = function(a, b) return bitop(a, b, XOR) end
        local function rol(value, amount)
            local divisor = 2 ^ (32 - amount)
            return (value % divisor) * 2 ^ amount + floor(value / divisor)
        end
        local function little32(value)
            return char(value % 256, floor(value / 256) % 256,
                floor(value / 65536) % 256, floor(value / 16777216) % 256)
        end
        local K = {
            0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,0xf57c0faf,0x4787c62a,0xa8304613,0xfd469501,
            0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,0x6b901122,0xfd987193,0xa679438e,0x49b40821,
            0xf61e2562,0xc040b340,0x265e5a51,0xe9b6c7aa,0xd62f105d,0x02441453,0xd8a1e681,0xe7d3fbc8,
            0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,0xa9e3e905,0xfcefa3f8,0x676f02d9,0x8d2a4c8a,
            0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,
            0x289b7ec6,0xeaa127fa,0xd4ef3085,0x04881d05,0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,
            0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,0x655b59c3,0x8f0ccc92,0xffeff47d,0x85845dd1,
            0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391
        }
        local SHIFT = {7,12,17,22,5,9,14,20,4,11,16,23,6,10,15,21}
        local function md5_raw(input)
            assert(type(input) == "string", "MD5 input must be a string")
            local size = #input
            local message = input .. char(128) .. string.rep(char(0), (55 - size) % 64)
                .. little32((size * 8) % U32) .. little32(floor(size / 536870912))
            local h0, h1, h2, h3 = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
            local words = {}
            for offset = 1, #message, 64 do
                for j = 0, 15 do
                    local a, b, c, d = byte(message, offset + j * 4, offset + j * 4 + 3)
                    words[j] = a + b * 256 + c * 65536 + d * 16777216
                end
                local a, b, c, d = h0, h1, h2, h3
                for i = 0, 63 do
                    local f, g, shiftBase
                    if i < 16 then
                        f, g, shiftBase = band(b, c) + band(U32 - 1 - b, d), i, 0
                    elseif i < 32 then
                        f, g, shiftBase = band(d, b) + band(U32 - 1 - d, c), (5 * i + 1) % 16, 4
                    elseif i < 48 then
                        f, g, shiftBase = bxor(bxor(b, c), d), (3 * i + 5) % 16, 8
                    else
                        local bOrNotD = U32 - 1 - band(U32 - 1 - b, d)
                        f, g, shiftBase = bxor(c, bOrNotD), (7 * i) % 16, 12
                    end
                    local nextB = (b + rol((a + f + K[i + 1] + words[g]) % U32,
                        SHIFT[shiftBase + i % 4 + 1])) % U32
                    a, b, c, d = d, nextB, b, c
                end
                h0, h1, h2, h3 = (h0 + a) % U32, (h1 + b) % U32, (h2 + c) % U32, (h3 + d) % U32
            end
            return little32(h0) .. little32(h1) .. little32(h2) .. little32(h3)
        end
        local function hex(input)
            return (input:gsub(".", function(c) return format("%02x", byte(c)) end))
        end
        local md5 = function(input) return hex(md5_raw(input)) end
        local form_encode = function(input)
            assert(type(input) == "string", "Form value must be a string")
            return (input:gsub("[^A-Za-z0-9%-%._~ ]", function(c)
                return format("%%%02X", byte(c)) end):gsub(" ", "+"))
        end
        local function constant_time_equal(a, b)
            if type(a) ~= "string" or type(b) ~= "string" then return false end
            local difference = abs(#a - #b)
            for i = 1, max(#a, #b) do
                difference = difference + abs((byte(a, i) or 0) - (byte(b, i) or 0))
            end
            return difference == 0
        end
        local function name_uuid(input)
            local digest = md5_raw(input)
            local h = hex(digest:sub(1,6) .. char(byte(digest,7) % 16 + 48)
                .. digest:sub(8,8) .. char(byte(digest,9) % 64 + 128) .. digest:sub(10))
            return h:sub(1,8) .. "-" .. h:sub(9,12) .. "-" .. h:sub(13,16)
                .. "-" .. h:sub(17,20) .. "-" .. h:sub(21,32)
        end
        return {md5 = md5, md5_raw = md5_raw, form_encode = form_encode,
                constant_time_equal = constant_time_equal, name_uuid = name_uuid}
    end)()

    local SESSION_KEY = '__YtMursleenLicenseSession_v2'
    local CACHE_NAME = '.license_cache'
    local CACHE_PATHS = {
        '//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME,
        '//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME,
        'Documents/ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        'Documents/ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME,
        '/Documents/ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        '/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME,
        'ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        'ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME,
        '../../ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME,
        '../../ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME
    }
    pcall(function()
        if os and os.getenv then
            local home = os.getenv('HOME')
            if home and home ~= '' then
                table.insert(CACHE_PATHS, 1, home .. '/Documents/ShadowTrackerExtra/Saved/SaveGames/' .. CACHE_NAME)
                table.insert(CACHE_PATHS, 2, home .. '/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/' .. CACHE_NAME)
            end
        end
    end)

    local B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local function b64encode(data)
        local out = {}
        for i = 1, #data, 3 do
            local a, b, c = data:byte(i, i + 2)
            b, c = b or 0, c or 0
            local n = a * 65536 + b * 256 + c
            local x1 = math.floor(n / 262144) % 64 + 1
            local x2 = math.floor(n / 4096) % 64 + 1
            local x3 = math.floor(n / 64) % 64 + 1
            local x4 = n % 64 + 1
            out[#out + 1] = B64:sub(x1,x1) .. B64:sub(x2,x2)
                .. (i + 1 <= #data and B64:sub(x3,x3) or '=')
                .. (i + 2 <= #data and B64:sub(x4,x4) or '=')
        end
        return table.concat(out)
    end
    local function b64decode(data)
        if type(data) ~= 'string' or #data % 4 ~= 0 or data:find('[^' .. B64 .. '=]') then return nil end
        local out = {}
        for i = 1, #data, 4 do
            local a = B64:find(data:sub(i,i), 1, true)
            local b = B64:find(data:sub(i+1,i+1), 1, true)
            local cchar, dchar = data:sub(i+2,i+2), data:sub(i+3,i+3)
            local c = cchar == '=' and 0 or B64:find(cchar, 1, true)
            local d = dchar == '=' and 0 or B64:find(dchar, 1, true)
            if not a or not b or not c or not d then return nil end
            local n = (a-1)*262144 + (b-1)*4096 + (c-1)*64 + (d-1)
            out[#out+1] = string.char(math.floor(n/65536)%256)
            if cchar ~= '=' then out[#out+1] = string.char(math.floor(n/256)%256) end
            if dchar ~= '=' then out[#out+1] = string.char(n%256) end
        end
        return table.concat(out)
    end
    local function readDiskSession()
        for _, path in ipairs(CACHE_PATHS) do
            local f = io and io.open and io.open(path, 'r')
            if f then
                local encoded = f:read('*a'); f:close()
                local raw = b64decode(encoded)
                if raw then
                    local key, entry, expiry = raw:match('^([^\n]*)\n(%d+)\n(%d+)$')
                    entry, expiry = tonumber(entry), tonumber(expiry)
                    if key and #key > 0 and entry and expiry and expiry > entry then
                        return {authorized = true, key = key, issuedAt = entry, expiresAt = expiry}
                    end
                end
            end
        end
    end
    local function writeDiskSession(session)
        if not session or type(session.key) ~= 'string' or not session.expiresAt then return false end
        local raw = session.key .. '\n' .. tostring(session.issuedAt or os.time()) .. '\n' .. tostring(session.expiresAt)
        local encoded = b64encode(raw)
        for _, path in ipairs(CACHE_PATHS) do
            local f = io and io.open and io.open(path, 'w')
            if f then
                local ok = pcall(function() f:write(encoded); f:flush() end)
                f:close()
                if ok then return true end
            end
        end
        return false
    end
    local function loadSession()
        local g = rawget(_G, SESSION_KEY)
        if type(g) ~= 'table' or g.authorized ~= true then g = readDiskSession() end
        if type(g) ~= 'table' or g.authorized ~= true then return nil end
        if type(g.expiresAt) ~= 'number' or g.expiresAt <= os.time() then
            _G[SESSION_KEY] = nil; return nil
        end
        _G[SESSION_KEY] = g
        return g
    end
    local function saveSession(key, expiresAt)
        local session = {authorized = true, key = key, expiresAt = expiresAt, issuedAt = os.time()}
        pcall(function() _G[SESSION_KEY] = session end)
        pcall(writeDiskSession, session)
    end
    local function clearSession()
        pcall(function() _G[SESSION_KEY] = nil end)
        for _, path in ipairs(CACHE_PATHS) do
            pcall(function() local f = io and io.open and io.open(path, 'w'); if f then f:write(''); f:close() end end)
        end
    end

    local CreateLocalExpiry = function(cfg)
        local E = {}
        local expiredText = 'Mod expired. DM @DR_SUBHAN for renewal.'
        local tamperText  = "Don't be over smart"
        local blockedMessage, blockedPhase
        local function finite(n)
            return type(n) == 'number' and n == n and n ~= math.huge and n ~= -math.huge
        end
        local function block(message, phase)
            if not blockedMessage then blockedMessage, blockedPhase = message, phase end
            return false, blockedMessage, blockedPhase
        end
        function E.Status() return not blockedMessage, blockedMessage, blockedPhase end
        function E.MarkTampered() return block(tamperText, 'tampered') end
        function E.GetExpiry() return nil end
        function E.Accept(server, now, world, phone, rtt)
            if blockedMessage then return E.Status() end
            if not finite(server) or not finite(now) or now < 0 or world == nil
                or not finite(rtt) or rtt < 0 or not finite(phone) then
                return block('Clock verification unavailable.', 'error')
            end
            if math.abs(phone - server) > (cfg.clockSkew or 120) + rtt then return E.MarkTampered() end
            return true
        end
        return E
    end

    local CreateAuth = function(P, cfg, deps)
        local A = {}
        local phase, message = 'locked', 'Enter your key to sign in.'
        local allowed, pending, generation = false, nil, 0
        local expiresAt
        local lastRequestLatencyMs, lastResponseTime, lastResponseWorld
        local startFn, stopFn, payloadStarted, restartRequired
        local localExpiry = deps.localExpiry
        do
            local stored = loadSession()
            if stored then
                allowed = true; expiresAt = stored.expiresAt
                phase, message = 'active', 'Session restored'
            end
        end
        if localExpiry then
            local ok, text, state = localExpiry.Status()
            if not ok then message, phase = text, state end
        end
        local function finite(n)
            return type(n) == 'number' and n == n and n ~= math.huge and n ~= -math.huge
        end
        local function readClock()
            local ok, n, w = pcall(deps.clock)
            if ok and finite(n) and n >= 0 and w ~= nil then return n, w end
        end
        local function notify(text, state)
            message, phase = text, state
            if type(deps.status) == 'function' then pcall(deps.status, text, state) end
        end
        local function stopPayload()
            if payloadStarted then
                payloadStarted = false
                local ok, accepted = pcall(stopFn)
                if not ok or accepted == false then restartRequired = true end
            end
        end
        local function revoke(text, state)
            generation = generation + 1
            allowed, pending, expiresAt = false, nil, nil
            lastRequestLatencyMs, lastResponseTime, lastResponseWorld = nil, nil, nil
            stopPayload()
            local localDenied = false
            if localExpiry then
                local ok, localText, localPhase = localExpiry.Status()
                if not ok then text, state, localDenied = localText, localPhase, true end
            end
            notify(restartRequired and not localDenied
                and 'Restart required: payload cleanup failed.' or text, state or 'error')
        end
        local function startPayload()
            if payloadStarted or not startFn then return true end
            payloadStarted = true
            local before = generation
            local ok, accepted = pcall(startFn)
            if not ok or accepted == false then
                restartRequired = true
                revoke('Restart required: offline script startup failed.', 'error')
                return false
            end
            return generation == before and allowed
        end
        local function denyReason(reason)
            if type(reason) ~= 'string' then return 'Expired' end
            local lower = reason:sub(1, 120):lower():gsub('[_%s%-]+', ' ')
            if lower == 'max devices' or lower == 'maximum devices'
                or lower == 'max devices reached' then
                return 'Max Devices'
            end
            local clean = reason
            for _, field in ipairs({'key', 'serial'}) do
                if pending and type(pending[field]) == 'string' and #pending[field] > 0 then
                    local needle = pending[field]:gsub('([^%w])', '%%%1')
                    clean = clean:gsub(needle, '[' .. field .. ']')
                end
            end
            if type(cfg.secret) == 'string' and #cfg.secret > 0 then
                clean = clean:gsub(cfg.secret:gsub('([^%w])', '%%%1'), '[credential]')
            end
            clean = clean:gsub('[%c]', ' '):sub(1, 120)
            return clean == '' and 'Expired' or ('Expired: ' .. clean)
        end
        local function configuredExpiry(result)
            if cfg.expiryPath == nil then return nil, true end
            if type(cfg.expiryPath) ~= 'table' or #cfg.expiryPath == 0 then return nil, false end
            local v = result
            for _, name in ipairs(cfg.expiryPath) do
                if type(v) ~= 'table' then return nil, false end
                v = rawget(v, name)
            end
            if finite(v) and v > 0 and v % 1 == 0 then return v, true end
            if type(v) == 'string' then
                local y, mo, d, h, mi, se = v:match('^(%d%d%d%d)%-(%d%d)%-(%d%d) (%d%d):(%d%d):(%d%d)$')
                if y then
                    local stamp = os.time({year=tonumber(y), month=tonumber(mo), day=tonumber(d),
                        hour=tonumber(h), min=tonumber(mi), sec=tonumber(se)})
                    if finite(stamp) and stamp > 0 then return stamp, true end
                end
            end
            return nil, false
        end
        local function begin(key)
            if restartRequired or pending then return false end
            if localExpiry then
                local ok, text, state = localExpiry.Status()
                if not ok then revoke(text, state); return false end
            end
            if type(key) ~= 'string' then key = '' end
            key = key:match('^%s*(.-)%s*$')
            if #key == 0 or #key > 512 then
                revoke('Expired: enter a valid key.', 'denied'); return false
            end
            local now, world = readClock()
            if not now then
                revoke('Game clock unavailable. Try again in a match.', 'error'); return false
            end
            local okSerial, serial = pcall(deps.serial, key)
            if not okSerial or type(serial) ~= 'string' or #serial == 0 or #serial > 512 then
                revoke('Device identifier unavailable.', 'error'); return false
            end
            generation = generation + 1
            local requestId = generation
            pending = {id = requestId, key = key, serial = serial,
                       started = now, world = world, deadline = now + cfg.timeout}
            notify('Signing in...', 'pending')
            if not pending or pending.id ~= requestId or generation ~= requestId then return false end
            local body = 'game=' .. P.form_encode(cfg.game)
                .. '&user_key=' .. P.form_encode(key)
                .. '&serial=' .. P.form_encode(serial)
            local function received(success, raw)
                if not pending or pending.id ~= requestId or generation ~= requestId then return end
                local current, worldNow = readClock()
                if not current or worldNow ~= pending.world or current < pending.started
                    or current >= pending.deadline then
                    revoke('Request expired. Please sign in again.', 'error'); return
                end
                if success ~= true or type(raw) ~= 'string' or #raw == 0 or #raw > 32768 then
                    revoke('Connection failed. Please try again.', 'error'); return
                end
                local ok, result = pcall(deps.decode, raw)
                if not ok or type(result) ~= 'table' then
                    revoke('Invalid server response.', 'error'); return
                end
                if result.status ~= true then revoke(denyReason(result.reason), 'denied'); return end
                local data = result.data
                if type(data) ~= 'table' or type(data.token) ~= 'string' or #data.token ~= 32
                    or not data.token:match('^[%x]+$') or not finite(data.rng) or data.rng % 1 ~= 0 then
                    revoke('Incomplete server response.', 'error'); return
                end
                local expected = P.md5(cfg.game .. '-' .. key .. '-' .. serial .. '-' .. cfg.secret)
                if not P.constant_time_equal(data.token:lower(), expected) then
                    revoke('Server token verification failed.', 'denied'); return
                end
                local okWall, wall = pcall(deps.wall)
                if not okWall or not finite(wall) then
                    revoke('Phone clock unavailable.', 'error'); return
                end
                if localExpiry then
                    local accepted, text, state = localExpiry.Accept(
                        data.rng, current, worldNow, wall, current - pending.started)
                    if not accepted then revoke(text, state); return end
                elseif math.abs(wall - data.rng) > cfg.clockSkew then
                    revoke('Phone/server clock mismatch. Check automatic time.', 'error'); return
                end
                local expiry, validExpiry = configuredExpiry(result)
                if not validExpiry then
                    revoke('Configured server expiry field is missing or invalid.', 'error'); return
                end
                if expiry and expiry - data.rng - (current - pending.started) <= 0 then
                    revoke('Expired', 'denied'); return
                end
                local fixedExpiry = localExpiry and localExpiry.GetExpiry()
                if fixedExpiry then expiry = math.min(expiry or fixedExpiry, fixedExpiry) end
                lastRequestLatencyMs = (current - pending.started) * 1000
                lastResponseTime, lastResponseWorld = current, worldNow
                pending = nil
                allowed, expiresAt = true, expiry
                saveSession(key, expiresAt)
                if not startPayload() then return end
                notify('Login successful.', 'active')
            end
            local ok, accepted = pcall(deps.post, cfg.url,
                {['Content-Type'] = 'application/x-www-form-urlencoded'},
                body, received, cfg.timeout)
            if not ok or accepted == false then
                revoke('HTTP request could not start.', 'error'); return false
            end
            return true
        end
        function A.Login(key) if allowed then return false end; return begin(key) end
        function A.Tick()
            if not pending then return end
            local now, world = readClock()
            if not now or world ~= pending.world or now < pending.started then
                revoke('Login interrupted by map loading. Please try again when ready.', 'locked'); return
            end
            if now >= pending.deadline then
                revoke('Request timed out. Please try again.', 'error')
            end
        end
        function A.IsAuthorized()
            if allowed and not restartRequired then return true end
            local stored = loadSession()
            if stored and not restartRequired then
                allowed = true; expiresAt = stored.expiresAt; return true
            end
            return false
        end
        function A.Logout() clearSession(); revoke('Expired: signed out.', 'locked') end
        function A.FailClosed(text, requiresRestart)
            if requiresRestart == true then restartRequired = true end
            revoke(text or 'Online access unavailable.', 'error')
        end
        function A.ReportClockTampering()
            if localExpiry then localExpiry.MarkTampered() end
            revoke("Don't be over smart", 'tampered')
        end
        function A.Bind(onStart, onStop)
            if type(onStart) ~= 'function' or type(onStop) ~= 'function' then
                return false, 'START_AND_STOP_REQUIRED'
            end
            if startFn and (startFn ~= onStart or stopFn ~= onStop) then
                return false, 'ALREADY_BOUND'
            end
            startFn, stopFn = onStart, onStop
            if A.IsAuthorized() then return startPayload() end
            return true
        end
        function A.Unbind()
            revoke('Offline script disconnected.', 'locked')
            startFn, stopFn = nil, nil
        end
        function A.GetRemainingSeconds() return nil end
        function A.GetState()
            local authorized = A.IsAuthorized()
            local sample, age
            if authorized and lastRequestLatencyMs ~= nil then
                local now, world = readClock()
                if now and world == lastResponseWorld and now >= lastResponseTime then
                    sample, age = lastRequestLatencyMs, now - lastResponseTime
                end
            end
            return {
                phase = phase, message = message, authorized = authorized,
                sessionAuthorized = authorized, expiresAt = expiresAt,
                accessPolicy = "game_session", expiryCheckPolicy = "login_only",
                periodicRecheck = false, pending = pending ~= nil,
                linked = startFn ~= nil, restartRequired = restartRequired == true,
                lastRequestLatencyMs = sample, lastRequestLatencyAgeSeconds = age,
                latencyScope = "license_http_round_trip"
            }
        end
        return A
    end

    local Core = {Primitives = Primitives, createExpiry = CreateLocalExpiry}
    function Core.new(config, dependencies)
        assert(type(config) == 'table' and type(dependencies) == 'table',
            'License configuration and dependencies required')
        local deps = {}
        for key, value in pairs(dependencies) do deps[key] = value end
        if deps.localExpiry == nil then deps.localExpiry = CreateLocalExpiry(config) end
        return CreateAuth(Primitives, config, deps)
    end
    return Core
end)()

-- ============================================================
-- 3) POPUP #1: LOGIN PANEL
-- ============================================================
local YtMursleenLoginUI = (function()
    local Module = {}
    function Module.new(env)
        env = env or _G
        local require = env.require or require
        local function global(name)
            local ok, value = pcall(function() return env[name] end)
            if ok then return value end
        end
        local UI = {_status = "Enter your key", _busy = false, _data = nil}
        local function member(object, name)
            if object == nil then return nil end
            local ok, value = pcall(function() return object[name] end)
            if ok then return value end
        end
        local function valid(object)
            local check = member(global("slua"), "isValid")
            if object == nil then return false end
            if type(check) == 'function' then
                local ok, result = pcall(check, object)
                if ok and result == true then return true end
            end
            local game = global('Game')
            local fallback = member(game, 'IsValid')
            if type(fallback) == 'function' then
                local ok, result = pcall(fallback, game, object)
                return ok and result == true
            end
            return false
        end
        local function imported(name)
            local loader = global("import")
            if type(loader) ~= "function" then return nil end
            local ok, result = pcall(loader, name)
            if ok then return result end
        end
        local function construct(class, ...)
            if class == nil then return nil end
            local ok, result = pcall(class, ...)
            if ok then return result end
        end
        local function vector(x, y)
            return construct(global("FVector2D") or imported("Vector2D"), x, y)
                or {X = x, Y = y}
        end
        local function color(r, g, b, a)
            return construct(global("FLinearColor") or imported("LinearColor"), r, g, b, a)
                or {R = r, G = g, B = b, A = a}
        end
        local function visibility(widget, value)
            local setter = member(widget, "SetWidgetVisibility") or member(widget, "SetVisibility")
            assert(type(setter) == "function", "UI_VISIBILITY_UNAVAILABLE")
            setter(widget, value)
        end
        local function setTextStyle(widget, size, textColor)
            pcall(function()
                local font = widget.Font
                if font then
                    font.Size = math.max(1, math.floor(size * (UI._scale or 1) + 0.5))
                    local assigned = pcall(function() widget.Font = font end)
                    if not assigned then widget:SetFont(font) end
                end
            end)
            pcall(function() widget:SetAutoWrapText(true) end)
            pcall(function()
                local slate = construct(imported("SlateColor"), textColor)
                if slate then widget:SetColorAndOpacity(slate) end
            end)
        end
        local function detach(data)
            if not data then return end
            data.visible = false
            pcall(function() if valid(data.input) then data.input:SetText("") end end)
            if data.event and data.eventHandle ~= nil then
                pcall(function() data.event:Remove(data.eventHandle) end)
            end
            if valid(data.container) then
                pcall(function() data.container:RemoveFromParent() end)
            end
            data.onSubmit = nil
        end
        function UI.Destroy() local previous = UI._data; UI._data = nil; detach(previous) end
        function UI.Hide()
            local data = UI._data
            if not data or data.hiddenApplied then return true end
            data.visible = false
            local ok = pcall(function()
                if valid(data.input) then data.input:SetText("") end
                if valid(data.container) then visibility(data.container, data.hidden) end
            end)
            if ok then data.hiddenApplied = true end
            return ok
        end
        function UI.SetStatus(message)
            UI._status = type(message) == "string" and message:sub(1, 160) or "Login unavailable"
            local data = UI._data
            if data and data.deliveredStatus == UI._status then return true end
            if data and valid(data.status) then
                local ok = pcall(function() data.status:SetText(UI._status) end)
                if ok then data.deliveredStatus = UI._status end
                return ok
            end
            return false
        end
        function UI.SetBusy(busy)
            UI._busy = busy == true
            local data = UI._data
            if data then
                if data.deliveredBusy == UI._busy then return true end
                local buttonOK = pcall(function() data.button:SetIsEnabled(not UI._busy) end)
                local inputOK  = pcall(function() data.input:SetIsEnabled(not UI._busy) end)
                if buttonOK and inputOK then data.deliveredBusy = UI._busy; return true end
            end
            return false
        end
        local function fitScale(parent)
            local result = 1
            pcall(function()
                local size = parent:GetCachedGeometry():GetLocalSize()
                local width, height = size.X, size.Y
                if type(width) == 'number' and type(height) == 'number'
                    and width > 24 and height > 24 then
                    result = math.min(1, (width - 24) / 500, (height - 24) / 248)
                end
            end)
            return result
        end
        function UI.Show(onSubmit)
            if type(onSubmit) ~= "function" then return false, "UI_SUBMIT_REQUIRED" end
            local data = UI._data
            if data and valid(data.parent)
                and math.abs(fitScale(data.parent) - (data.scale or 1)) > 0.001 then
                UI.Destroy(); data = nil
            end
            if data and valid(data.container) and valid(data.parent) then
                local ok = data.visible or pcall(function()
                    visibility(data.container, data.visibleEnum)
                end)
                if ok then
                    data.onSubmit, data.visible, data.hiddenApplied = onSubmit, true, false
                    UI.SetStatus(UI._status); UI.SetBusy(UI._busy); return true
                end
            end
            UI.Destroy()
            local okTools, uiTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameUITools")
            local getRoot = okTools and member(uiTools, "GetMainControlBaseUI")
            if type(getRoot) ~= "function" then return false, "UI_NOT_READY" end
            local okRoot, root = pcall(getRoot)
            if not okRoot or not valid(root) then return false, "UI_NOT_READY" end
            local parent = member(root, "CanvasPanel_0")
            if not valid(parent) then parent = member(root, "CanvasPanel_42") end
            if not valid(parent) then return false, "UI_NOT_READY" end
            local game = global("CGame")
            if type(member(game, "NewObjectFromPath")) ~= "function" then
                return false, "UI_FACTORY_UNAVAILABLE"
            end
            local enums = member(global("UEnums"), "ESlateVisibility")
            local visibleEnum, hidden = member(enums, "Visible"), member(enums, "Collapsed")
            local passive = member(enums, "SelfHitTestInvisible")
            if visibleEnum == nil or hidden == nil or passive == nil then
                return false, "UI_ENUM_UNAVAILABLE"
            end
            UI._scale = fitScale(parent)
            data = {parent = parent, visible = false, onSubmit = onSubmit,
                    visibleEnum = visibleEnum, hidden = hidden, scale = UI._scale}
            local okBuild = pcall(function()
                local function make(class, outer)
                    local widget = game:NewObjectFromPath("/Script/UMG." .. class, outer)
                    assert(valid(widget), "UI_WIDGET_UNAVAILABLE")
                    return widget
                end
                data.container = make("CanvasPanel", parent)
                local function add(widget, x, y, width, height, z)
                    local slot = data.container:AddChildToCanvas(widget)
                    slot:SetAutoSize(false)
                    slot:SetPosition(vector(x * UI._scale, y * UI._scale))
                    slot:SetSize(vector(width * UI._scale, height * UI._scale))
                    slot:SetZOrder(z)
                    return slot
                end
                local background = make("Border", data.container)
                background:SetBrushColor(color(0.025, 0.035, 0.05, 0.98))
                visibility(background, visibleEnum)
                add(background, 0, 0, 500, 248, 0)
                local title = make("TextBlock", data.container)
                title:SetText("OWNER @DR_SUBHAN  Online Login")
                setTextStyle(title, 19, color(0.1, 0.9, 1, 1))
                visibility(title, passive); add(title, 22, 15, 456, 30, 1)
                data.input = make("EditableTextBox", data.container)
                data.input:SetText("")
                setTextStyle(data.input, 17, color(0.92, 0.94, 0.96, 1))
                pcall(function() data.input:SetHintText("Enter your key") end)
                visibility(data.input, visibleEnum); add(data.input, 22, 58, 456, 44, 2)
                local hint = make("TextBlock", data.container)
                hint:SetText("Enter your key, then tap LOGIN.")
                setTextStyle(hint, 12, color(0.72, 0.78, 0.83, 1))
                visibility(hint, passive); add(hint, 22, 106, 456, 20, 2)
                data.status = make("TextBlock", data.container)
                data.status:SetText(UI._status); data.deliveredStatus = UI._status
                setTextStyle(data.status, 13, color(0.92, 0.94, 0.96, 1))
                visibility(data.status, passive)
                pcall(function() data.status:SetAutoWrapText(true) end)
                add(data.status, 22, 129, 456, 54, 2)
                data.button = make("Button", data.container)
                visibility(data.button, visibleEnum)
                local label = make("TextBlock", data.button)
                label:SetText("LOGIN")
                setTextStyle(label, 17, color(0.05, 0.08, 0.12, 1))
                visibility(label, passive); data.button:AddChild(label)
                add(data.button, 150, 190, 200, 40, 2)
                data.event = data.button.OnClicked
                data.eventHandle = data.event:Add(function()
                    if UI._data ~= data or not data.visible or UI._busy then return end
                    local readOK, key = pcall(function() return data.input:GetText() end)
                    if not readOK or type(key) ~= "string" then
                        UI.SetStatus("Unable to read the key"); return
                    end
                    key = key:match("^%s*(.-)%s*$")
                    if key == "" or #key > 512 then UI.SetStatus("Enter a valid key"); return end
                    local submitOK = pcall(data.onSubmit, key)
                    if not submitOK then UI.SetBusy(false); UI.SetStatus("Login could not start") end
                end)
                local slot = parent:AddChildToCanvas(data.container)
                slot:SetAutoSize(false)
                slot:SetSize(vector(500 * UI._scale, 248 * UI._scale))
                slot:SetZOrder(9000)
                local anchors = slot:GetAnchors()
                anchors.Minimum, anchors.Maximum = vector(0.5, 0.5), vector(0.5, 0.5)
                slot:SetAnchors(anchors)
                slot:SetAlignment(vector(0.5, 0.5))
                slot:SetPosition(vector(0, 0))
                visibility(data.container, passive)
            end)
            if not okBuild then detach(data); return false, "UI_BUILD_UNAVAILABLE" end
            data.visible = true; UI._data = data; UI.SetBusy(UI._busy)
            return true
        end
        function UI.ShowNotice(message)
            local shown, reason = UI.Show(function() return false end)
            if not shown then return false, reason end
            UI.SetStatus(message); UI.SetBusy(true); return true
        end
        return UI
    end
    return Module
end)()

-- ============================================================
-- 4) POPUP #2: WELCOME CARD
-- ============================================================
local YtMursleenWelcomeUI = (function()
    local Module = {}
    function Module.new(env)
        env = env or _G
        local require = env.require or require
        local function global(n)
            local ok, v = pcall(function() return env[n] end)
            if ok then return v end
        end
        local function member(o, k)
            if o == nil then return nil end
            local ok, v = pcall(function() return o[k] end)
            if ok then return v end
        end
        local function valid(o)
            local c = member(global("slua"), "isValid")
            if o == nil then return false end
            if type(c) == 'function' then
                local ok, v = pcall(c, o)
                if ok and v == true then return true end
            end
            local g = global('Game'); local f = member(g, 'IsValid')
            if type(f) == 'function' then
                local ok, v = pcall(f, g, o)
                return ok and v == true
            end
            return false
        end
        local function imported(n)
            local l = global("import")
            if type(l) ~= "function" then return nil end
            local ok, v = pcall(l, n); if ok then return v end
        end
        local function construct(c, ...)
            if c == nil then return nil end
            local ok, v = pcall(c, ...); if ok then return v end
        end
        local function vector(x, y)
            return construct(global("FVector2D") or imported("Vector2D"), x, y) or {X = x, Y = y}
        end
        local function linear(v)
            v = v / 255
            if v <= 0.04045 then return v / 12.92 end
            return ((v + 0.055) / 1.055) ^ 2.4
        end
        local function color(r, g, b, a)
            r, g, b, a = linear(r), linear(g), linear(b), a or 1
            return construct(global("FLinearColor") or imported("LinearColor"), r, g, b, a)
                or {R = r, G = g, B = b, A = a}
        end
        local function visibility(w, v)
            local s = member(w, "SetWidgetVisibility") or member(w, "SetVisibility")
            if type(s) == 'function' then s(w, v) end
        end
        local WelcomeUI = {Width = 600, Height = 276}
        local WelcomeText = {
            "Welcome to @DR_SUBHAN Lua mod",
            "Kill limit 8-10",
            "Play smart and avoid report",
        }
        local UI = {_shown = false, _data = nil}
        local function detach(data)
            if not data then return end
            data.Visible = false
            if data.Event and data.EventHandle ~= nil then
                pcall(function() data.Event:Remove(data.EventHandle) end)
            end
            if valid(data.Container) then
                pcall(function() visibility(data.Container, data.Hidden) end)
                pcall(function() data.Container:RemoveFromParent() end)
            end
        end
        function UI:Destroy() local p = UI._data; UI._data = nil; detach(p) end
        local function parent()
            local okT, tools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameUITools")
            if not okT then return nil end
            local getRoot = member(tools, "GetMainControlBaseUI")
            if type(getRoot) ~= "function" then return nil end
            local ok, root = pcall(getRoot)
            if not ok or not valid(root) then return nil end
            local canvas = member(root, "CanvasPanel_0")
            if not valid(canvas) then canvas = member(root, "CanvasPanel_42") end
            if valid(canvas) then return root, canvas end
        end
        function UI:Show()
            if UI._shown and UI._data and valid(UI._data.Container) then
                visibility(UI._data.Container, UI._data.Passive)
                UI._data.Visible = true
                return true
            end
            UI:Destroy()
            local root, par = parent()
            if not par then return false, "WELCOME_ROOT_UNAVAILABLE" end
            local game = global("CGame")
            if type(member(game, "NewObjectFromPath")) ~= "function" then
                return false, "WELCOME_FACTORY_UNAVAILABLE"
            end
            local enums = member(global("UEnums"), "ESlateVisibility")
            local visible, hidden, passive = member(enums, "Visible"),
                member(enums, "Collapsed"), member(enums, "SelfHitTestInvisible")
            if visible == nil or hidden == nil or passive == nil then
                return false, "WELCOME_ENUM_UNAVAILABLE"
            end
            local data = {Root = root, Parent = par, Visible = false,
                          Hidden = hidden, Passive = passive}
            local ok = pcall(function()
                local function make(class, outer)
                    local w = game:NewObjectFromPath("/Script/UMG." .. class, outer)
                    assert(valid(w), "WELCOME_WIDGET_UNAVAILABLE")
                    return w
                end
                data.Container = make("CanvasPanel", par)
                visibility(data.Container, hidden)
                local function add(w, x, y, ww, hh, z)
                    local s = data.Container:AddChildToCanvas(w)
                    s:SetAutoSize(false)
                    s:SetPosition(vector(x, y))
                    s:SetSize(vector(ww, hh))
                    s:SetZOrder(z)
                    return s
                end
                local function rect(x, y, ww, hh, c, z)
                    local w = make("Border", data.Container)
                    w:SetBrushColor(c)
                    visibility(w, passive)
                    add(w, x, y, ww, hh, z)
                    return w
                end
                local slateColor
                pcall(function() slateColor = imported("SlateColor") end)
                local function textStyle(w, size, c)
                    local font = member(w, "Font")
                    if font ~= nil then
                        if type(font) == 'table' then
                            local copy = {}
                            for k, v in pairs(font) do copy[k] = v end
                            font = copy
                        end
                        font.Size = size
                        pcall(function() w:SetFont(font) end)
                    end
                    pcall(function() w:SetColorAndOpacity(slateColor and slateColor(c) or c) end)
                    pcall(function() w:SetJustification(1) end)
                    visibility(w, passive)
                end
                local function text(value, x, y, ww, hh, size, c, z)
                    local w = make("TextBlock", data.Container)
                    w:SetText(value)
                    textStyle(w, size, c)
                    pcall(function() w:SetAutoWrapText(true) end)
                    add(w, x, y, ww, hh, z)
                    return w
                end
                local W, H = WelcomeUI.Width, WelcomeUI.Height
                rect(4, 6, W, H, color(18, 5, 10, 0.25), 0)
                rect(0, 0, W, H, color(186, 137, 74), 1)
                rect(2, 2, W - 4, H - 4, color(255, 244, 214), 2)
                local stops = {{116, 16, 46}, {169, 38, 47}, {194, 105, 35}}
                local segments = 64
                for i = 0, segments - 1 do
                    local t = i / (segments - 1)
                    local left, right, blend
                    if t <= 0.5 then left, right, blend = stops[1], stops[2], t * 2
                    else left, right, blend = stops[2], stops[3], (t - 0.5) * 2 end
                    local x0 = 2 + (W - 4) * i / segments
                    local x1 = 2 + (W - 4) * (i + 1) / segments
                    rect(x0, 2, math.min(W - 2, x1 + 0.3) - x0, 76,
                        color(left[1] + (right[1] - left[1]) * blend,
                              left[2] + (right[2] - left[2]) * blend,
                              left[3] + (right[3] - left[3]) * blend), 3)
                end
                rect(18, 3, W - 36, 1, color(255, 255, 255, 0.32), 4)
                rect(2, 78, W - 4, 3, color(238, 188, 93), 4)
                local title = text(WelcomeText[1], 24, 23, W - 48, 44, 19, color(255, 253, 247), 5)
                pcall(function() title:SetShadowOffset(vector(0, 1)) end)
                pcall(function() title:SetShadowColorAndOpacity(color(40, 3, 12, 0.45)) end)
                rect(30, 100, W - 60, 54, color(255, 226, 159), 3)
                rect(30, 100, 4, 54, color(160, 33, 49), 4)
                text(WelcomeText[2], 46, 110, W - 92, 38, 23, color(115, 25, 45), 5)
                text(WelcomeText[3], 30, 168, W - 60, 32, 17, color(130, 34, 47), 5)
                local button = make("Button", data.Container)
                pcall(function() button:SetBackgroundColor(color(131, 25, 47)) end)
                visibility(button, visible)
                local label = make("TextBlock", button)
                label:SetText("OK")
                textStyle(label, 17, color(255, 251, 238))
                local ls = button:AddChild(label)
                pcall(function() ls:SetHorizontalAlignment(2) end)
                pcall(function() ls:SetVerticalAlignment(2) end)
                add(button, (W - 164) / 2, 212, 164, 42, 6)
                data.Event = member(button, "OnClicked")
                data.EventHandle = data.Event:Add(function()
                    if UI._data == data and data.Visible then UI:Destroy() end
                end)
                local slot = par:AddChildToCanvas(data.Container)
                slot:SetAutoSize(false)
                slot:SetSize(vector(W, H))
                slot:SetZOrder(9200)
                local anchors = slot:GetAnchors()
                anchors.Minimum, anchors.Maximum = vector(0.5, 0.5), vector(0.5, 0.5)
                slot:SetAnchors(anchors)
                slot:SetAlignment(vector(0.5, 0.5))
                slot:SetPosition(vector(0, 0))
                visibility(data.Container, passive)
            end)
            if not ok then detach(data); return false, "WELCOME_BUILD_FAILED" end
            data.Visible = true
            UI._data = data
            UI._shown = true
            return true
        end
        function UI:Hide() if UI._data then detach(UI._data) end; UI._data = nil end
        function UI:IsShown() return UI._shown == true end
        return UI
    end
    return Module
end)()
_G.YtMursleenWelcomeUI = YtMursleenWelcomeUI

-- ============================================================
-- 5) RUNTIME (gate + 3s stable-gameplay + welcome-once)
-- ============================================================
local YtMursleenLicenseRuntime = (function()
    local Runtime = {}
    Runtime.__index = Runtime
    local function finite(n)
        return type(n) == 'number' and n == n and n >= 0 and n < math.huge
    end
    local function read(o, k)
        if o == nil then return nil end
        local ok, v = pcall(function() return o[k] end)
        if ok then return v end
    end
    local function static(o, k, ...)
        local fn = read(o, k)
        if type(fn) ~= 'function' then return nil end
        local ok, v = pcall(fn, ...); if ok then return v end
    end
    local function call(o, k, ...)
        local fn = read(o, k)
        if type(fn) ~= 'function' then return nil end
        local ok, v = pcall(fn, o, ...); if ok then return v end
    end
    local function validConfig(c)
        return type(c) == 'table' and type(c.url) == 'string' and c.url:match('^https://') ~= nil
            and type(c.game) == 'string' and #c.game > 0
            and type(c.secret) == 'string' and #c.secret > 0
            and finite(c.timeout) and c.timeout > 0 and finite(c.clockSkew)
    end
    function Runtime.new(env, config, Core, LoginUI)
        local self = setmetatable({
            env = env or _G, reason = 'login_required', active = false,
            ready = false, disposed = false, uiRetryAt = 0, uiFailures = 0
        }, Runtime)
        if not validConfig(config) or type(Core) ~= 'table' or type(Core.new) ~= 'function'
            or type(Core.Primitives) ~= 'table' then
            self.reason = 'license_dependencies_unavailable'; return self
        end
        local cfg = {}
        for k, v in pairs(config) do cfg[k] = v end
        self.timeout = cfg.timeout
        if type(LoginUI) == 'table' and type(LoginUI.new) == 'function' then
            local ok, ui = pcall(LoginUI.new, self.env)
            if ok and type(ui) == 'table' then self.ui = ui end
        end
        if type(_G.YtMursleenWelcomeUI) == 'table' and type(_G.YtMursleenWelcomeUI.new) == 'function' then
            local okW, w = pcall(_G.YtMursleenWelcomeUI.new, self.env)
            if okW and type(w) == 'table' then self.welcome = w end
        end
        self.welcomeShownThisSession = true
        self.welcomeScheduledAt = nil
        self.welcomeDelaySeconds = 3.0
        self.submit = function(key) return self:login(key) end
        local ok, auth = pcall(Core.new, cfg, {
            clock = function() return self:_clock() end,
            wall = function()
                local value = static(read(self.env, 'os'), 'time')
                if finite(value) and value > 0 then return value end
            end,
            serial = function(key)
                local client = read(self.env, 'Client')
                local value = nil
                for _, name in ipairs({
                    'GetPhoneDeviceID', 'GetDeviceID', 'GetDeviceId',
                    'GetUUID', 'GetUniqueID', 'GetClientDeviceID',
                }) do
                    local fn = read(client, name)
                    if type(fn) == 'function' then
                        local ok, v = pcall(fn, client)
                        if ok and type(v) == 'string' and #v > 0 then value = v; break end
                    end
                end
                if not value then
                    local prop = read(client, 'DeviceID') or read(client, 'UUID')
                    if type(prop) == 'string' and #prop > 0 then value = prop end
                end
                if not value then
                    local gd = self.gameplayData
                    local pc = gd and gd.GetPlayerController and gd.GetPlayerController()
                    if pc and type(read(pc, 'GetPlayerKey')) == 'function' then
                        local ok, k = pcall(pc.GetPlayerKey, pc)
                        if ok and k then value = tostring(k) end
                    end
                end
                if not value then value = 'unknown-device' end
                return Core.Primitives.name_uuid('YtMursleen-LUA-V1\0' .. key .. '\0' .. value)
            end,
            decode = function(raw)
                local json = self:_module('json', nil, 'common.json_util', 'decode')
                assert(json, 'JSON_UNAVAILABLE')
                return json.decode(raw)
            end,
            post = function(url, headers, body, callback, timeout)
                local manager = read(self.env, 'ModuleManager')
                local http = nil
                local config = read(manager, 'CommonModuleConfig')
                local getter = read(manager, 'GetModule')
                if type(getter) == 'function' and config then
                    local ok, h = pcall(getter, read(config, 'http_manager'))
                    if ok and h and type(read(h, 'Post')) == 'function' then http = h end
                end
                if not http then
                    local okR, hm = pcall(require, "client.slua.logic.http.http_manager")
                    if okR and hm and type(hm.Post) == 'function' then http = hm end
                end
                if not http then error('HTTP_POST_UNAVAILABLE') end
                return http:Post(url, headers, body, nil, callback, timeout)
            end,
            status = function(message, phase)
                self.active = false
                self.reason = phase == 'active' and 'waiting_maintenance' or 'login_required'
                self:_ui('SetStatus', message)
                self:_ui('SetBusy', phase == 'pending')
                if phase == 'active' then self:_ui('Hide') end
            end,
        })
        if ok and type(auth) == 'table' then self.auth = auth
        else self.reason = 'license_initialization_unavailable' end
        return self
    end
    function Runtime:_module(cache, globalName, path, method)
        local found = globalName and read(self.env, globalName)
        if type(read(found, method)) == 'function' then return found end
        found = self[cache]
        if type(read(found, method)) == 'function' then return found end
        local loader = read(self.env, 'require')
        if type(loader) == 'function' then
            local ok, value = pcall(loader, path)
            if ok and type(read(value, method)) == 'function' then
                self[cache] = value; return value
            end
        end
    end
    function Runtime:_valid(object)
        if object == nil then return false end
        if static(read(self.env, 'slua'), 'isValid', object) == true then return true end
        return call(read(self.env, 'Game'), 'IsValid', object) == true
    end
    function Runtime:_clock()
        local world = static(read(self.env, 'slua'), 'getWorld')
        if world == nil then return nil end
        local statics = read(self.env, 'GameplayStatics') or self.statics
        if type(read(statics, 'GetRealTimeSeconds')) ~= 'function' then
            local loader = read(self.env, 'import')
            if type(loader) == 'function' then
                local ok, value = pcall(loader, 'GameplayStatics')
                if ok then statics = value end
            end
        end
        if type(read(statics, 'GetRealTimeSeconds')) ~= 'function' then return nil end
        self.statics = statics
        local now = static(statics, 'GetRealTimeSeconds', world)
        if finite(now) then return now, world end
    end
    function Runtime:_readGameplay(world)
        local data = read(self.env, 'GameplayData') or self.gameplayData
        if data == nil then
            local loader = read(self.env, 'require')
            if type(loader) == 'function' then
                local ok, value = pcall(loader, 'GameLua.GameCore.Data.GameplayData')
                if ok and value ~= nil then self.gameplayData = value; data = value end
            end
        end
        local pc = static(data, 'GetPlayerController')
        if not self:_valid(pc) and not self:_valid(read(pc, 'Object')) then
            pc = call(read(self.env, 'slua_GameFrontendHUD'), 'GetPlayerController')
        end
        if not self:_valid(pc) and not self:_valid(read(pc, 'Object')) then
            return nil, 'waiting_controller'
        end
        local pawn = static(data, 'GetPlayerCharacter')
        if not self:_valid(pawn) then pawn = static(data, 'GetLocalCharacter') end
        for _, method in ipairs({'GetPlayerCharacterSafety', 'GetCurPawn', 'GetPawn'}) do
            if not self:_valid(pawn) then pawn = call(pc, method) end
            if not self:_valid(pawn) then pawn = call(read(pc, 'Object'), method) end
        end
        if not self:_valid(pawn) then return nil, 'waiting_pawn' end
        local tools = self:_module('tools', nil,
            'GameLua.Mod.BaseMod.Common.UI.InGameUITools', 'GetMainControlBaseUI')
        local root = static(tools, 'GetMainControlBaseUI')
        if not self:_valid(root) then return nil, 'waiting_control_ui' end
        local status = self:_module('gameStatus', 'GameStatus',
            'client.common.game_status', 'IsInFightingStatus')
        local loading = self:_module('loading', nil,
            'client.slua.logic.loading.logic_loading', 'IsShowing')
        if not status or not loading then return nil, 'readiness_services_unavailable' end
        if static(status, 'IsInFightingStatus') ~= true then return nil, 'waiting_gameplay' end
        if static(loading, 'IsShowing') ~= false then return nil, 'waiting_loading' end
        return {world = world, controller = pc, pawn = pawn, root = root}
    end
    local function same(a, b)
        return a and b and a.world == b.world and a.controller == b.controller
            and a.pawn == b.pawn and a.root == b.root
    end
    function Runtime:_ui(method, ...)
        local fn = read(self.ui, method)
        if type(fn) ~= 'function' then return false, 'UI_UNAVAILABLE' end
        local ok, value, reason = pcall(fn, ...)
        if not ok then return false, 'UI_TEMPORARILY_UNAVAILABLE' end
        return value, reason
    end
    function Runtime:_clearReadiness(reason)
        self.active, self.ready = false, false
        self.identity, self.readySince, self.maintenanceAt, self.maintenanceWorld = nil, nil, nil, nil
        self.reason = reason
        self:_ui('Hide')
    end
    function Runtime:_showPanel(now, state, blocked)
        if now < self.uiRetryAt then return false end
        local shown, uiReason
        if blocked then shown, uiReason = self:_ui('ShowNotice', state.message)
        else shown, uiReason = self:_ui('Show', self.submit) end
        if shown then
            self.uiFailures, self.uiError = 0, nil
            self:_ui('SetStatus', state.message)
            self:_ui('SetBusy', blocked or state.pending)
        else
            self.uiFailures = self.uiFailures + 1
            self.uiRetryAt = now + (self.uiFailures >= 10 and 5 or 1)
            self.uiError = type(uiReason) == 'string' and uiReason:match('^UI_[A-Z_]+$')
                or 'UI_UNAVAILABLE'
        end
        return shown == true
    end
    function Runtime:update()
        if self.disposed then self.reason = 'disposed'; return false end
        if not self.auth then return false end
        local tickOK = pcall(self.auth.Tick)
        if not tickOK then
            self.auth.FailClosed('License maintenance unavailable.')
            self:_clearReadiness('license_maintenance_unavailable'); return false
        end
        local now, world = self:_clock()
        if not now then self:_clearReadiness('clock_unavailable'); return false end
        local ready, reason = self:_readGameplay(world)
        if not ready then self:_clearReadiness(reason); return false end
        if not same(self.identity, ready) or not self.readySince or now < self.readySince then
            self.identity, self.readySince = ready, now
        end
        self.ready = now - self.readySince >= 3
        self.maintenanceAt, self.maintenanceWorld = now, world
        self.active = self.ready and self.auth.IsAuthorized()
        if not self.ready then
            self.reason = 'waiting_stable_gameplay'; self:_ui('Hide'); return false
        end
        local state = self.auth.GetState()
        if self.active then
            self.reason = 'active'
            self:_ui('Hide')
            if self.welcome and not self.welcomeShownThisSession then
                if not self.welcomeScheduledAt then self.welcomeScheduledAt = now end
                if self.welcomeScheduledAt
                    and (now - self.welcomeScheduledAt) >= self.welcomeDelaySeconds then
                    local shown = false
                    pcall(function() if self.welcome:Show() then shown = true end end)
                    if shown then
                        self.welcomeShownThisSession = true
                        _G.__YtMursleen_WELCOME_SHOWN_SESSION = true
                        self.welcomeScheduledAt = nil
                    else
                        self.welcomeScheduledAt = now
                    end
                end
            end
            return true
        end
        self.reason = 'login_required'
        if state.restartRequired or state.phase == 'expired' or state.phase == 'tampered' then
            self.reason = state.restartRequired and 'restart_required' or state.phase
            self:_showPanel(now, state, true); return false
        end
        if not self:_showPanel(now, state, false) and self.uiError then
            self.reason = 'login_ui_unavailable'
        end
        return false
    end
    function Runtime:isActive()
        if self.disposed or not self.auth or not self.active or not self.ready then return false end
        if not self.auth.IsAuthorized() then self.active = false; return false end
        local now, world = self:_clock()
        if not now or world ~= self.maintenanceWorld or not self.maintenanceAt
            or now < self.maintenanceAt or now - self.maintenanceAt >= 3 then
            self.active = false; self.reason = 'maintenance_stale'; return false
        end
        return true
    end
    function Runtime:login(key)
        if self.disposed or not self.auth then return false end
        if self.auth.IsAuthorized() then return true end
        local now, world = self:_clock()
        if not self.ready or not now or world ~= self.maintenanceWorld
            or not self.maintenanceAt or now < self.maintenanceAt
            or now - self.maintenanceAt >= 3 then return false end
        local identity = self:_readGameplay(world)
        if not same(identity, self.identity) then
            self:_clearReadiness('waiting_stable_gameplay'); return false
        end
        local ok, accepted = pcall(self.auth.Login, key)
        if not ok then self.auth.FailClosed('Login could not start.'); return false end
        return accepted == true
    end
    function Runtime:getStatus()
        local active = self:isActive()
        local state = self.auth and self.auth.GetState() or {}
        return {
            authorized = active, sessionAuthorized = state.authorized == true,
            phase = state.phase or 'locked',
            message = state.message or 'License dependencies unavailable.',
            reason = self.reason, pending = state.pending == true,
            gameplayReady = self.ready, expiresAt = state.expiresAt,
            accessPolicy = 'game_session', expiryCheckPolicy = 'login_only',
            clockProtection = 'login_only', periodicRecheck = false,
            loginDelaySeconds = 3, restartRequired = state.restartRequired == true,
            uiError = self.uiError,
            lastRequestLatencyMs = state.lastRequestLatencyMs,
            latencyScope = 'license_http_round_trip', disposed = self.disposed
        }
    end
    function Runtime:logout()
        self.active = false
        if self.auth then self.auth.Logout() end
        self.reason = 'login_required'; return true
    end
    function Runtime:dispose()
        if self.disposed then return true end
        self:logout(); self.disposed = true; self.ready = false
        self:_ui('Destroy'); self.reason = 'disposed'
        self.submit = nil
        return true
    end
    return Runtime
end)()

-- ============================================================
-- 6) SINGLETON + MAINTENANCE + GLOBAL API
-- ============================================================
local LicenseInstance = nil
local MaintenanceState = {timer = nil, owner = nil}

local function EnsureLicense()
    if LicenseInstance then return LicenseInstance end
    local GameplayData = nil
    pcall(function() GameplayData = require("GameLua.GameCore.Data.GameplayData") end)
    local host = setmetatable({GameplayData = GameplayData}, {__index = _ENV})
    LicenseInstance = YtMursleenLicenseRuntime.new(
        host, YtMursleenLicenseConfig, YtMursleenLicenseCore, YtMursleenLoginUI)
    _G.YtMursleenESPLicenseInstance = LicenseInstance
    return LicenseInstance
end

local function MaintenanceTick()
    if LicenseInstance then
        pcall(function() LicenseInstance:update() end)
    end
end

local function AttachMaintenance(owner)
    if not slua.isValid(owner) then return false end
    if type(owner.AddGameTimer) ~= "function" then return false end
    if MaintenanceState.timer and MaintenanceState.owner == owner then return true end
    if MaintenanceState.timer and slua.isValid(MaintenanceState.owner)
        and type(MaintenanceState.owner.RemoveGameTimer) == "function" then
        pcall(function() MaintenanceState.owner:RemoveGameTimer(MaintenanceState.timer) end)
    end
    MaintenanceState.timer, MaintenanceState.owner = nil, nil
    local ok, timer = pcall(function() return owner:AddGameTimer(1.0, true, MaintenanceTick) end)
    if not ok or not timer then return false end
    MaintenanceState.timer, MaintenanceState.owner = timer, owner
    pcall(MaintenanceTick)
    return true
end

local function TryAttachMaintenance()
    local pc = nil
    pcall(function()
        local GDP = require("GameLua.GameCore.Data.GameplayData")
        if GDP and GDP.GetPlayerController then pc = GDP.GetPlayerController() end
    end)
    if not slua.isValid(pc) then
        pcall(function()
            if slua_GameFrontendHUD then pc = slua_GameFrontendHUD:GetPlayerController() end
        end)
    end
    if slua.isValid(pc) then AttachMaintenance(pc) end
end

local EXPIRY_TIMESTAMP = os.time({year = 2027, month = 8, day = 20, hour = 0, min = 0, sec = 0})
local function CheckExpiration()
    if LicenseInstance then
        local active = false
        pcall(function() active = LicenseInstance:isActive() end)
        if active then _G._MOD_EXPIRED = false; return true end
    end
    local now = os.time()
    local remaining = EXPIRY_TIMESTAMP - now
    if remaining <= 0 then _G._MOD_EXPIRED = true; return false end
    _G._MOD_EXPIRED = false
    _G._MOD_REMAINING_SECONDS = remaining
    return true
end
_G.CheckExpiration = CheckExpiration

function _G.TryShowWelcome()
    if _G.WelcomeShown then return end
    if not CheckExpiration() then return end
    _G.WelcomeShown = true
end

pcall(function()
    EnsureLicense()
    TryAttachMaintenance()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(1, function() TryAttachMaintenance() end)
        ticker.AddTimerOnce(2, function() TryAttachMaintenance() end)
        ticker.AddTimerOnce(3, function() if CheckExpiration() then _G.TryShowWelcome() end end)
    end
end)

function _G.YtMursleenLicenseLogin(key)
    EnsureLicense()
    if not LicenseInstance then return false, 'license_unavailable' end
    local ok, result = pcall(LicenseInstance.login, LicenseInstance, key)
    if not ok then return false, 'license_unavailable' end
    return result
end
function _G.YtMursleenLicenseLogout()
    if not LicenseInstance then return false end
    return pcall(LicenseInstance.logout, LicenseInstance)
end
function _G.YtMursleenLicenseStatus()
    EnsureLicense()
    if not LicenseInstance then
        return {authorized = false, phase = 'locked', message = 'license_unavailable'}
    end
    local ok, value = pcall(LicenseInstance.getStatus, LicenseInstance)
    return ok and value or {authorized = false, phase = 'locked'}
end
local function IsLicenseActive()
    if not LicenseInstance then return false end
    local active = false
    pcall(function() active = LicenseInstance:isActive() == true end)
    return active
end
_G.IsLicenseActive = IsLicenseActive
_G.IsGateBlocked = function() return not IsLicenseActive() end

-- ============================================================
-- 7) MAGIC BULLET + AUTO-HEAD + BYPASS (gated by license)
-- ============================================================
local function startBaselineHacks()
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local EPawnState   = import("EPawnState")
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    _G.g_masterahsanyt = _G.g_masterahsanyt or "@DR_SUBHAN"
    local g_masterahsanyt_StartSettingsMaintenance

    -- ========== BYPASS START ==========
    do
        local function _nop() end
        local function _retTrue() return true end
        local function _retFalse() return false end
        local function _retZero() return 0 end
        local function _retEmpty() return {} end
        local function _retEmptyStr() return "" end
        local function _once(obj, key)
            if obj == nil then return false end
            if obj[key] then return false end
            local ok = pcall(function() obj[key] = true end)
            return ok
        end

        local BLOCKED_PACKETS = {
            ["ReportAttackFlow"]=true,["ReportSecAttackFlow"]=true,["ReportFireArms"]=true,
            ["ReportVerifyInfoFlow"]=true,["ReportMrpcsFlow"]=true,["ReportPlayerBehavior"]=true,
            ["ReportTeammatHurt"]=true,["ReportMisKillByTeammate"]=true,["ReportForbitPick"]=true,
            ["ReportPlayerMoveRoute"]=true,["ReportPlayerPosition"]=true,["ReportVehicleMoveFlow"]=true,
            ["ReportSecTgameMovingFlow"]=true,["ReportParachuteData"]=true,
            ["SendTssSdkAntiDataToLobby"]=true,["ReportEquipmentFlow"]=true,["ReportAimFlow"]=true,
            ["ReportPlayersPing"]=true,["ReportPlayerIP"]=true,["ReportPlayerFramePingRecord"]=true,
            ["OnDSConnectionSaturated"]=true,["ReportDSNetSaturation"]=true,
            ["ReportNetContinuousSaturate"]=true,["ReportDSNetRate"]=true,["SendClientStats"]=true,
            ["SendServerAvgTickDelta"]=true,["ReportCircleFlow"]=true,["ClientSecMrpcsFlow"]=true,
            ["SwiftHawk"]=true,["ClientSwiftHawk"]=true,["ClientSwiftHawkWithParams"]=true,
            ["SwiftHawkReport"]=true,["SwiftHawkData"]=true,
            ["ReportHitFlow"]=true,["CoronaLabReport"]=true,["CoronaLabData"]=true,
            ["PlayerSecurityInfo"]=true,["ReportSecurityInfo"]=true,["SendSecurityData"]=true,
            ["ClientCircleFlow"]=true,["ReportModifierException"]=true,
            ["ReportSimulateCharacterLocation"]=true,["RPC_Client_ShootVertifyRes"]=true,
            ["BulletHitInfoUploadData"]=true,["ShootVerifyFailed"]=true,
            ["report_unrealnet_exception"]=true,["tss_sdk_report"]=true,
            ["AntiCheatReport"]=true,["CheatDetection"]=true,["ViolationReport"]=true,
            ["SecurityViolation"]=true,["IntegrityCheck"]=true,["SignatureVerify"]=true,
            ["report_speed_hack"]=true,["report_wall_hack"]=true,["report_aim_bot"]=true,
            ["report_esp_usage"]=true,["report_modded_files"]=true,["detect_cheat"]=true,
            ["ban_player"]=true,["client_anti_cheat_report"]=true,
            ["HiggsBosonReport"]=true,["AvatarExceptionReport"]=true,["ReportItemID"]=true,
            ["SendHisarData"]=true,["ServerReportAvatar"]=true,["ClientReportNetAvatar"]=true,
            ["ReportViolation"]=true,["ProcessSecurityEvent"]=true,
            ["ReportHitboxScale"]=true,["ReportPhysicsAssetChange"]=true,
            ["ReportBodyTypeAnomaly"]=true,["ReportMagicBulletUsage"]=true,
            ["report_abnormal_physics"]=true,["report_hitbox_mismatch"]=true,
            ["report_magic_bullet"]=true,["report_body_type_anomaly"]=true,
            ["RPC_ClientCoronaLab"]=true,["MrpcsData"]=true,
            ["RPC_Server_ReportSimulateCharacterLocation"]=true,
        }
        local REPORT_FLOW_FUNCS = {
            "ReportAttackFlow","ReportSecAttackFlow","ReportFireArms","ReportVerifyInfoFlow",
            "ReportMrpcsFlow","ReportPlayerBehavior","ReportTeammatHurt","ReportMisKillByTeammate",
            "ReportForbitPick","ReportPlayerMoveRoute","ReportPlayerPosition","ReportVehicleMoveFlow",
            "ReportSecTgameMovingFlow","ReportParachuteData","SendTssSdkAntiDataToLobby",
            "ReportEquipmentFlow","ReportAimFlow","ReportPlayersPing","ReportPlayerIP",
            "ReportPlayerFramePingRecord","OnDSConnectionSaturated","ReportDSNetSaturation",
            "ReportNetContinuousSaturate","ReportDSNetRate","SendClientStats",
            "SendServerAvgTickDelta","ReportCircleFlow","ClientSecMrpcsFlow",
            "SwiftHawk","ClientSwiftHawk","ClientSwiftHawkWithParams",
            "ReportHitFlow","CoronaLabReport","CoronaLabData",
            "PlayerSecurityInfo","ReportSecurityInfo","SendSecurityData",
            "ClientCircleFlow","ReportModifierException","ReportSimulateCharacterLocation",
            "RPC_Client_ShootVertifyRes","BulletHitInfoUploadData","ShootVerifyFailed",
            "report_unrealnet_exception","tss_sdk_report","AntiCheatReport",
            "CheatDetection","ViolationReport","SecurityViolation","IntegrityCheck",
            "SignatureVerify","report_speed_hack","report_wall_hack","report_aim_bot",
            "report_esp_usage","report_modded_files","detect_cheat","ban_player",
            "client_anti_cheat_report","HiggsBosonReport","AvatarExceptionReport",
            "ReportItemID","SendHisarData","ServerReportAvatar","ClientReportNetAvatar",
            "ReportViolation","ProcessSecurityEvent",
            "ReportHitboxScale","ReportPhysicsAssetChange","ReportBodyTypeAnomaly",
            "ReportMagicBulletUsage","report_abnormal_physics","report_hitbox_mismatch",
            "report_magic_bullet","report_body_type_anomaly",
        }
        local REPORT_STATE_CALLBACKS = {
            "ReportWallHack","ReportAimbot","ReportSpeedHack","ReportMagicBullet",
            "ReportAbnormalMaterial","ReportDepthTestChange","ReportMemoryException",
            "ReportMaterialScan","ReportShaderOverride","ReportESPBox","ReportESPHealth",
            "ReportMiniMapESP","ReportEnemyFrameUI","ReportMarkCreated","ReportMarkDestroyed",
            "MarkSuspiciousESP","OnScreenMarkAdd","OnScreenMarkRemove","ReportDistanceMarker",
            "ReportWallhackESP","SendESPData","UploadESPInfo","ReportHurtFlow",
            "OnPlayerRPCValidateFailed","OnPlayerActorChannelError","OnPlayerSpectateException",
            "OnShutdownAfterError",
        }
        local SUBSYSTEM_TARGETS = {
            "CoronaLabSubsystem","PlayerSecurityInfoSubsystem","ClientCircleFlowSubsystem",
            "ModifierExceptionSubsystem","SimulateCharacterSubsystem",
            "ShootVerifySubSystemClient","HiggsBosonComponent",
            "ClientReportPlayerSubsystem","DSReportPlayerSubsystem",
            "ClientHawkEyePatrolSubsystem","DSHawkEyePatrolSubsystem",
            "ClientDataStatistcsSubsystem","AFKReportorSubsystem",
            "BehaviorScoreSubsystem","FileCheckSubsystem","MemoryCheckSubsystem",
            "SpeedCheckSubsystem","WallCheckSubsystem","AvatarExceptionSubsystem",
            "GameReportSubsystem","ClientSecMrpcsFlowSubsystem","MrpcsFlowSubsystem",
            "CircleFlowSubsystem","SwiftHawkSubsystem","AntiCheatSubsystem",
            "IntegrityCheckSubsystem","SignatureVerifySubsystem",
            "MD5CheckSubsystem","PakVerifySubsystem",
            "ClientWallhackDetectionSubsystem","ClientESPDetectionSubsystem",
            "ClientAimTrackingSubsystem","ClientRenderCheckSubsystem",
            "ClientKernelCheckSubsystem","ClientMemoryGuardSubsystem",
            "AvatarExceptionPlayerInst","ClientAntiCheatSubsystem",
        }

        local function layer1_slua()
            pcall(function()
                local slua = rawget(_G, "slua")
                if slua and _once(slua, "__lunar_sig_patched") then
                    if slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
                end
                local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
                if loader and _once(loader, "__lunar_loader_patched") then
                    loader.verifyBytecode = _retTrue
                    loader.checkIntegrity = _retTrue
                    loader.disableSignatureCheck = _retTrue
                end
                local ser = package.loaded["slua.serialize"]
                if ser and _once(ser, "__lunar_ser_patched") then
                    ser.check = _retTrue; ser.verify = _retTrue
                end
                if jit and jit.attach and not _G.__lunar_jit_bc then
                    jit.attach(_nop, "bc"); _G.__lunar_jit_bc = true
                end
                if not _G.__lunar_slua_globals then
                    _G.slua_verify = _retTrue
                    _G.check_slua_integrity = _retTrue
                    _G.__lunar_slua_globals = true
                end
            end)
        end
        local function layer2_integrity()
            pcall(function()
                local okK, KSL = pcall(import, "KismetSystemLibrary")
                if okK and KSL then
                    for _, cmd in ipairs({
                        "pak.DisablePakSignatureCheck 1","pakchunk.EnableSignatureCheck 0",
                        "s.VerifyPak 0","sig.Check 0","security.DisableChecks 1",
                    }) do pcall(KSL.ExecuteConsoleCommand, nil, cmd) end
                end
                local okC, CMode = pcall(import, "CreativeModeBlueprintLibrary")
                if okC and CMode and _once(CMode, "__lunar_cm_patched") then
                    CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
                    CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
                    CMode.GetContentDiffData = function() return true, "BYPASSED" end
                    CMode.VerifyFileIntegrity = _retTrue
                end
                if not _G.__lunar_hash_globals then
                    _G.MD5Hash = function() return "00000000000000000000000000000000" end
                    _G.CRC32 = function() return 0 end
                    _G.SHA1 = function() return "BYPASS" end
                    _G.__lunar_hash_globals = true
                end
                local FHC = package.loaded["common.file_hash_checker"]
                if FHC and _once(FHC, "__lunar_fhc_patched") then
                    FHC.CheckFileMD5 = _retTrue; FHC.VerifyAll = _retTrue
                    FHC.GetHash = function() return "BYPASS" end
                end
                local okS, ST = pcall(import, "STExtraBlueprintFunctionLibrary")
                if okS and ST and _once(ST, "__lunar_st_patched") then
                    ST.CheckMD5 = _retTrue
                    ST.GetMD5 = function() return "BYPASS" end
                    ST.VerifyFile = _retTrue
                end
            end)
        end
        local function layer3_telemetry()
            pcall(function()
                local okSS, SMTD = pcall(import, "ScreenshotMTDer")
                if okSS and SMTD and _once(SMTD, "__lunar_smtd_patched") then
                    SMTD.MTDePicture = _retEmptyStr
                    SMTD.ReMTDePicture = _retEmptyStr
                    SMTD.HasCaptured = _retTrue
                    SMTD.TakeScreenshot = _nop
                end
                local TLog = package.loaded["TLog"] or _G.TLog
                if TLog and _once(TLog, "__lunar_tlog_patched") then
                    TLog.Info=_nop; TLog.Warning=_nop; TLog.Error=_nop
                    TLog.Debug=_nop; TLog.Report=_nop; TLog.Send=_nop; TLog.Flush=_nop
                end
                for _, name in ipairs({"CrashSight","Bugly"}) do
                    local s = _G[name] or package.loaded[name]
                    if s and _once(s, "__lunar_crash_patched") then
                        s.ReportException=_nop; s.SetCustomData=_nop
                        s.SendCrash=_nop; s.ReportUserException=_nop
                        s.Log=_nop; s.SetUserData=_nop
                    end
                end
                for _, sdk in ipairs({"Firebase","Adjust","AppsFlyer","FacebookAnalytics","GameAnalytics"}) do
                    local s = _G[sdk]
                    if s and _once(s, "__lunar_analytics_patched") then
                        s.logEvent=_nop; s.trackEvent=_nop
                        s.setEnabled=_retFalse; s.sendEvent=_nop; s.report=_nop
                    end
                end
            end)
        end
        local function layer4_avatar()
            pcall(function()
                local ptlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
                if ptlog and _once(ptlog, "__lunar_ptlog_patched") then
                    ptlog.ReportEvent=_nop; ptlog.ReportDownloadResult=_nop
                    ptlog.ReportODPTDError=_nop; ptlog.ReportSkinError=_nop
                end
                local AU = package.loaded["AvatarUtils"]
                if AU and _once(AU, "__lunar_au_patched") then
                    AU.CheckIsWeaponInBlackList = _retFalse
                    AU.IsValidAvatar = _retTrue
                    AU.CheckAvatarIntegrity = _retTrue
                    AU.ReportInvalidAvatar = _nop
                end
                local eqEx = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
                if eqEx and _once(eqEx, "__lunar_eqex_patched") then
                    eqEx.Report=_nop; eqEx.SendException=_nop
                end
            end)
        end
        local function layer5_reportflows()
            pcall(function()
                if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
                local GC = _G.GameplayCallbacks
                if GC.__lunar_patched then return end
                for _, f in ipairs(REPORT_FLOW_FUNCS) do _G[f] = _nop; GC[f] = _nop end
                for _, f in ipairs(REPORT_STATE_CALLBACKS) do _G[f] = _nop; GC[f] = _nop end
                GC.CheckReportSecAttackFlow = _retFalse
                GC.CheckReportSecAttackFlowWithAttackFlow = _retFalse
                for _, f in ipairs({
                    "IsEnableReportMrpcsInCircleFlow","IsEnableReportMrpcsInPartCircleFlow",
                    "IsEnableReportMrpcsFlow","IsEnableReportAttackFlow",
                    "IsEnableReportHitFlow","IsEnableReportCircleFlow",
                }) do _G[f] = _retFalse; GC[f] = _retFalse end
                local origState = GC.OnDSPlayerStateChanged
                GC.OnDSPlayerStateChanged = function(UID, State, ...)
                    if type(State) == "string" then
                        local s = State:lower()
                        if s:find("cheat") or s:find("ban") or s:find("integrity")
                            or s:find("violation") or s:find("kick") or s:find("suspend") then
                            return
                        end
                    end
                    if origState then return origState(UID, State, ...) end
                end
                GC.__lunar_patched = true
            end)
        end
        local function layer6_subsystems()
            pcall(function()
                local okS, SubMgr = pcall(require, "GameLua.GameCore.Module.Subsystem.SubsystemMgr")
                if not okS or not SubMgr then return end
                for _, sn in ipairs(SUBSYSTEM_TARGETS) do
                    local okGet, sub = pcall(function() return SubMgr:Get(sn) end)
                    if okGet and sub and not sub.__lunar_patched then
                        for k, v in pairs(sub) do
                            if type(v) == "function" and (
                                k:find("Report") or k:find("Send") or k:find("Upload")
                                or k:find("Verify") or k:find("Check") or k:find("Validate")
                                or k:find("Scan") or k:find("Detect") or k:find("Collect")
                                or k:find("Flow") or k:find("Heartbeat") or k:find("Ban")
                            ) then pcall(function() sub[k] = _nop end) end
                        end
                        for _, t in ipairs({"timer","heartbeatTimer","reportTimer"}) do
                            if sub[t] then pcall(function() sub:RemoveGameTimer(sub[t]) end) end
                        end
                        if sn == "ClientWallhackDetectionSubsystem" then
                            sub.IsVisionNormal = _retTrue
                            sub.GetVisibilityRate = function() return math.random(60, 85) end
                        elseif sn == "ClientESPDetectionSubsystem" then
                            sub.HasESP = _retFalse
                            sub.CheckOverlay = function() return "clean" end
                        elseif sn == "ClientAimTrackingSubsystem" then
                            sub.GetAimData = function() return { accuracy = math.random(45,65), headshotRate = math.random(15,35) } end
                            sub.IsAimNormal = _retTrue
                        elseif sn == "ClientMemoryGuardSubsystem" then
                            sub.IsMemoryClean = function() return true, {code=0} end
                            sub.ScanResult = function() return "clean" end
                        elseif sn == "ShootVerifySubSystemClient" then
                            sub.OnShootVerifyFailed = _nop
                            sub.VerifyShot = _retTrue
                        elseif sn == "ClientKernelCheckSubsystem" then
                            sub.IsKernelClean = function() return true, {code=0, message="clean"} end
                            sub.GetKernelVersion = function() return "5.4.0-generic" end
                        end
                        sub.__lunar_patched = true
                    end
                end
            end)
        end
        local function layer7_netutil()
            pcall(function()
                local NetUtil = _G.NetUtil
                if NetUtil and type(NetUtil.SendPacket) == "function" and not NetUtil.__lunar_blocked then
                    local orig = NetUtil.SendPacket
                    NetUtil.SendPacket = function(packetName, ...)
                        if BLOCKED_PACKETS[packetName] then return nil end
                        return orig(packetName, ...)
                    end
                    NetUtil.__lunar_blocked = true
                end
            end)
        end
        local function layer8_tss()
            pcall(function()
                local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
                if TssSdk and _once(TssSdk, "__lunar_tss_patched") then
                    TssSdk.SendReportInfo = _nop
                    TssSdk.ReportCheat = _nop
                    TssSdk.ReportException = _nop
                    TssSdk.ScanMemory = _retTrue
                    TssSdk.IsEmulator = _retFalse
                    TssSdk.GetTssSdkReportInfo = _retEmptyStr
                    TssSdk.CheckEnvironment = _retTrue
                    TssSdk.VerifyProcess = _retTrue
                    TssSdk.GetFileMD5 = _retEmptyStr
                    TssSdk.VerifyFileSignature = _retTrue
                    TssSdk.CheckIntegrity = _retTrue
                    TssSdk.OnRecvData = function(data)
                        if type(data) == "string" and (
                            data:find("report",1,true) or data:find("exception",1,true)
                            or data:find("cheat",1,true) or data:find("violation",1,true)
                            or data:find("hack",1,true) or data:find("verify",1,true)
                            or data:find("hitbox",1,true) or data:find("physics",1,true)
                        ) then return end
                    end
                end
            end)
        end
        local function layer9_marks()
            pcall(function()
                local okIGM, IGM = pcall(require, "GameLua.Mod.BaseMod.Common.InGameMarkTools")
                if not okIGM or not IGM then return end
                local MarkMgr = IGM.ScreenMarkManager
                if not MarkMgr or MarkMgr.__lunar_patched then return end
                MarkMgr.GetAllActiveMarks = function(self, ...)
                    local marks = (MarkMgr.__origGetMarks and MarkMgr.__origGetMarks(self, ...)) or {}
                    if type(marks) ~= "table" then return marks end
                    local out = {}
                    for _, m in ipairs(marks) do
                        if m.MarkGroupID ~= 1006 and m.MarkGroupID ~= 9999 then
                            table.insert(out, m)
                        end
                    end
                    return out
                end
                MarkMgr.GetMarksByGroup = function(self, gid)
                    if gid == 1006 or gid == 9999 then return {} end
                end
                MarkMgr.OnAddMark = _nop
                MarkMgr.OnRemoveMark = _nop
                MarkMgr.__lunar_patched = true
            end)
        end
        local function layer10_higgs()
            pcall(function()
                local okH, Higgs = pcall(require, "GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
                if okH and Higgs and not Higgs.__lunar_patched then
                    for _, m in ipairs({
                        "ControlMHActive","Tick","OnTick","MHActiveLogic",
                        "TriggerAvatarCheck","StartAvatarCheck","ReportItemID",
                        "ReceiveAnyDamage","OnWeaponHitRecord","ShowSecurityAlert",
                        "ServerReportAvatar","ClientReportNetAvatar","SendHisarData",
                        "ValidateSecurityData","StaticShowSecurityAlertInDev",
                        "RPC_Client_ShootVertifyRes","RPC_Server_ReportSimulateCharacterLocation",
                        "DisableHiggsBoson","CheckMHActive","ReportViolation",
                        "ProcessSecurityEvent","ValidatePlayer","CheckIntegrity",
                    }) do if Higgs[m] then Higgs[m] = _nop end end
                    Higgs.GetNetAvatarItemIDs = _retEmpty
                    Higgs.GetCurWeaponSkinID = _retZero
                    Higgs.IsMHActive = _retFalse
                    Higgs.bMHActive = false
                    Higgs.bCallPreReplication = false
                    if Higgs.BlackList then for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end end
                    Higgs.__lunar_patched = true
                end
                if not _G.__lunar_blacklist_cleared then
                    _G.BlackList = {}; _G.__lunar_blacklist_cleared = true
                end
                if _G.AvatarCheckCallback and not _G.AvatarCheckCallback.__lunar_patched then
                    _G.AvatarCheckCallback.StartAvatarCheck = _nop
                    _G.AvatarCheckCallback.OnReportItemID = _nop
                    _G.AvatarCheckCallback.__lunar_patched = true
                end
            end)
        end
        local function layer11_global_reports()
            pcall(function()
                local reports = {
                    "ReportESPBox","ReportESPHealth","ReportMiniMapESP","ReportEnemyFrameUI",
                    "ReportMarkCreated","ReportMarkDestroyed","MarkSuspiciousESP",
                    "OnScreenMarkAdd","OnScreenMarkRemove","ReportDistanceMarker",
                    "ReportWallhackESP","SendESPData","UploadESPInfo",
                    "ReportHitboxScale","ReportPhysicsAssetChange",
                    "ReportBodyTypeAnomaly","ReportMagicBulletUsage",
                }
                for _, fn in ipairs(reports) do
                    if _G[fn] then _G[fn] = _nop end
                end
                if not _G.__lunar_module_reports_scrubbed then
                    for _, mod in pairs(package.loaded) do
                        if type(mod) == "table" then
                            for _, fn in ipairs(reports) do
                                if type(mod[fn]) == "function" then mod[fn] = _nop end
                            end
                        end
                    end
                    _G.__lunar_module_reports_scrubbed = true
                end
            end)
        end
        local function layer12_hawkeye()
            pcall(function()
                local okS, SubMgr = pcall(require, "GameLua.GameCore.Module.Subsystem.SubsystemMgr")
                if not okS or not SubMgr then return end
                local okG, hawk = pcall(function() return SubMgr:Get("ClientHawkEyePatrolSubsystem") end)
                if not okG or not hawk or hawk.__lunar_patched then return end
                for _, m in ipairs({
                    "IsDuringHawkEyePatrol","HasReported","HasShownWatchEndedTips",
                    "CheckShowReportedTips","CanInspectorBroadcast",
                    "GetForbidNextPatrolRemainingTimeInSeconds",
                    "GetInspectorBroadcastCount","GetMaxInspectorBroadcastCount",
                    "ReportCheat","SendReportTLog","RequestImprison","ExitWatching",
                    "WantMatchNextPatrol","ShowWatchEndedTips","TryShowReportedTips",
                    "_OnHawkSync","_OnHawkReportSuccess","_OnRecvInspectorBroadcastCount",
                    "_OnInspectorBroadcastResult","_OnPlayerKilledOtherPlayer",
                    "_CollectBeWatchedPlayerInfo","_InitHawkEyePatrolSubsystem",
                    "InitHawkEyePatrolSubsystem","_StartFrameUIRefreshTimer",
                    "_StartHideUITimer","_StartShowDistanceUITimer",
                    "_StartCloseBattleEndedTipsTimer","_StartBattleTimeUsageTimer",
                    "_StartQuitVoiceRoomTimer","_StartExitGameTimer",
                }) do if hawk[m] then hawk[m] = _nop end end
                hawk.__lunar_patched = true
            end)
        end
        local function layer13_replay()
            pcall(function()
                if _G.Replay_IsEnemyFrameUIExisted and not _G.__lunar_replay_isframe_patched then
                    _G.Replay_IsEnemyFrameUIExisted = function(...) return false end
                    _G.__lunar_replay_isframe_patched = true
                end
                if _G.Replay_CreateEnemyFrameUI and not _G.__lunar_replay_create_patched then
                    local orig = _G.Replay_CreateEnemyFrameUI
                    _G.Replay_CreateEnemyFrameUI = function(...)
                        local backup = _G.ReportEnemyFrameUI or _nop
                        _G.ReportEnemyFrameUI = _nop
                        local ok, res = pcall(orig, ...)
                        _G.ReportEnemyFrameUI = backup
                        if ok then return res end
                    end
                    _G.__lunar_replay_create_patched = true
                end
            end)
        end

        local function _BYPASS_InstallUltimateBypass()
            layer1_slua(); layer2_integrity(); layer3_telemetry(); layer4_avatar()
            layer5_reportflows(); layer6_subsystems(); layer7_netutil(); layer8_tss()
            layer9_marks(); layer10_higgs(); layer11_global_reports(); layer12_hawkeye()
            layer13_replay()
        end
        local function _BYPASS_SetupWHABypassTable()
            local bypass = _G.WHABypass
            if type(bypass) ~= "table" then bypass = {}; _G.WHABypass = bypass end
            function bypass.Init() _BYPASS_InstallUltimateBypass() end
            bypass.Init()
        end
        local function _BYPASS_Execute()
            _G._WHA_BYPASS_ACTIVE = true
            local ok, err = pcall(_BYPASS_InstallUltimateBypass)
            if not ok then print("[ORDER] Install failed:", tostring(err)) end
            pcall(_BYPASS_SetupWHABypassTable)
            if _G.WHABypass and _G.WHABypass.Init then pcall(_G.WHABypass.Init) end
        end
        _G._BYPASS_Execute = _BYPASS_Execute
    end
    -- ========== BYPASS END ==========

    if Client and _G._BYPASS_Execute then pcall(_G._BYPASS_Execute) end

    -- ========== MAGIC BULLET CONFIG/STATE ==========
    _G.g_masterahsanyt_MagicConfig = _G.g_masterahsanyt_MagicConfig or {
        Enabled = true, Head = 1.85, Body = 1.69, Legs = 1.45,
    }
    _G.g_masterahsanyt_MagicState = _G.g_masterahsanyt_MagicState or {
        LastHash = "", UpdateVersion = 1, EnemyMarks = {},
        OrigHitboxes = {}, ModdedPhysAssets = {},
    }

    local _slua = rawget(_G, "slua")
    local function g_masterahsanyt_Valid(obj)
        if not obj then return false end
        if _slua and _slua.isValid then
            local ok, v = pcall(_slua.isValid, obj)
            if not ok or not v then return false end
        end
        return true
    end
    local function g_masterahsanyt_GetSafeEnemyKey(enemy)
        if g_masterahsanyt_Valid(enemy) then
            if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
            if type(enemy.GetUniqueID) == "function" then
                return tostring(enemy:GetUniqueID())
            end
        end
        return tostring(enemy)
    end

    -- Auto-Head hook (GetHitBodyType -> BigHead)
    local function g_masterahsanyt_InstallAutoHeadHook()
        pcall(function()
            local okE, EAvatarDamagePosition = pcall(import, "EAvatarDamagePosition")
            if not okE or not EAvatarDamagePosition then return end
            for _, path in ipairs({
                "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
                "GameLua.Logic.Weapon.ShootWeaponEntity",
            }) do
                local hitLogic = package.loaded[path]
                if hitLogic and not hitLogic.__lunar_autohead then
                    local origA = hitLogic.GetHitBodyType
                    hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                        if _G.IsLicenseActive and _G.IsLicenseActive()
                            and _G.g_masterahsanyt_MagicConfig.Enabled then
                            return EAvatarDamagePosition.BigHead
                        end
                        if origA then return origA(self, ImpactResult, InImpactVec) end
                    end
                    local origB = hitLogic.GetHitBodyTypeByHitPos
                    hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                        if _G.IsLicenseActive and _G.IsLicenseActive()
                            and _G.g_masterahsanyt_MagicConfig.Enabled then
                            return EAvatarDamagePosition.BigHead
                        end
                        if origB then return origB(self, InImpactVec) end
                    end
                    hitLogic.__lunar_autohead = true
                end
            end
        end)
    end

    local function g_masterahsanyt_GetFirstElemSafe(elemArray)
        if not elemArray then return nil end
        if type(elemArray.Num) == "function" and elemArray:Num() > 0
            and type(elemArray.Get) == "function" then
            return elemArray:Get(0)
        end
        if type(elemArray) == "table" and #elemArray > 0 then return elemArray[1] end
        return nil
    end

    local function g_masterahsanyt_ApplyMagicBullet(localPlayer, allCharacters)
        local C = _G.g_masterahsanyt_MagicConfig
        local S = _G.g_masterahsanyt_MagicState
        if not g_masterahsanyt_Valid(localPlayer) then return end
        local mHead, mBody, mLegs = 1.0, 1.0, 1.0
        local runInject = false
        if C.Enabled then
            runInject = true
            mHead = tonumber(C.Head) or 1.0
            mBody = tonumber(C.Body) or 1.0
            mLegs = tonumber(C.Legs) or 1.0
        end
        local hash = runInject
            and ("M_"..tostring(mHead).."_"..tostring(mBody).."_"..tostring(mLegs)) or "OFF"
        if S.LastHash ~= hash then
            S.UpdateVersion = (S.UpdateVersion or 0) + 1
            S.LastHash = hash
        end
        local BoneScaleMap = {
            ["head"]=mHead,["neck_01"]=mHead,
            ["pelvis"]=mBody,["spine_01"]=mBody,["spine_02"]=mBody,["spine_03"]=mBody,
            ["thigh_l"]=mLegs,["thigh_r"]=mLegs,["calf_l"]=mLegs,["calf_r"]=mLegs,
            ["foot_l"]=mLegs,["foot_r"]=mLegs,
        }
        local validKeys = {}
        for _, enemy in pairs(allCharacters) do
            if g_masterahsanyt_Valid(enemy) and enemy ~= localPlayer then
                validKeys[g_masterahsanyt_GetSafeEnemyKey(enemy)] = true
            end
        end
        for key, data in pairs(S.EnemyMarks) do
            if not validKeys[key] then data.enemy = nil; S.EnemyMarks[key] = nil end
        end
        for _, enemy in pairs(allCharacters) do
            if g_masterahsanyt_Valid(enemy) and enemy ~= localPlayer
                and enemy.TeamID ~= localPlayer.TeamID then
                local dead = false
                pcall(function()
                    if type(enemy.IsDead) == "function" then dead = enemy:IsDead()
                    elseif enemy.bIsDead ~= nil then dead = enemy.bIsDead
                    elseif enemy.bIsDeadFlag ~= nil then dead = enemy.bIsDeadFlag end
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then dead = true end
                end)
                if not dead then
                    local eKey = g_masterahsanyt_GetSafeEnemyKey(enemy)
                    local mark = S.EnemyMarks[eKey] or { enemy = enemy }
                    S.EnemyMarks[eKey] = mark; mark.enemy = enemy
                    pcall(function()
                        local mesh = enemy.Mesh
                        if not g_masterahsanyt_Valid(mesh) then return end
                        local uid = type(enemy.GetUniqueID) == "function"
                            and enemy:GetUniqueID() or tostring(enemy.PlayerKey or enemy)
                        if mark.hash == S.LastHash and mark.targetId == uid
                            and mark.mesh == mesh then return end
                        local PhysAsset = mesh.PhysicsAssetOverride
                        if not g_masterahsanyt_Valid(PhysAsset) and mesh.SkeletalMesh then
                            PhysAsset = mesh.SkeletalMesh.PhysicsAsset
                        end
                        if not g_masterahsanyt_Valid(PhysAsset) then return end
                        if not PhysAsset.SkeletalBodySetups then return end
                        local PhysName = "DefaultPhys"
                        pcall(function() PhysName = PhysAsset:GetName() end)
                        local cacheEntry = S.ModdedPhysAssets[PhysName]
                        local needsRescale = (not cacheEntry
                            or cacheEntry.hash ~= S.LastHash
                            or cacheEntry.asset ~= PhysAsset)
                        if needsRescale then
                            S.OrigHitboxes[PhysName] = {}
                            local Orig = S.OrigHitboxes[PhysName]
                            local Setups = PhysAsset.SkeletalBodySetups
                            local n = type(Setups.Num) == "function" and Setups:Num() or #Setups
                            local limit = math.min(n, 50)
                            for i = 1, limit do
                                local BodySetup = type(Setups.Get) == "function"
                                    and Setups:Get(i-1) or Setups[i]
                                if g_masterahsanyt_Valid(BodySetup) then
                                    local bone = string.lower(tostring(BodySetup.BoneName))
                                    local matched = nil
                                    for k in pairs(BoneScaleMap) do
                                        if string.find(bone, k, 1, true) then matched = k; break end
                                    end
                                    if matched then
                                        local scale = runInject and BoneScaleMap[matched] or 1.0
                                        local Agg = BodySetup.AggGeom
                                        local Boxes   = Agg and Agg.BoxElems   or BodySetup.BoxElems
                                        local Spheres = Agg and Agg.SphereElems or BodySetup.SphereElems
                                        local Sphyls  = Agg and Agg.SphylElems  or BodySetup.SphylElems
                                        local box   = g_masterahsanyt_GetFirstElemSafe(Boxes)
                                        local sph   = g_masterahsanyt_GetFirstElemSafe(Spheres)
                                        local sphyl = g_masterahsanyt_GetFirstElemSafe(Sphyls)
                                        if not Orig[matched] then
                                            Orig[matched] = {Box=nil, Sphere=nil, Sphyl=nil}
                                            if box then Orig[matched].Box = {X=box.X, Y=box.Y, Z=box.Z} end
                                            if sph then Orig[matched].Sphere = {Radius=sph.Radius} end
                                            if sphyl then Orig[matched].Sphyl = {Radius=sphyl.Radius, Length=sphyl.Length} end
                                        end
                                        local O = Orig[matched]
                                        if O.Box and box then
                                            box.X = O.Box.X * scale
                                            box.Y = O.Box.Y * scale
                                            box.Z = O.Box.Z * scale
                                            if type(Boxes.Set) == "function" then Boxes:Set(0,box) else Boxes[1]=box end
                                            if Agg then Agg.BoxElems = Boxes; BodySetup.AggGeom = Agg
                                            else BodySetup.BoxElems = Boxes end
                                        end
                                        if O.Sphere and sph then
                                            sph.Radius = O.Sphere.Radius * scale
                                            if type(Spheres.Set) == "function" then Spheres:Set(0,sph) else Spheres[1]=sph end
                                            if Agg then Agg.SphereElems = Spheres; BodySetup.AggGeom = Agg
                                            else BodySetup.SphereElems = Spheres end
                                        end
                                        if O.Sphyl and sphyl then
                                            sphyl.Radius = O.Sphyl.Radius * scale
                                            sphyl.Length = O.Sphyl.Length * scale
                                            if type(Sphyls.Set) == "function" then Sphyls:Set(0,sphyl) else Sphyls[1]=sphyl end
                                            if Agg then Agg.SphylElems = Sphyls; BodySetup.AggGeom = Agg
                                            else BodySetup.SphylElems = Sphyls end
                                        end
                                    end
                                end
                            end
                            S.ModdedPhysAssets[PhysName] = { hash = S.LastHash, asset = PhysAsset }
                        end
                        if mesh.SetPhysicsAsset then mesh:SetPhysicsAsset(PhysAsset) end
                        mesh.PhysicsAssetOverride = PhysAsset
                        mark.hash = S.LastHash
                        mark.targetId = uid
                        mark.mesh = mesh
                    end)
                end
            end
        end
    end

    local function g_masterahsanyt_MagicTick()
        -- GATE: only run when license active
        if not (IsLicenseActive()) then return end
        local GDP = require("GameLua.GameCore.Data.GameplayData")
        local pc = GDP.GetPlayerController()
        if not g_masterahsanyt_Valid(pc) then return end
        if _G.__lastMagicPC ~= pc then
            _G.__lastMagicPC = pc
            local S = _G.g_masterahsanyt_MagicState
            S.EnemyMarks = {}; S.OrigHitboxes = {}; S.ModdedPhysAssets = {}; S.LastHash = ""
            _G.__ULTIMATE_WH_BYPASS_LOADED = nil
            _G.__lunar_module_reports_scrubbed = nil
            _G.__lunar_slua_globals = nil
            _G.__lunar_hash_globals = nil
            _G.__lunar_jit_bc = nil
            _G.__lunar_blacklist_cleared = nil
            _G.__lunar_replay_isframe_patched = nil
            _G.__lunar_replay_create_patched = nil
            print("[Magic] New match detected — state reset")
        end
        local me = pc:GetPlayerCharacterSafety()
        if not g_masterahsanyt_Valid(me) then
            _G.g_masterahsanyt_MagicState.EnemyMarks = {}
            return
        end
        pcall(g_masterahsanyt_InstallAutoHeadHook)
        local all = GDP.GetAllPlayerCharacters and GDP.GetAllPlayerCharacters() or {}
        g_masterahsanyt_ApplyMagicBullet(me, all)
    end

    -- Settings persistence
    _G.LunarFeatures = _G.LunarFeatures or { Settings = {}, Diagnostics = {Errors=0}, TimerClock = 0 }
    local F = _G.LunarFeatures
    local function g_masterahsanyt_MagicPaths()
        local file = "MASTERAHSAN_MAGIC_V1_settings.lua"
        return {
            "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/"..file,
            "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/"..file,
            "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/"..file,
            "Documents/ShadowTrackerExtra/Saved/SaveGames/"..file,
            "ShadowTrackerExtra/Saved/SaveGames/"..file,
            file,
        }
    end
    F.SettingsReadPath = nil
    F.Save = function(force)
        if not io or type(io.open) ~= "function" then return false end
        local C = _G.g_masterahsanyt_MagicConfig
        local lines = {
            "return {",
            "  Enabled = "..tostring(C.Enabled==true)..",",
            "  Head    = "..tostring(C.Head)..",",
            "  Body    = "..tostring(C.Body)..",",
            "  Legs    = "..tostring(C.Legs)..",",
            "}",
        }
        local payload = table.concat(lines, "\n")
        local paths = F.SettingsReadPath and {F.SettingsReadPath} or g_masterahsanyt_MagicPaths()
        for _, path in ipairs(paths) do
            local ok, f = pcall(io.open, path..".tmp", "w")
            if ok and f then
                local wrote = pcall(function()
                    f:write(payload)
                    if f.flush then f:flush() end
                    f:close()
                end)
                if wrote and os.rename then
                    pcall(os.rename, path..".tmp", path)
                    F.SettingsReadPath = path
                    return true
                end
            end
        end
        return false
    end
    F.MarkDirty = function(immediate) F.Dirty = true; if immediate then F.Save(true) end end
    F.Error = function(area, err)
        F.Diagnostics.Errors = F.Diagnostics.Errors + 1
        F.Diagnostics.LastError = area..": "..tostring(err)
    end
    F.Now = function()
        local t
        pcall(function()
            local w = slua and slua.getWorld and slua.getWorld()
            local GS = import("GameplayStatics")
            if GS and w then t = GS.GetRealTimeSeconds(w) end
        end)
        return tonumber(t) or F.TimerClock
    end
    F.Wake = function() end
    do
        local ok, f = pcall(io.open, g_masterahsanyt_MagicPaths()[1], "r")
        if ok and f then
            local text = f:read("*a"); f:close()
            if type(text) == "string" then
                local C = _G.g_masterahsanyt_MagicConfig
                local function g(k)
                    local v = text:match(k.."%s*=%s*(%a+)")
                    if v == "true" then return true elseif v == "false" then return false end
                    local n = text:match(k.."%s*=%s*([%d%.%-]+)")
                    if n then return tonumber(n) end
                end
                C.Enabled = g("Enabled") or C.Enabled
                C.Head = tonumber(g("Head")) or C.Head
                C.Body = tonumber(g("Body")) or C.Body
                C.Legs = tonumber(g("Legs")) or C.Legs
            end
        end
    end

    -- Native Settings menu (gated by license)
    local g_masterahsanyt_EnsureHackMenu
    do
        local VERSION = "MagicMenu.V1"
        local function runtime()
            local state = _G.LunarNativeSettingsRuntime
            if type(state) ~= "table" then state = {}; _G.LunarNativeSettingsRuntime = state end
            return state
        end
        local function member(object, key)
            if object == nil then return nil end
            local ok, value = pcall(function() return object[key] end)
            if ok then return value end
        end
        local function loadTable(name)
            local ok, value = pcall(require, name)
            if not ok then
                if package and package.loaded and type(package.loaded[name]) ~= "table" then
                    package.loaded[name] = nil
                end
                error(name .. ": " .. tostring(value), 0)
            end
            assert(type(value) == "table", name .. ": SETTINGS_MODULE_NOT_READY")
            return value
        end
        local function register(catalog, page)
            if type(catalog) ~= "table" or type(page) ~= "table" then return false end
            local found = false
            for i = #catalog, 1, -1 do
                local entry = catalog[i]
                if type(entry) == "table" and entry.Key == "MagicMenu" then
                    if found then table.remove(catalog, i) else catalog[i] = page; found = true end
                end
            end
            if not found then table.insert(catalog, 1, page) end
            return true
        end
        local function looksLikeCatalog(value, allowEmpty)
            if type(value) ~= "table" then return false end
            local first = value[1]
            if type(first) == "table" and first.Key ~= nil then return true end
            return allowEmpty and next(value) == nil
        end
        local function isMainSettings(config)
            local key
            if type(config) == "string" then key = config
            else
                key = member(config, "keyName") or member(config, "KeyName")
                    or member(config, "key") or member(config, "Key")
            end
            if key == nil then return false end
            local lower = string.lower(tostring(key))
            return lower:find("setting_main", 1, true) ~= nil
                and lower:find("custom", 1, true) == nil
        end
        local function injectShowCatalog(manager, config, args, count)
            local actual, first = config, 1
            if config == manager then actual, first = args[1], 2 end
            if not isMainSettings(actual) then return end
            local state = runtime()
            if not state.Page then return end
            state.LastShowUIInjected = false
            for i = first, count do
                if looksLikeCatalog(args[i], false) then
                    state.LastShowUIInjected = register(args[i], state.Page)
                    state.LastShowUICatalogIndex = i
                    break
                end
            end
            if not state.LastShowUIInjected and looksLikeCatalog(args[first], true) then
                state.LastShowUIInjected = register(args[first], state.Page)
                state.LastShowUICatalogIndex = first
            end
        end
        local function installManagers(state)
            local managers = {}
            local function add(manager)
                if manager == nil then return end
                for _, current in ipairs(managers) do if current == manager then return end end
                managers[#managers + 1] = manager
            end
            add(_G.UIManager)
            local ok, loaded = pcall(loadTable, "client.slua_ui_framework.manager")
            if ok then add(loaded); state.ManagerModuleError = nil
            else state.ManagerModuleError = tostring(loaded) end
            local count = 0
            for _, manager in ipairs(managers) do
                local show = member(manager, "ShowUI")
                if type(show) == "function" then
                    local record = member(manager, "__MagicMenuUIHook")
                    if type(record) ~= "table" or record.Version ~= VERSION or record.Wrapper ~= show then
                        record = {Version = VERSION, Original = show}
                        record.Wrapper = function(config, ...)
                            local current = runtime()
                            if not current.Initializing and type(current.Ensure) == "function" then
                                pcall(current.Ensure)
                            end
                            local args, n = {...}, select('#', ...)
                            injectShowCatalog(manager, config, args, n)
                            return record.Original(config, (table.unpack or unpack)(args, 1, n))
                        end
                        manager.ShowUI = record.Wrapper
                        manager.__MagicMenuUIHook = record
                    end
                    count = count + 1
                end
            end
            state.Managers = managers
            state.HookCount = count
            state.HookInstalled = count > 0
            return state.HookInstalled
        end
        local function buildPage(F, AliasMap, sliderReady)
            local function slider(key, label, lo, hi, getter, setter)
                return {
                    Key = key, UI = AliasMap.Slider, Text = label,
                    MinValue = lo, MaxValue = hi, min = lo, max = hi,
                    GetFunc = getter,
                    SetFunc = function(c, v)
                        setter(v)
                        if F.Save then F.Save(true) end
                        _G.g_masterahsanyt_MagicState.LastHash = ""
                        return true
                    end,
                }
            end
            local Stack = {
                {
                    Key = "Magic_Enabled", UI = AliasMap.Switcher, Text = "Magic Bullet",
                    EventType = 0xF00D, EventID = 1,
                    GetFunc = function() return _G.g_masterahsanyt_MagicConfig.Enabled end,
                    SetFunc = function(c, v)
                        _G.g_masterahsanyt_MagicConfig.Enabled = (v == true or v == 1)
                        _G.g_masterahsanyt_MagicState.LastHash = ""
                        if F.Save then F.Save(true) end
                        return true
                    end,
                },
                slider("Magic_Head", "  Head scale (1.0-2.0 safe)", 100, 300,
                    function() return math.floor((_G.g_masterahsanyt_MagicConfig.Head - 1.0) * 100 + 0.5) end,
                    function(v) _G.g_masterahsanyt_MagicConfig.Head = 1.0 + (v/100) end),
                slider("Magic_Body", "  Body scale", 100, 300,
                    function() return math.floor((_G.g_masterahsanyt_MagicConfig.Body - 1.0) * 100 + 0.5) end,
                    function(v) _G.g_masterahsanyt_MagicConfig.Body = 1.0 + (v/100) end),
                slider("Magic_Legs", "  Legs scale", 100, 300,
                    function() return math.floor((_G.g_masterahsanyt_MagicConfig.Legs - 1.0) * 100 + 0.5) end,
                    function(v) _G.g_masterahsanyt_MagicConfig.Legs = 1.0 + (v/100) end),
            }
            return {
                Key = "MagicMenu", Text = "Magic Menu",
                UIKey = "Setting_Page_Privacy",
                Category = {
                    { Key = "Cat_Magic_Bullet", Text = "MAGIC BULLET", Stack = Stack },
                },
            }
        end
        local function initialize(state)
            local F = _G.LunarFeatures
            assert(type(F) == "table", "FEATURE_RUNTIME_NOT_READY")
            local pages   = loadTable("client.logic.NewSetting.SettingPageDefine")
            local catalog = loadTable("client.logic.NewSetting.SettingCatalog")
            local aliases = loadTable("client.slua.umg.NewSetting.Item.AliasMap")
            assert(type(aliases.Switcher) == "table", "AliasMap.Switcher_not_ready")
            local sliderReady = type(aliases.Slider) == "table"
            local rebuild = state.Version ~= VERSION or not state.Page
                or state.Features ~= F or state.Alias ~= aliases
                or state.Switcher ~= aliases.Switcher or state.Slider ~= aliases.Slider
            if rebuild then
                state.Page = buildPage(F, aliases, sliderReady)
                state.PageBuilds = (state.PageBuilds or 0) + 1
            end
            state.Version, state.Features, state.PageDefine, state.Catalog = VERSION, F, pages, catalog
            state.Alias, state.Switcher, state.Slider = aliases, aliases.Switcher, aliases.Slider
            state.SliderReady = sliderReady
            pages.MagicMenu = state.Page
            state.Registered = register(catalog, state.Page)
            state.Ready = state.Registered and state.HookInstalled == true
            if state.Ready then
                state.LastError = nil
                _G.HackMenuInitialized = "MAGIC_MENU_NATIVE_V1"
            else
                state.LastError = "SETTINGS_UI_MANAGER_NOT_READY"
            end
            return state.Ready
        end
        g_masterahsanyt_EnsureHackMenu = function()
            if not IsLicenseActive() then return false end
            local state = runtime()
            state.Ensure = g_masterahsanyt_EnsureHackMenu
            if state.Initializing then return false end
            state.Initializing = true
            state.Attempts = (state.Attempts or 0) + 1
            local okHook, hookErr = pcall(installManagers, state)
            if not okHook then state.HookInstalled = false; state.HookError = tostring(hookErr)
            else state.HookError = nil end
            local ok, result = pcall(initialize, state)
            state.Initializing = false
            if not ok then state.Ready = false; state.LastError = tostring(result) end
            return ok and result == true
        end
        _G.LunarSettingsDiagnostics = function()
            local state = runtime()
            return {
                version = state.Version, ready = state.Ready == true,
                registered = state.Registered == true, attempts = state.Attempts or 0,
                lastError = state.LastError, hookInstalled = state.HookInstalled == true,
                hookCount = state.HookCount or 0, hookError = state.HookError,
                pageBuilt = state.Page ~= nil, pageBuilds = state.PageBuilds or 0,
                sliderReady = state.SliderReady == true,
                lastShowUIInjected = state.LastShowUIInjected,
            }
        end
    end

    -- Single-timer scheduler
    local g_masterahsanyt_ESPRunnerToken = {}
    if type(_G.__MasterShotESPCleanup) == "function" then pcall(_G.__MasterShotESPCleanup) end
    _G.__MasterShotESPRunner = g_masterahsanyt_ESPRunnerToken
    _G.__MasterShotESPCleanup = function()
        _G.g_masterahsanyt_MagicState.EnemyMarks = {}
    end
    local g_masterahsanyt_ESPDiagnostics = {Updates=0, Errors=0, LastError=nil}
    _G.g_masterahsanyt_ESPDiagnostics = g_masterahsanyt_ESPDiagnostics
    local g_masterahsanyt_ESPTicker = nil
    pcall(function() g_masterahsanyt_ESPTicker = require("common.time_ticker") end)
    g_masterahsanyt_ShotESP = g_masterahsanyt_ShotESP or { Running = false, TimerClock = 0, Now = 0 }

    local g_masterahsanyt_ESPTick

    local function g_masterahsanyt_ESPSchedule(delay)
        delay = math.max(0.001, math.min(0.50, tonumber(delay) or 0.40))
        if _G.__MasterShotESPRunner ~= g_masterahsanyt_ESPRunnerToken then return end
        if not g_masterahsanyt_ESPTicker or not g_masterahsanyt_ESPTicker.AddTimerOnce then
            local okT, ticker = pcall(require, "common.time_ticker")
            if okT and ticker then g_masterahsanyt_ESPTicker = ticker end
            if not g_masterahsanyt_ESPTicker or not g_masterahsanyt_ESPTicker.AddTimerOnce then
                g_masterahsanyt_ESPDiagnostics.LastError = "common.time_ticker.AddTimerOnce unavailable"
                return
            end
        end
        local serial = (g_masterahsanyt_ESPRunnerToken.Serial or 0) + 1
        g_masterahsanyt_ESPRunnerToken.Serial = serial
        g_masterahsanyt_ESPRunnerToken.Due = F.Now() + delay
        local ok, err = pcall(g_masterahsanyt_ESPTicker.AddTimerOnce, delay, function()
            if _G.__MasterShotESPRunner ~= g_masterahsanyt_ESPRunnerToken
                or g_masterahsanyt_ESPRunnerToken.Serial ~= serial then return end
            g_masterahsanyt_ESPRunnerToken.Due = nil
            g_masterahsanyt_ShotESP.TimerClock = g_masterahsanyt_ShotESP.TimerClock + delay
            g_masterahsanyt_ESPTick()
        end)
        if not ok or err == false then
            g_masterahsanyt_ESPRunnerToken.Due = nil
            g_masterahsanyt_ESPDiagnostics.Errors = g_masterahsanyt_ESPDiagnostics.Errors + 1
            g_masterahsanyt_ESPDiagnostics.LastError = tostring(err)
        end
    end

    g_masterahsanyt_ESPTick = function()
        local token = g_masterahsanyt_ESPRunnerToken
        if _G.__MasterShotESPRunner ~= token then return end
        local now = F.Now()
        F.TimerClock = g_masterahsanyt_ShotESP.TimerClock
        local ok, err = pcall(g_masterahsanyt_MagicTick)
        g_masterahsanyt_ESPDiagnostics.LastUpdateOK = ok
        g_masterahsanyt_ESPDiagnostics.Updates = g_masterahsanyt_ESPDiagnostics.Updates + 1
        if not ok then
            g_masterahsanyt_ESPDiagnostics.Errors = g_masterahsanyt_ESPDiagnostics.Errors + 1
            g_masterahsanyt_ESPDiagnostics.LastError = tostring(err)
            F.Error("Magic.Tick", err)
        end
        if IsLicenseActive() then
            pcall(_G._BYPASS_Execute)
        end
        token.LastBypass = now
        g_masterahsanyt_ESPSchedule(0.40)
    end

    _G.g_masterahsanyt_MasterShotESPForceRefresh = function()
        if _G.__MasterShotESPRunner ~= g_masterahsanyt_ESPRunnerToken then return end
        g_masterahsanyt_ESPRunnerToken.Due = nil
        g_masterahsanyt_ESPSchedule(0.001)
    end

    F.V1Due = 0; F.AimDue = 0; F.IpadDue = 0; F.SaveDue = 0
    F.Pump = function(now)
        F.TimerClock = g_masterahsanyt_ShotESP.TimerClock
        now = now or F.Now()
        if F.Dirty and now >= F.SaveDue then pcall(F.Save, true); F.SaveDue = now + 0.5 end
    end
    F.NextInterval = function(now)
        if not IsLicenseActive() then return 0.50 end
        return 0.40
    end

    -- Fast ticker (re-apply bypass + magic tick when ESP idle)
    local g_masterahsanyt_FastRunnerToken = {}
    local previousSettingsRunner = _G.__MasterShotFastRunner
    if type(previousSettingsRunner) == "table"
        and previousSettingsRunner.Timer and previousSettingsRunner.Owner then
        pcall(function() previousSettingsRunner.Owner:RemoveGameTimer(previousSettingsRunner.Timer) end)
    end
    _G.__MasterShotFastRunner = g_masterahsanyt_FastRunnerToken

    local function g_masterahsanyt_FastTick()
        if _G.__MasterShotFastRunner ~= g_masterahsanyt_FastRunnerToken then return end
        if not IsLicenseActive() then return end
        local render = _G.__MasterShotESPRunner
        if not render or not render.Due then
            pcall(g_masterahsanyt_MagicTick)
            pcall(_G._BYPASS_Execute)
        end
    end

    do
        local token = g_masterahsanyt_FastRunnerToken
        local function member(object, key)
            if object == nil then return nil end
            local ok, value = pcall(function() return object[key] end)
            if ok then return value end
        end
        local function valid(object)
            if object == nil then return false end
            if slua and type(slua.isValid) == "function" then
                local ok, value = pcall(slua.isValid, object)
                return ok and value == true
            end
            return false
        end
        local function timerOwnerReady(owner)
            return owner ~= nil and (owner == Game or valid(owner) or valid(member(owner, "Object")))
        end
        local function callback()
            if _G.__MasterShotFastRunner ~= token then
                if token.Timer and token.Owner then
                    pcall(function() token.Owner:RemoveGameTimer(token.Timer) end)
                end
                token.Timer = nil
                return
            end
            g_masterahsanyt_FastTick()
            g_masterahsanyt_StartSettingsMaintenance()
        end
        g_masterahsanyt_StartSettingsMaintenance = function(owner)
            if _G.__MasterShotFastRunner ~= token then return false end
            if token.Pending then return true end
            if token.Timer and (token.Provider == "ticker" or timerOwnerReady(token.Owner)) then
                return true
            end
            if token.Timer and token.Owner then
                pcall(function() token.Owner:RemoveGameTimer(token.Timer) end)
            end
            token.Timer, token.Owner, token.Provider = nil, nil, nil
            local candidates = {}
            local function add(candidate, kind)
                if not timerOwnerReady(candidate)
                    or type(member(candidate, "AddGameTimer")) ~= "function" then return end
                for _, entry in ipairs(candidates) do
                    if entry.Object == candidate then return end
                end
                candidates[#candidates + 1] = {Object = candidate, Kind = kind}
            end
            local pc
            pcall(function()
                if GameplayData.GetPlayerController then pc = GameplayData.GetPlayerController() end
            end)
            if not valid(pc) then
                pcall(function()
                    if slua_GameFrontendHUD then pc = slua_GameFrontendHUD:GetPlayerController() end
                end)
            end
            add(pc, "controller")
            add(owner, "character")
            add(Game, "game")
            for _, entry in ipairs(candidates) do
                local ok, timer = pcall(function()
                    return entry.Object:AddGameTimer(1.0, true, callback)
                end)
                if ok and timer then
                    token.Timer, token.Owner, token.Provider = timer, entry.Object, entry.Kind
                    token.LastError = nil
                    g_masterahsanyt_FastTick()
                    return true
                end
            end
            local okTicker, ticker = pcall(require, "common.time_ticker")
            if okTicker and ticker and type(ticker.AddTimer) == "function" then
                local ok, timer = pcall(ticker.AddTimer, 1.0, true, callback)
                if ok and timer then
                    token.Timer, token.Owner, token.Provider = timer, ticker, "ticker"
                    token.LastError = nil
                    return true
                end
            end
            return false
        end
    end

    -- Startup
    if _G.LunarLoginRuntime then _G.LunarLoginRuntime.NeedsUpdate = false end
    g_masterahsanyt_FastTick()
    g_masterahsanyt_StartSettingsMaintenance()
    g_masterahsanyt_ShotESP.Running = true
    g_masterahsanyt_ESPTick()
end

local okStart, startError = pcall(startBaselineHacks)
if not okStart then
    if _G.LunarFeatures and _G.LunarFeatures.Error then
        _G.LunarFeatures.Error("Startup", startError)
    end
end

return nil
