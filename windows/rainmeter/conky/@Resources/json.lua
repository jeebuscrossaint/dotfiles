-- Minimal JSON decoder for the weather panel. Rainmeter's Lua is 5.1 with no
-- libraries, and WebParser's regex is the wrong tool for a nested document.
-- null decodes to nil; that is what weather.jq's `// empty` relied on too.

local json = {}

local function err(s, i, what) error(("json: %s at %d near %q"):format(what, i, s:sub(i, i + 10))) end

local function ws(s, i)
    local _, e = s:find("^[ \t\r\n]*", i)
    return e + 1
end

local esc = { ['"'] = '"', ['\\'] = '\\', ['/'] = '/', b = '\b', f = '\f', n = '\n', r = '\r', t = '\t' }

local function utf8(cp)
    if cp < 0x80 then return string.char(cp) end
    if cp < 0x800 then return string.char(0xC0 + math.floor(cp / 0x40), 0x80 + cp % 0x40) end
    if cp < 0x10000 then
        return string.char(0xE0 + math.floor(cp / 0x1000), 0x80 + math.floor(cp / 0x40) % 0x40, 0x80 + cp % 0x40)
    end
    return string.char(0xF0 + math.floor(cp / 0x40000), 0x80 + math.floor(cp / 0x1000) % 0x40,
        0x80 + math.floor(cp / 0x40) % 0x40, 0x80 + cp % 0x40)
end

local value

local function str(s, i)
    local out, j = {}, i + 1
    while true do
        local c = s:sub(j, j)
        if c == "" then err(s, i, "unterminated string") end
        if c == '"' then return table.concat(out), j + 1 end
        if c == "\\" then
            local n = s:sub(j + 1, j + 1)
            if n == "u" then
                local cp = tonumber(s:sub(j + 2, j + 5), 16) or 63
                j = j + 6
                -- Surrogate pair.
                if cp >= 0xD800 and cp <= 0xDBFF and s:sub(j, j + 1) == "\\u" then
                    local lo = tonumber(s:sub(j + 2, j + 5), 16) or 0
                    cp = 0x10000 + (cp - 0xD800) * 0x400 + (lo - 0xDC00)
                    j = j + 6
                end
                out[#out + 1] = utf8(cp)
            else
                out[#out + 1] = esc[n] or n
                j = j + 2
            end
        else
            local k = s:find('["\\]', j)
            if not k then err(s, i, "unterminated string") end
            out[#out + 1] = s:sub(j, k - 1)
            j = k
        end
    end
end

value = function(s, i)
    i = ws(s, i)
    local c = s:sub(i, i)
    if c == "{" then
        local t = {}
        i = ws(s, i + 1)
        if s:sub(i, i) == "}" then return t, i + 1 end
        while true do
            local k
            k, i = str(s, ws(s, i))
            i = ws(s, i)
            if s:sub(i, i) ~= ":" then err(s, i, "expected ':'") end
            t[k], i = value(s, i + 1)
            i = ws(s, i)
            local d = s:sub(i, i)
            if d == "}" then return t, i + 1 end
            if d ~= "," then err(s, i, "expected ',' or '}'") end
            i = i + 1
        end
    elseif c == "[" then
        local t, n = {}, 0
        i = ws(s, i + 1)
        if s:sub(i, i) == "]" then return t, i + 1 end
        while true do
            n = n + 1
            t[n], i = value(s, i)
            i = ws(s, i)
            local d = s:sub(i, i)
            if d == "]" then t.n = n; return t, i + 1 end
            if d ~= "," then err(s, i, "expected ',' or ']'") end
            i = i + 1
        end
    elseif c == '"' then
        return str(s, i)
    elseif s:find("^true", i) then return true, i + 4
    elseif s:find("^false", i) then return false, i + 5
    elseif s:find("^null", i) then return nil, i + 4
    else
        local num = s:match("^-?%d+%.?%d*[eE]?[-+]?%d*", i)
        if not num or num == "" then err(s, i, "unexpected character") end
        return tonumber(num), i + #num
    end
end

function json.decode(s)
    if type(s) ~= "string" or s == "" then return nil end
    local ok, v = pcall(value, s, 1)
    if ok then return v end
    return nil, v
end

return json
