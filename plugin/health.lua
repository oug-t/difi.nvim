local M = {}

function M.check()
    vim.health.start("difi.nvim report")

    if vim.fn.executable("difi") == 1 then
        vim.health.ok("difi binary found")

        local handle = io.popen("difi --version")
        local result = handle:read("*a")
        handle:close()

        if result and result ~= "" then
            vim.health.info("Version: " .. result:gsub("\n", ""))
        end
    else
        vim.health.error("difi binary not found")
        vim.health.info("Install via Homebrew: brew tap oug-t/difi && brew install difi")
    end
end

return M
