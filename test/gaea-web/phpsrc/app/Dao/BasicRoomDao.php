<?php
/**
 * Created by table_graphQL.
 * User: Administrator
 * Date: 2017-06
 */
namespace tiny_app\Dao;

use TinyWeb\Application;
use TinyWeb\OrmQuery\OrmConfig;
use TinyWeb\Traits\OrmTrait;


/**
 * Class BasicRoomDao
 * 直播活动基本信息 每个条目对应一个活动
 * 数据表 basic_room
 * @package tiny_app\Dao
 */
class BasicRoomDao
{

    use OrmTrait;

    /**
     * 使用这个特性的子类必须 实现这个方法 返回特定格式的数组 表示数据表的配置
     * @return OrmConfig
     */
    protected static function getOrmConfig()
    {
        if (is_null(static::$_orm_config)) {
            static::$_orm_config = new OrmConfig(Application::getInstance()->getEnv('ENV_MYSQL_DB'), 'basic_room', 'room_id', 300, 5000);
        }
        return static::$_orm_config;
    }

    
    /*
     * INTEGER room_id 直播活动 唯一id
     */
    public static function room_id($room_id, $default = null)
    {
        return static::getFiledById('room_id', $room_id, $default);
    }

    
    /*
     * VARCHAR(32) room_title 直播活动标题
     */
    public static function room_title($room_id, $default = null)
    {
        return static::getFiledById('room_title', $room_id, $default);
    }

    
    /*
     * VARCHAR(32) chat_topic DMS topic 互动消息话题
     */
    public static function chat_topic($room_id, $default = null)
    {
        return static::getFiledById('chat_topic', $room_id, $default);
    }

    
    /*
     * VARCHAR(64) dms_sub_key DMS sub_key 必须确保dms状态正常并且开启系统消息通知，
     */
    public static function dms_sub_key($room_id, $default = null)
    {
        return static::getFiledById('dms_sub_key', $room_id, $default);
    }

    
    /*
     * VARCHAR(64) dms_pub_key DMS pub_key
     */
    public static function dms_pub_key($room_id, $default = null)
    {
        return static::getFiledById('dms_pub_key', $room_id, $default);
    }

    
    /*
     * VARCHAR(64) dms_s_key DMS s_key
     */
    public static function dms_s_key($room_id, $default = null)
    {
        return static::getFiledById('dms_s_key', $room_id, $default);
    }

    
    /*
     * INTEGER aodian_uin 奥点云 uin
     */
    public static function aodian_uin($room_id, $default = null)
    {
        return static::getFiledById('aodian_uin', $room_id, $default);
    }

    
    /*
     * VARCHAR(32) lss_app 流媒体 app
     */
    public static function lss_app($room_id, $default = null)
    {
        return static::getFiledById('lss_app', $room_id, $default);
    }

    
    /*
     * VARCHAR(32) stream 流媒体 stream
     */
    public static function stream($room_id, $default = null)
    {
        return static::getFiledById('stream', $room_id, $default);
    }

    
    /*
     * SMALLINT room_status 直播活动状态 正常 normal, 冻结 frozen, 删除 deleted
     */
    public static function room_status($room_id, $default = null)
    {
        return static::getFiledById('room_status', $room_id, $default);
    }

    
}