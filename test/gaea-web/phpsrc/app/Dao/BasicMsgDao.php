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
 * Class BasicMsgDao
 * 互动消息模型 可扩展自定义类型
 * 数据表 basic_msg
 * @package tiny_app\Dao
 */
class BasicMsgDao
{

    use OrmTrait;

    /**
     * 使用这个特性的子类必须 实现这个方法 返回特定格式的数组 表示数据表的配置
     * @return OrmConfig
     */
    protected static function getOrmConfig()
    {
        if (is_null(static::$_orm_config)) {
            static::$_orm_config = new OrmConfig(Application::getInstance()->getEnv('ENV_MYSQL_DB'), 'basic_msg', 'msg_id', 300, 5000);
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
     * INTEGER room_id 对应房间id
     */
    public static function room_id($msg_id, $default = null)
    {
        return static::getFiledById('room_id', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) user_id 对应消息发起者用户id
     */
    public static function user_id($msg_id, $default = null)
    {
        return static::getFiledById('user_id', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) msg_type 互动消息类型 聊天及审核消息 chat_and_review, 打赏及赠送礼物消息 donate_and_gift
     */
    public static function msg_type($msg_id, $default = null)
    {
        return static::getFiledById('msg_type', $msg_id, $default);
    }

    
    /*
     * INTEGER timestamp 消息创建时间戳
     */
    public static function timestamp($msg_id, $default = null)
    {
        return static::getFiledById('timestamp', $msg_id, $default);
    }

    
}