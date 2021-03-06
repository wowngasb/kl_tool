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
 * Class PlayerMpsConfigDao
 * 直播活动 Mps播放器
 * 数据表 player_mps_config
 * @package tiny_app\Dao
 */
class PlayerMpsConfigDao
{

    use OrmTrait;

    /**
     * 使用这个特性的子类必须 实现这个方法 返回特定格式的数组 表示数据表的配置
     * @return OrmConfig
     */
    protected static function getOrmConfig()
    {
        if (is_null(static::$_orm_config)) {
            static::$_orm_config = new OrmConfig(Application::getInstance()->getEnv('ENV_MYSQL_DB'), 'player_mps_config', 'room_id', 300, 5000);
        }
        return static::$_orm_config;
    }

    
    /*
     * INTEGER room_id 对应房间 id
     */
    public static function room_id($room_id, $default = null)
    {
        return static::getFiledById('room_id', $room_id, $default);
    }

    
    /*
     * VARCHAR(16) player_type 播放器类型 固定为 mpsplayer
     */
    public static function player_type($room_id, $default = null)
    {
        return static::getFiledById('player_type', $room_id, $default);
    }

    
    /*
     * INTEGER uin 用户奥点uin
     */
    public static function uin($room_id, $default = null)
    {
        return static::getFiledById('uin', $room_id, $default);
    }

    
    /*
     * VARCHAR(32) appId mps实例id 需要静态实例
     */
    public static function appId($room_id, $default = null)
    {
        return static::getFiledById('appId', $room_id, $default);
    }

    
    /*
     * SMALLINT autostart 是否自动播放
     */
    public static function autostart($room_id, $default = null)
    {
        return static::getFiledById('autostart', $room_id, $default);
    }

    
    /*
     * SMALLINT stretching 设置全屏模式 1代表按比例撑满至全屏 2代表铺满全屏 3代表视频原始大小
     */
    public static function stretching($room_id, $default = null)
    {
        return static::getFiledById('stretching', $room_id, $default);
    }

    
    /*
     * SMALLINT mobilefullscreen 移动端是否全屏
     */
    public static function mobilefullscreen($room_id, $default = null)
    {
        return static::getFiledById('mobilefullscreen', $room_id, $default);
    }

    
    /*
     * VARCHAR(16) controlbardisplay 是否显示控制栏 可取值 disable enable 默认为disable
     */
    public static function controlbardisplay($room_id, $default = null)
    {
        return static::getFiledById('controlbardisplay', $room_id, $default);
    }

    
    /*
     * SMALLINT isclickplay 是否单击播放，默认为false
     */
    public static function isclickplay($room_id, $default = null)
    {
        return static::getFiledById('isclickplay', $room_id, $default);
    }

    
    /*
     * SMALLINT isfullscreen 是否双击全屏，默认为true
     */
    public static function isfullscreen($room_id, $default = null)
    {
        return static::getFiledById('isfullscreen', $room_id, $default);
    }

    
}