local client_communication_path = nil

local function get_client_communication_path()
    if client_communication_path ~= nil then
        return client_communication_path
    end
    local local_app_data = os.getenv("LOCALAPPDATA")
    if local_app_data ~= nil then
        client_communication_path = local_app_data .. "\\KHRECOM\\"
        return client_communication_path
    end
    client_communication_path = os.getenv("HOME") .. "/KHRECOM/"
    local exists, _, error_code = os.rename(client_communication_path, client_communication_path)
    if not exists and error_code ~= 13 then
        os.execute("mkdir \"" .. client_communication_path .. "\"")
    end
    return client_communication_path
end

local function get_client_file_path(file_name)
    return get_client_communication_path() .. file_name
end

local function client_file_exists(file_name)
    local file = io.open(get_client_file_path(file_name), "r")
    if file == nil then
        return false
    end
    file:close()
    return true
end

local function read_client_file_line(file_name)
    local file = io.open(get_client_file_path(file_name), "r")
    if file == nil then
        return nil
    end
    local line = file:read("*l")
    file:close()
    return line
end

local function read_client_file_number(file_name)
    local line = read_client_file_line(file_name)
    if line == nil then
        return nil
    end
    return tonumber(line)
end

local function read_client_file_text(file_name)
    local file = io.open(get_client_file_path(file_name), "r")
    if file == nil then
        return nil
    end
    local text = file:read("*a")
    file:close()
    return text
end

local function split_numbers(text, separator)
    local numbers = {}
    for piece in string.gmatch(text, "([^" .. separator .. "]+)") do
        local number = tonumber(piece)
        if number ~= nil then
            numbers[#numbers + 1] = number
        end
    end
    return numbers
end

local function create_client_file_if_missing(file_name)
    if client_file_exists(file_name) then
        return
    end
    local file = io.open(get_client_file_path(file_name), "w")
    if file == nil then
        return
    end
    file:write("")
    file:close()
end

local function send_location(location_id)
    create_client_file_if_missing("send" .. tostring(location_id))
end

return {
    get_client_communication_path = get_client_communication_path,
    client_file_exists = client_file_exists,
    read_client_file_line = read_client_file_line,
    read_client_file_number = read_client_file_number,
    read_client_file_text = read_client_file_text,
    split_numbers = split_numbers,
    create_client_file_if_missing = create_client_file_if_missing,
    send_location = send_location
}
