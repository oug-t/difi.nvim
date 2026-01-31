if vim.g.loaded_difi then
    return
end
vim.g.loaded_difi = 1

vim.api.nvim_create_user_command("Difi", function(opts)
    require("difi").toggle(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command("DifiHealth", function()
    require("difi.health").check()
end, {})
