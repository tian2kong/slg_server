local account_sql = {
    select_account = "select account,gm,invatecode from account where playerid=%d",
    select_playerid = "select playerid,gm,invatecode from account where account like '%s'",
    insert_account = "insert into account(account, playerid, gm, invatecode) values('%s',%d, %d, '%s')",
    select_maxid = "select max(playerid) from account",
    update_invatecode = "update account set invatecode = '%s' where account like '%s'",
    delete_account = "delete from account where playerid=%d;",
}

return account_sql