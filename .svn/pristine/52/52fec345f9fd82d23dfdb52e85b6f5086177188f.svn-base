local storagecommon = BuildCommon("storagecommon")

storagecommon.code = {
    unknow          = 0, --
    success         = 1, --成功
    upload_suc      = 2, --上传成功
    abandon_suc     = 3, --释放成功
    send_suc        = 4, --发送成功


    param_error     = 10, --参数错误
    no_find         = 11, --没有找到数据
    wait            = 12, --继续等待接收
    repeat_recv     = 13, --重复接收
    no_wait         = 14, --不是等待状态了(已经接收完毕,或释放)
    status_error    = 15, --状态错误
    type_error      = 16, --类型错误
    size_error      = 17, --包体长度错误
    large_size      = 18, --文件太大
}

storagecommon.package_size = 1024 * 60 --一个包最大60KB

storagecommon.eventid = {
    event_upload = 1,   --上传大文件通知
    event_download = 2, --下载(请求)大文件
}

storagecommon.type = {
    other_unknow = 0, --其他未知的类型
    space_image = 1, --空间图片
    space_voice = 2, --空间语音

    private_voice = 3, --私聊语音
    channel_voice = 4, --频道语音
}

return storagecommon