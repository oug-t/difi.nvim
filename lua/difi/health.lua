local M = {}

function M.check()
    vim.health.start("difi.nvim report")

    if vim.fn.executable("git") == 1 then
        vim.health.ok("git binary found")
    else
        vim.health.error("git binary not found")
    end
end

return M
