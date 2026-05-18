-- This script originally comes from https://github.com/mrcjkb/lua-typecheck-action (2026-05-14).
-- I modified its `os.execute` call, which incorrectly user return values.

---@class Args
---@field checklevel string The diagnostics level to fail at
---@field configpath string? Path to the luarc.json

local function getenv_or_err(env_var)
	return assert(os.getenv(env_var), env_var .. " not set.")
end

local workdir = os.getenv("GITHUB_WORKSPACE") or "."

local config_path_input = getenv_or_err("INPUT_CONFIGPATH")

---@type Args
local args = {
	checklevel = getenv_or_err("INPUT_CHECKLEVEL"),
	configpath = (
		config_path_input ~= "" and '"' .. workdir .. "/" .. config_path_input .. '"' or nil
	),
}

---@param filename string
---@return string? content
local function read_file(filename)
	local content
	local f = io.open(filename, "r")
	if f then
		content = f:read("*a")
		f:close()
	end
	return content
end

---@class LintResult
---@field success boolean
---@field directory string
---@field diagnostics string?

---@param directory string
---@return LintResult
local function lint(directory)
	local result = {
		directory = directory,
	}
	local stdout_file = "stdout.txt"
	local stderr_file = "stderr.txt"
	local cmd = "lua-language-server --check_format=pretty"
		.. (" --check " .. directory)
		.. (args.configpath and " --configpath=" .. args.configpath or "")
		.. " --checklevel="
		.. args.checklevel
	local redirect = " >" .. stdout_file .. " 2>" .. stderr_file
	print(cmd .. redirect)
	local success = os.execute(cmd .. redirect)
	local stdout = read_file(stdout_file) or ""
	if not success then
		local stderr = read_file(stderr_file) or ""
		result.success = false
		result.diagnostics = stdout .. "\n\n" .. stderr
		return result
	end
	result.success = true
	os.execute("rm -f " .. stdout_file .. " " .. stderr_file)
	return result
end

local success = true
local result = lint('"' .. workdir .. '"')
if not result.success then
	print("Diagnostics for directory " .. result.directory .. ":")
	print(result.diagnostics)
	success = false
end
if not success then
	error("LINT FAILED!")
end
