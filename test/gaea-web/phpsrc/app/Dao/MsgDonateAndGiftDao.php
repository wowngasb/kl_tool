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
 * Class MsgDonateAndGiftDao
 * 打赏及赠送礼物消息
 * 数据表 msg_donate_and_gift
 * @package tiny_app\Dao
 */
class MsgDonateAndGiftDao
{

    use OrmTrait;

    /**
     * 使用这个特性的子类必须 实现这个方法 返回特定格式的数组 表示数据表的配置
     * @return OrmConfig
     */
    protected static function getOrmConfig()
    {
        if (is_null(static::$_orm_config)) {
            static::$_orm_config = new OrmConfig(Application::getInstance()->getEnv('ENV_MYSQL_DB'), 'msg_donate_and_gift', 'msg_id', 300, 5000);
        }
        return static::$_orm_config;
    }

    
    /*
     * INTEGER msg_id 互动消息 唯一id
     */
    public static function msg_id($msg_id, $default = null)
    {
        return static::getFiledById('msg_id', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) msg_type 互动消息类型 固定为 donate_and_gift
     */
    public static function msg_type($msg_id, $default = null)
    {
        return static::getFiledById('msg_type', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) target_user_id 消息目标用户 用户id 用于处理打赏给指定用户 
     */
    public static function target_user_id($msg_id, $default = null)
    {
        return static::getFiledById('target_user_id', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) trade_type 打赏或礼物类型 
     */
    public static function trade_type($msg_id, $default = null)
    {
        return static::getFiledById('trade_type', $msg_id, $default);
    }

    
    /*
     * FLOAT trade_num 打赏或礼物数量 
     */
    public static function trade_num($msg_id, $default = null)
    {
        return static::getFiledById('trade_num', $msg_id, $default);
    }

    
    /*
     * VARCHAR(512) content_text 消息文本内容
     */
    public static function content_text($msg_id, $default = null)
    {
        return static::getFiledById('content_text', $msg_id, $default);
    }

    
}