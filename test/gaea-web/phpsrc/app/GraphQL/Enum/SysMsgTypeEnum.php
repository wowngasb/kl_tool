<?php
/**
 * Created by table_graphQL.
 * User: Administrator
 * Date: 2017-06
 */
namespace MyGraphQL\Enum;

use GraphQL\Type\Definition\EnumType;

/**
 * Class SysMsgTypeEnum
 * 房间系统消息显示类型 全部显示 show_all, 全部隐藏 hide_all
 * @package MyGraphQL\Enum
 */
class SysMsgTypeEnum extends EnumType
{

    public function __construct(array $_config = [])
    {
        $config = [
            'description' => "房间系统消息显示类型 全部显示 show_all, 全部隐藏 hide_all",
            'values' => []
        ];
        $config['values']['show_all'] = [
            'value' => 'show_all',
            'description' => "房间系统消息显示类型 全部显示 show_all, 全部隐藏 hide_all",
        ];
        $config['values']['hide_all'] = [
            'value' => 'hide_all',
            'description' => "房间系统消息显示类型 全部显示 show_all, 全部隐藏 hide_all",
        ];
        
        if (!empty($_config['values'])) {
            $config['values'] = array_merge($_config['values'], $config['values']);
        }
        parent::__construct($config);
    }

}