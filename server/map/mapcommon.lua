local mapcommon = BuildCommon("mapcommon")

mapcommon.max_x = 1000 --
mapcommon.max_y = 1000 --

mapcommon.init_intersectspacenum = 4 --
mapcommon.mapobject_maxtombid = 10000 --活物ID复用, 场景活物大量创建, 优先找前N个没有复用的ID

mapcommon.block_x_offset = 10 --区块X轴偏移量
mapcommon.block_y_offset = 10 --区块y轴偏移量
mapcommon.blockkey_offset = 1000 --block坐标偏移值 blockkey = block_x * 1000 + block_y

mapcommon.block_x_num = mapcommon.max_x / mapcommon.block_x_offset --x轴区块数
mapcommon.block_y_num = mapcommon.max_y / mapcommon.block_y_offset --y轴区块数

mapcommon.xykey_offset = 1000 --地图坐标偏移值 xykey = x * 1000 + y

mapcommon.playercity_width = 2 --玩家主城宽度
mapcommon.playercity_height = 2 --玩家主城高度

mapcommon.default_width = 2 --默认宽度
mapcommon.default_height = 2 --默认高度

mapcommon.recoverscale = 0.25--资源低于25%加入回收队列

mapcommon.search_blockoffset = 2--搜索block偏移量
mapcommon.search_expiretm = 300--搜索失效CD

--资源区域
mapcommon.MapAreaType = {
	eMAT_Senior = 1, --高级区域
	eMAT_Middle = 2, --中级区域
	eMAT_Lower  = 3, --低级区域
}

mapcommon.TombType = 0 --墓地类型通用(资源, 怪物)
--资源类型
mapcommon.ResourceType = {
	eRT_Gas = 1, --天然气
	eRT_Food = 2, --食物
	eRT_Water = 3, --水
	eRT_Cement = 4, --水泥
}
--怪物类型
mapcommon.MonsterType = {
	eMT_Zombie = 1, --僵尸 
}

--地图活物类型
mapcommon.MapObjectType = {
	eMOT_Player 	= 1,
	eMOT_Resource 	= 2,
	eMOT_Monster 	= 3,
}

mapcommon.map_code = {
	unknow = 0,
	success = 1,
	fail = 2,

	nocitydata = 10,
	errorparam = 11, --参数错误
	unsearchtag = 12, --没有找到目标
}

--搜索类型
mapcommon.SearchType = { 
	eST_Gas 	= 1, --煤气
	eST_Food 	= 2, --食物
	eST_Water 	= 3, --水
	eST_Cement 	= 4, --水泥

	eST_Zombie  = 5, --僵尸
}

--搜索类型映射资源 怪物等类型
mapcommon.SearchTypeMappingType = {
	--资源
	[mapcommon.SearchType.eST_Gas] = mapcommon.ResourceType.eRT_Gas,
	[mapcommon.SearchType.eST_Food] = mapcommon.ResourceType.eRT_Food,
	[mapcommon.SearchType.eST_Water] = mapcommon.ResourceType.eRT_Water,
	[mapcommon.SearchType.eST_Cement] = mapcommon.ResourceType.eRT_Cement,

	--怪物
	[mapcommon.SearchType.eST_Zombie] = mapcommon.MonsterType.eMT_Zombie,
}

--搜索活物等级区间
mapcommon.SearchLevelRange = {
	--资源
	[mapcommon.SearchType.eST_Gas]={1,7},
	[mapcommon.SearchType.eST_Food]={1,7},
	[mapcommon.SearchType.eST_Water]={1,7},
	[mapcommon.SearchType.eST_Cement]={1,7},

	--怪物
	[mapcommon.SearchType.eST_Zombie]={1,7},
}

mapcommon.ObjectProto = {
	[mapcommon.MapObjectType.eMOT_Player] = "synccitylist",
    [mapcommon.MapObjectType.eMOT_Resource] = "syncresourcelist",
}

mapcommon.MapObjRemoveProto = "syncmapobjremove"
mapcommon.MarchListProto = "syncmarchlist"
mapcommon.MarchRemoveProto = "syncmarchremove"

----------------------------------------------------Function-----------------------------------------------

function mapcommon.xyToblockxy(x, y)
	return math.ceil(x / mapcommon.block_x_offset), math.ceil(y / mapcommon.block_y_offset)
end

--坐标x,y 转换blockkey
function mapcommon.xyToblockkey(x, y)
	return mapcommon.blockxyToblockkey(mapcommon.xyToblockxy(x,y))
end

function mapcommon.blockxyToxy(block_x, block_y)
	return (block_x-1)*mapcommon.block_x_offset+1, (block_y-1)*mapcommon.block_y_offset+1
end

function mapcommon.xyToarenatype(x, y)
	--TODOX
	return mapcommon.MapAreaType.MAT_SENIOR
end

--坐标x,y xykey= x*偏移值(1000)+y
function mapcommon.xyToxykey(x, y)
	return x*mapcommon.xykey_offset + y
end

function mapcommon.blockxyToblockkey(block_x, block_y)
	return mapcommon.blockkey_offset * block_x + block_y
end

function mapcommon.blockkeyToblockxy(blockkey)
	return blockkey // mapcommon.blockkey_offset, blockkey % mapcommon.blockkey_offset
end

--原始坐标转换成该block的起始startx,starty坐标 (x,y)为原始坐标格子
function mapcommon.xyToblockstartxy(x, y)
	return mapcommon.blockxyToxy(mapcommon.xyToblockxy(x,y))
end
function mapcommon.blockkeyToblockstartxy(blockkey)
	return mapcommon.blockxyToxy(mapcommon.blockkeyToblockxy(blockkey))
end

--获取指定pos内九宫格所有坐标点, r半径
function mapcommon.getaroundpos(x, y, r)
	--[[ 记录周围九宫格
		y	-------------------
			|     |     |     |
			|  1  |  2  |  3  |
			|     |     |     |
			-------------------
			|     |     |     |
			|  4  |  5  |  6  |
			|     | x,y |     |
			-------------------
			|     |     |     |
			|  7  |  8  |  9  |
			|     |     |     |
			-------------------
		pos(0,0)	           x
	]]

	r = r or 1
	local pos = {}
	for iy=y+r,y-r,-1 do
		for ix=x-r,x+r do
			table.insert(pos, {ix, iy})
		end
	end
	return pos
end

return mapcommon