<?php
/**
 * Created by table_graphQL.
 * User: Administrator
 * Date: 2017-06
 */
namespace MyGraphQL\Type;

use MyGraphQL\Types;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\ResolveInfo;

/**
 * Class ChatConfig
 * 直播活动 聊天配置信息
 * @package MyGraphQL\Type
 */
class ChatConfig extends ObjectType
{

    public function __construct(array $_config = [], $type = null)
    {
        if (is_null($type)) {
            /** @var Types $type */
            $type = new Types();
        }
        $config = [
            'description' => "直播活动 聊天配置信息",
            'fields' => []
        ];
        $config['fields']['review_type'] = [
            'type' => $type::nonNull($type::ReviewTypeEnum()),
            'description' => "房间聊天审核类型 禁止聊天 disable_chat, 关闭聊天审核，聊天直接发布 direct_pub, 开启聊天审核 review_chat",
        ];
        $config['fields']['sysmsg_type'] = [
            'type' => $type::nonNull($type::SysMsgTypeEnum()),
            'description' => "房间系统消息显示类型 全部显示 show_all, 全部隐藏 hide_all",
        ];
        
        $config['resolveField'] = function($value, $args, $context, ResolveInfo $info) {
            if (method_exists($this, $info->fieldName)) {
                return $this->{$info->fieldName}($value, $args, $context, $info);
            } else {
                return is_array($value) ? $value[$info->fieldName] : $value->{$info->fieldName};
            }
        };
        if (!empty($_config['fields'])) {
            $config['fields'] = array_merge($_config['fields'], $config['fields']);
        }
        parent::__construct($config);
    }

}