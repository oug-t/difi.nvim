local M = {}

M.state = {
    active = false,
    ns_id = -1,
}

local function set_highlights()
    M.state.ns_id = vim.api.nvim_create_namespace("difi_active")

    local is_dark = (vim.o.background == "dark")
    local add_bg = is_dark and "#10351f" or "#e6ffec"
    local delete_bg = is_dark and "#3d0d12" or "#ffebe9"

    vim.api.nvim_set_hl(0, "DifiAdd", { bg = add_bg })
    vim.api.nvim_set_hl(0, "DifiDelete", { bg = delete_bg })
end

local function get_git_diff(filename, target)
    target = target or "HEAD"

    local cmd = string.format(
        "git diff --diff-algorithm=histogram --ignore-blank-lines -U100000 %s -- %s",
        target,
        vim.fn.shellescape(filename)
    )

    local output = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("difi error: " .. output, vim.log.levels.ERROR)
        return nil
    end

    return output
end

local function apply_diff_view(target)
    if vim.bo.modified then
        vim.notify("difi: Please save the file first (:w)", vim.log.levels.WARN)
        return
    end

    local filename = vim.fn.expand("%")
    if filename == "" then
        vim.notify("difi: Buffer has no file name", vim.log.levels.ERROR)
        return
    end

    local diff_output = get_git_diff(filename, target)
    if not diff_output or diff_output == "" then
        vim.notify("difi: No significant changes found against " .. (target or "HEAD"), vim.log.levels.INFO)
        return
    end

    local lines = vim.split(diff_output, "\n")
    local new_buffer_lines = {}
    local header_done = false

    for _, line in ipairs(lines) do
        if line:match("^@@") then
            header_done = true
        elseif header_done then
            if line ~= "" or #new_buffer_lines > 0 then
                table.insert(new_buffer_lines, line)
            end
        end
    end

    if #new_buffer_lines == 0 then
        vim.notify("difi: Could not parse diff output", vim.log.levels.WARN)
        return
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_buffer_lines)

    set_highlights()
    for i, line in ipairs(new_buffer_lines) do
        if line:match("^-") then
            vim.api.nvim_buf_add_highlight(0, M.state.ns_id, "DifiDelete", i - 1, 0, -1)
        elseif line:match("^+") then
            vim.api.nvim_buf_add_highlight(0, M.state.ns_id, "DifiAdd", i - 1, 0, -1)
        end
    end

    M.state.active = true
    vim.notify("difi: Diff against " .. (target or "HEAD"), vim.log.levels.INFO)
end

local function restore_view()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local final_lines = {}

    for _, line in ipairs(lines) do
        local first_char = line:sub(1, 1)

        if first_char == "-" then
        elseif first_char == "+" then
            table.insert(final_lines, line:sub(2))
        elseif first_char == " " then
            table.insert(final_lines, line:sub(2))
        else
            table.insert(final_lines, line)
        end
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, final_lines)

    if M.state.ns_id ~= -1 then
        vim.api.nvim_buf_clear_namespace(0, M.state.ns_id, 0, -1)
    end

    M.state.active = false
    vim.notify("difi: Changes applied", vim.log.levels.INFO)
end

function M.toggle(args)
    if M.state.active then
        restore_view()
    else
        -- Priority: 1. Args, 2. Env Var (from difi CLI), 3. Default (HEAD)
        local target = (args and args ~= "") and args or vim.env.DIFI_TARGET
        apply_diff_view(target)
    end
end

return M
