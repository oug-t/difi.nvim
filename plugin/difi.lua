if vim.g.loaded_difi then
    return
end
vim.g.loaded_difi = 1

local health = require("difi.health")

vim.api.nvim_create_user_command("Difi", function()
    require("difi").toggle()
end, {})

vim.api.nvim_create_user_command("DifiHealth", health.check, {})
