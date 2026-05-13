-- single_char_filter.lua
-- 自定义候选词过滤器
--
--[[
## 功能
1. 短输入过滤：输入码 ≤2 字符时，过滤 completion 类型候选（英文前缀补全）
2. 精确匹配置顶：纯英文输入时，将完全匹配的英文单词置顶（黑名单除外）

## 背景
Rime 候选词排序由两个阶段决定：

1. 翻译器权重（initial_quality）
   custom_phrase: 99 > script_translator: 1.2 > melt_eng: 1.1 > cn_en: 0.5

2. 过滤器链（按顺序处理）
   pin_cand_filter → long_word_filter → reduce_english_filter → 本过滤器

## 解决的问题
- 输入 "b" 时不想看到 "�" "Ⓑ" 等 completion 补全
- 输入 "brew" 时，因拼音权重 1.2 > 英文权重 1.1，"不热" 排在 "brew" 前面
  本过滤器将精确匹配的英文单词提升到首位

## 黑名单
某些英文单词虽然是合法英文，但作为拼音更常用（如 rang/yang），
这些词不应被置顶，而应遵循 reduce_english_filter 的降低处理。
--]]

local M = {}

-- 黑名单：这些词是合法英文，但作为拼音更常用，不进行置顶
-- 复用 reduce_english_filter.lua 中的内置列表
local blacklist = {
    "rang", "yang", "yin", "yan", "yen", "zen",
    "women", "womens",  -- wo men (我们)
    "tad",  -- ta de (他的)
    "bang", "tang", "hang", "lang", "gang", "sang", "wang", "fang",
    "bing", "ding", "ling", "ming", "ning", "ping", "ting", "jing", "xing",
    "long", "dong", "gong", "kong", "song", "tong", "nong",
    "dang", "nang", "cang", "zang", "kang",
    "deng", "feng", "geng", "heng", "leng", "meng", "neng", "peng", "seng", "teng", "weng", "zeng",
    "hong", "rong", "yong", "zong", "cong",
    "liang", "jiang", "xiang", "qiang", "niang",
    "ban", "can", "dan", "fan", "gan", "han", "lan", "man", "nan", "pan", "ran", "san", "tan", "wan", "zan",
    "ben", "fen", "gen", "hen", "ken", "men", "nen", "pen", "ren", "sen", "wen", "zen",
    "bin", "din", "fin", "gin", "kin", "lin", "min", "pin", "sin", "tin", "win", "yin",
    "bun", "dun", "fun", "gun", "hun", "jun", "kun", "nun", "pun", "run", "sun", "tun",
    "chi", "shi", "zhi",
    "duo",  -- duo (多/朵/躲)
    "fade", "shade",
}
local blacklist_set = {}
for _, word in ipairs(blacklist) do
    blacklist_set[word:lower()] = true
end

function M.init(env)
    -- 初始化函数，可以为空
end

-- 检查字符串是否为纯英文字母
local function is_pure_english(str)
    return str:match("^[a-zA-Z]+$") ~= nil
end

function M.func(input, env)
    local context = env.engine.context
    local input_code = context.input

    -- 如果输入码长度小于等于 2，则过滤掉 completion 类型的候选（英文补全）
    if utf8.len(input_code) <= 2 then
        for cand in input:iter() do
            local cand_type = cand.type
            -- 过滤掉 completion 类型的候选项（这些是来自 custom_phrase 和 melt_eng 的前缀补全）
            if cand_type ~= "completion" then
                yield(cand)
            end
        end
        return
    end

    -- 输入码长度大于 2 时，检查是否为纯英文输入
    -- 如果是纯英文，尝试将完全匹配的英文单词置顶
    if is_pure_english(input_code) then
        local input_lower = input_code:lower()
        local exact_match = nil  -- 完全匹配的候选项
        local others = {}        -- 其他候选项

        -- 只在前 50 个候选项中查找完全匹配
        local count = 0
        for cand in input:iter() do
            count = count + 1
            local cand_text_lower = cand.text:lower()

            -- 找到完全匹配的英文单词（忽略大小写），但排除黑名单中的词
            if exact_match == nil and cand_text_lower == input_lower and is_pure_english(cand.text) and not blacklist_set[input_lower] then
                exact_match = cand
            else
                table.insert(others, cand)
            end

            -- 限制查找范围，避免性能问题
            if count >= 50 then
                break
            end
        end

        -- 先输出完全匹配的候选项
        if exact_match then
            yield(exact_match)
        end

        -- 再输出其他候选项
        for _, cand in ipairs(others) do
            yield(cand)
        end

        -- 继续输出剩余的候选项
        for cand in input:iter() do
            yield(cand)
        end
    else
        -- 非纯英文输入，正常显示所有候选
        for cand in input:iter() do
            yield(cand)
        end
    end
end

return M
