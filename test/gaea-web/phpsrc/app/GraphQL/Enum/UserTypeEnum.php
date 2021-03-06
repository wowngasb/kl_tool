<?php
/**
 * Created by table_graphQL.
 * User: Administrator
 * Date: 2017-06
 */
namespace MyGraphQL\Enum;

use GraphQL\Type\Definition\EnumType;

/**
 * Class UserTypeEnum
 * 用户类型 游客 guest, 已认证 authorized, 管理者 manager, 发布者 publisher
 * @package MyGraphQL\Enum
 */
class UserTypeEnum extends EnumType
{

    public function __construct(array $_config = [])
    {
        $config = [
            'description' => "用户类型 游客 guest, 已认证 authorized, 管理者 manager, 发布者 publisher",
            'values' => []
        ];
        $config['values']['publisher'] = [
            'value' => 'publisher',
            'description' => "用户类型 游客 guest, 已认证 authorized, 管理者 manager, 发布者 publisher",
        ];
        $config['values']['manager'] = [
            'value' => 'manager',
            'description' => "用户类型 游客 guest, 已认证 authorized, 管理者 manager, 发布者 publisher",
        ];
        $config['values']['guest'] = [
            'value' => 'guest',
            'description' => "用户类型 游客 guest, 已认证 authorized, 管理者 manager, 发布者 publisher",
        ];
        $config['values']['authorized'] = [
            'value' => 'authorized',
            'description' => "用户类型 游客 guest, 已认证 authorized, 管理者 manager, 发布者 publisher",
        ];
        
        if (!empty($_config['values'])) {
            $config['values'] = array_merge($_config['values'], $config['values']);
        }
        parent::__construct($config);
    }

}