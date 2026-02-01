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

local env_target = vim.env.DIFI_TARGET

if env_target then
    local function auto_start()
        if vim.fn.filereadable(vim.fn.expand("%")) == 1 then
            require("difi").toggle(env_target)
        end
    end

    if vim.v.vim_did_enter == 1 then
        auto_start()
    else
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = auto_start,
            once = true
        })
    end
end
