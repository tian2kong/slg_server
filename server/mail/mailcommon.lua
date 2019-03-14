local mailcommon = BuildCommon("mailcommon")

mailcommon.MailType = {
    trade = 1,--交易
    guild = 2,--帮派
    arena = 3,--竞技场
    system = 4,--系统
}

mailcommon.expire_time = 3 * 24 * 60 * 60   --邮件过期时间为3天

mailcommon.message_code = {
    unkown = 0,
    success = 1,
    no_mail = 2,--没有邮件
    server_busy = 5,--服务器繁忙
}

return mailcommon