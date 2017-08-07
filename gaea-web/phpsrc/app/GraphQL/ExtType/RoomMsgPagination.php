<?php
/**
 * Created by table_graphQL.
 * User: Administrator
 * Date: 2017-06
 */
namespace MyGraphQL\ExtType;

use MyGraphQL\Types;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\ResolveInfo;

/**
 * Class RoomMsgPagination
 * 房间历史消息
 * @package MyGraphQL\ExtType
 */
class RoomMsgPagination extends ObjectType
{

    public function __construct(array $_config = [], $type = null)
    {
        if (is_null($type)) {
            /** @var Types $type */
            $type = new Types();
        }
        $config = [
            'description' => "房间历史消息",
            'fields' => []
        ];
        $config['fields']['msgList'] = [
            'type' => $type::listOf($type::BasicMsg([], $type)),
            'description' => "消息列表",
        ];
        $config['fields']['pageInfo'] = [
            'type' => $type::PageInfo([], $type),
            'description' => "分页信息",
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