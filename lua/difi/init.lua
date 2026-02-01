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

    -- Apply content
    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_buffer_lines)

    -- Apply Highlights
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
            -- Drop deleted lines
        elseif first_char == "+" then
            -- Keep added lines, strip marker
            table.insert(final_lines, line:sub(2))
        elseif first_char == " " then
            -- Keep context lines, strip marker
            table.insert(final_lines, line:sub(2))
        else
            -- Keep modified lines
            table.insert(final_lines, line)
        end
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, final_lines)

    -- SMART RESET: Check if content matches disk (Tolerant of trailing newline)
    local filename = vim.fn.expand("%")
    if vim.fn.filereadable(filename) == 1 then
        vim.cmd("checktime") -- Ensure we see the latest disk state
        local disk_lines = vim.fn.readfile(filename)

        -- Often one source has an empty string at the end and the other doesn't.
        -- We allow a 1-line difference if that line is empty.
        local diff_count = #disk_lines - #final_lines
        local size_match = (diff_count == 0) or (diff_count == 1 and disk_lines[#disk_lines] == "") or
        (diff_count == -1 and final_lines[#final_lines] == "")

        if size_match then
            local match = true
            -- Compare the overlapping lines
            local limit = math.min(#disk_lines, #final_lines)
            for i = 1, limit do
                if disk_lines[i] ~= final_lines[i] then
                    match = false
                    break
                end
            end

            if match then
                -- It's a match! Force the buffer to be "clean"
                vim.api.nvim_set_option_value("modified", false, { buf = 0 })
            end
        end
    end

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
        local target = (args and args ~= "") and args or vim.env.DIFI_TARGET
        apply_diff_view(target)
    end
end

return M
