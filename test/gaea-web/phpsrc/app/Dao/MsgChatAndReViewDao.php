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
 * Class MsgChatAndReViewDao
 * 聊天及审核消息
 * 数据表 msg_chat_and_review
 * @package tiny_app\Dao
 */
class MsgChatAndReViewDao
{

    use OrmTrait;

    /**
     * 使用这个特性的子类必须 实现这个方法 返回特定格式的数组 表示数据表的配置
     * @return OrmConfig
     */
    protected static function getOrmConfig()
    {
        if (is_null(static::$_orm_config)) {
            static::$_orm_config = new OrmConfig(Application::getInstance()->getEnv('ENV_MYSQL_DB'), 'msg_chat_and_review', 'msg_id', 300, 5000);
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
     * VARCHAR(16) msg_type 互动消息类型 固定为 chat_and_review
     */
    public static function msg_type($msg_id, $default = null)
    {
        return static::getFiledById('msg_type', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) target_user_id 消息目标用户 用户id 用于处理私聊
     */
    public static function target_user_id($msg_id, $default = null)
    {
        return static::getFiledById('target_user_id', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) target_msg_id 目标消息id
     */
    public static function target_msg_id($msg_id, $default = null)
    {
        return static::getFiledById('target_msg_id', $msg_id, $default);
    }

    
    /*
     * VARCHAR(512) content_text 消息文本内容
     */
    public static function content_text($msg_id, $default = null)
    {
        return static::getFiledById('content_text', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) msg_status 聊天及审核消息状态 用户发布聊天 publish_chat, 审核发布消息 review_pub, 审核删除消息 review_del, 添加到审核列表 review_add
     */
    public static function msg_status($msg_id, $default = null)
    {
        return static::getFiledById('msg_status', $msg_id, $default);
    }

    
    /*
     * VARCHAR(16) operator_id 当前操作者 用户id
     */
    public static function operator_id($msg_id, $default = null)
    {
        return static::getFiledById('operator_id', $msg_id, $default);
    }

    
}