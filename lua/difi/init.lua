local M = {}

M.state = {
    buf = -1,
    win = -1,
}

local function is_installed()
    return vim.fn.executable("difi") == 1
end

local function create_floating_window(opts)
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.9)
    local height = opts.height or math.floor(vim.o.lines * 0.9)

    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local buf = nil
    if vim.api.nvim_buf_is_valid(M.state.buf) then
        buf = M.state.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
        M.state.buf = buf
    end

    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    }

    local win = vim.api.nvim_open_win(buf, true, win_config)
    M.state.win = win

    return { buf = buf, win = win }
end

function M.toggle()
    if not is_installed() then
        vim.notify("difi binary not found. Please install it:\nbrew tap oug-t/difi && brew install difi",
            vim.log.levels.ERROR)
        return
    end

    if vim.api.nvim_win_is_valid(M.state.win) then
        vim.api.nvim_win_hide(M.state.win)
    else
        local win_info = create_floating_window({ width = 120, height = 40 })

        if vim.bo[win_info.buf].channel == 0 then
            vim.fn.termopen("difi", {
                on_exit = function()
                    vim.api.nvim_win_close(win_info.win, true)
                end,
            })
        end
        vim.cmd("startinsert")
    end
end

return M
