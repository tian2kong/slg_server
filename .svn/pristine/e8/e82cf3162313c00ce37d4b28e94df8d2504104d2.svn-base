local static_func = {}

--获取兑换属性点所需经验
static_func.GetFreePointExchangeExp = function(CurPoint, Amount)
    -- function num : 0_8 , upvalues : _ENV
    if not Amount then
        Amount = 1
    end
    local NeedExp = 0
    for i = 1, Amount do
        local Y = 1
        local X = CurPoint + 1
        if X <= 100 then
            Y = 1
        else
            if X <= 200 then
                Y = 0.4
            else
                if X <= 300 then
                    Y = 0.27
                else
                    if X <= 400 then
                        Y = 0.27
                    else
                        assert(false)
                    end
                end
            end
        end
        CurPoint = CurPoint + 1
        NeedExp = NeedExp + (math.floor)((9326 * (52 * X ^ 1.15 / X) * X ^ 0.4 + 1231 * (52 * X ^ 1.15 / X) * X + 119) * Y)
    end
    return NeedExp
end

return static_func