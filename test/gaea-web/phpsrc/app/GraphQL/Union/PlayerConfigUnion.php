<?php
/**
 * Created by table_graphQL.
 * User: Administrator
 * Date: 2017-06
 */
namespace MyGraphQL\Union;

use MyGraphQL\Types;
use GraphQL\Type\Definition\ResolveInfo;
use GraphQL\Type\Definition\UnionType;

/**
 * Class PlayerConfigUnion
 * 播放器配置
 * @package MyGraphQL\Union
 */
class PlayerConfigUnion extends UnionType
{

    public function __construct(array $_config = [], $type = null)
    {
        if (is_null($type)) {
            /** @var Types $type */
            $type = new Types();
        }
        $config = [
            'types' => [
                $type::PlayerAodianConfig([], $type),
                $type::PlayerMpsConfig([], $type),
            ],
            'resolveType' => function ($rootValue, $context, ResolveInfo $info) use ($type) {
                false && func_get_args();
                if ($rootValue['player_type'] == 'mpsplayer') {
                    return $type::PlayerMpsConfig([], $type);
                } else if ($rootValue['player_type'] == 'aodianplayer') {
                    return $type::PlayerAodianConfig([], $type);}
                return null;
            },
            'description' => "播放器配置"
        ];

        $config = array_merge($config, $_config);
        parent::__construct($config);
    }

}