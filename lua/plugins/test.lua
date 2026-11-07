-- ============================================================================
-- TEST RUNNER (LANGUAGE ORCHESTRATOR)
-- ============================================================================

local language_registry = require("languages")
local task_runner = require("plugins.tasks")

local function project_root(path)
	return task_runner.project_root(path)
end

local neotest_ready = false

local function configured_neotest()
	if neotest_ready then
		return require("neotest")
	end
	neotest_ready = true

	local adapters = {}
	for _, contribution in ipairs(language_registry.collect("test")) do
		local test_contribution = contribution.value
		if type(test_contribution.adapters) == "function" then
			local ok, items = pcall(test_contribution.adapters, {
				project_root = project_root,
				language = contribution.language,
			})
			if ok and type(items) == "table" then
				vim.list_extend(adapters, items)
			end
		end
	end

	require("neotest").setup({
		adapters = adapters,
		quickfix = {
			enabled = true,
			open = false,
		},
		output_panel = {
			enabled = true,
			open = "botright split | resize 14",
		},
		summary = {
			enabled = true,
			follow = true,
			open = "botright vsplit | vertical resize 48",
		},
		status = {
			virtual_text = true,
		},
	})

	return require("neotest")
end

local function dispatch_language_test(method)
	local filetype = vim.bo.filetype
	local language = language_registry.find_for_filetype(filetype)
	if not language or not language.test then
		return false
	end

	local callback = language.test[method]
	if type(callback) ~= "function" then
		return false
	end

	local ok, handled = pcall(callback, {
		neotest = configured_neotest(),
		project_root = project_root,
		language = language,
	})

	return ok and handled == true
end

vim.keymap.set("n", "<leader>tn", function()
	if dispatch_language_test("run_nearest") then
		return
	end
	configured_neotest().run.run()
end, { desc = "Test nearest" })
vim.keymap.set("n", "<leader>tf", function()
	configured_neotest().run.run(vim.fn.expand("%"))
end, { desc = "Test file" })
vim.keymap.set("n", "<leader>ta", function()
	configured_neotest().run.run(project_root())
end, { desc = "Test project" })
vim.keymap.set("n", "<leader>tv", function()
	configured_neotest().run.run({ strategy = "dap" })
end, { desc = "Test nearest (debug)" })
vim.keymap.set("n", "<leader>tl", function()
	configured_neotest().run.run_last()
end, { desc = "Test run last" })
vim.keymap.set("n", "<leader>ts", function()
	configured_neotest().summary.toggle()
end, { desc = "Test summary toggle" })
vim.keymap.set("n", "<leader>to", function()
	configured_neotest().output.open({ enter = true })
end, { desc = "Test output open" })
vim.keymap.set("n", "<leader>tO", function()
	configured_neotest().output_panel.toggle()
end, { desc = "Test output panel toggle" })

vim.keymap.set("n", "<leader>jt", function()
	if dispatch_language_test("run_nearest") then
		return
	end
	configured_neotest().run.run()
end, { desc = "IDE test nearest" })

return { neotest = configured_neotest }
