-- single_char_filter.lua
-- 过滤单字符输入时来自 melt_eng 和 custom_phrase 的英文联想

local M = {}

function M.init(env)
    -- 初始化函数，可以为空
end

function M.func(input, env)
    local context = env.engine.context
    local input_code = context.input

    -- 如果输入码长度为 1，则过滤掉 completion 类型的候选（英文补全）
    if utf8.len(input_code) == 1 then
        for cand in input:iter() do
            local cand_type = cand.type
            -- 过滤掉 completion 类型的候选项（这些是来自 custom_phrase 和 melt_eng 的前缀补全）
            if cand_type ~= "completion" then
                yield(cand)
            end
        end
    else
        -- 输入码长度大于 1 时，正常显示所有候选
        for cand in input:iter() do
            yield(cand)
        end
    end
end

return M
