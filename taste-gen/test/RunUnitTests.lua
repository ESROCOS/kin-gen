function actual_folder_name()
    return "../out"
end

function expected_folder_name()
    return "expected"
end

local function read_file_content(path, filename)
    local file = io.open(path..filename,'r')
    local data = file:read("*all")
    file:close()
    return data
end

local function preprocess(line_text)
    line_text = line_text:match( "^%s*(.-)%s*$" )
    return line_text
end


local function compare_files_content(path, filename)
    local expected_file = io.open(expected_folder_name().."/"..path..filename,'r')
    local actual_file = io.open(actual_folder_name().."/"..path..filename,'r')

    local expected_line = expected_file:read()
    local actual_line = actual_file:read()
    local line = 1
    local mismatch = false
    repeat
        local actual_line_preprocessed = preprocess(actual_line)
        local expected_line_preprocessed = preprocess(expected_line)
        if actual_line_preprocessed ~= expected_line_preprocessed then
            mismatch = true
            break
        end
        expected_line = expected_file:read()
        actual_line = actual_file:read()
        line = line + 1
    until expected_line == nil or actual_line == nil

    expected_file:close()
    actual_file:close()
    return mismatch, line, actual_line, expected_line
end

local function read_file_contents(path, filename)
    local expected = read_file_content(expected_folder_name().."/"..path, filename)
    local actual = read_file_content(actual_folder_name().."/"..path, filename)
    return actual, expected
end

local function test_file(path, filename)
    local actual, expected = read_file_contents(path, filename)
    return actual == expected
end

local function file_exists(path, filename)
    local file = io.open(actual_folder_name().."/"..path..filename,'r')
    if file == nil then return false end
    file:close()
    return true
end

files = {}
--files["kinblock.h"] = {"kinblock/"}
--files["kinblock.cc"] = {"kinblock/" }
files["kinblock-bridge.h"] = { "kinblock/", "kinblock/rmtool/" }
files["kinblock-bridge.cc"] = {"kinblock/rmtool/" }
files["Makefile"] = {"kinblock/rmtool/" }
files["user_init_pre.sh"] = {""}

print("=== COMPARISON TESTS ===\n")
for file, paths in pairs(files) do
    for idx,path in pairs(paths) do
        local result = ""
        if file_exists(path, file) then
            local mismatch, line, actual_line, expected_line = compare_files_content(path, file)
            if not mismatch then
                result = "OK!"
            else
                result = "Mismatch on line "..line.."\nACTUAL:   "..actual_line.."\nEXPECTED: "..expected_line
            end
        else
            result = "FILE DOES NOT EXIST!"
        end
        print(path..file..": "..result.."\n")
    end
end
