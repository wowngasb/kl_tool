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
 * Class BasicRoom
 * 直播活动基本信息 每个条目对应一个活动
 * @package MyGraphQL\Type
 */
class BasicRoom extends ObjectType
{

    public function __construct(array $_config = [], $type = null)
    {
        if (is_null($type)) {
            /** @var Types $type */
            $type = new Types();
        }
        $config = [
            'description' => "直播活动基本信息 每个条目对应一个活动",
            'fields' => []
        ];
        $config['fields']['room_status'] = [
            'type' => $type::nonNull($type::RoomStatusEnum()),
            'description' => "直播活动状态 正常 normal, 冻结 frozen, 删除 deleted",
        ];
        $config['fields']['room_id'] = [
            'type' => $type::nonNull($type::ID()),
            'description' => "直播活动 唯一id",
        ];
        $config['fields']['room_title'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "直播活动标题",
        ];
        $config['fields']['chat_topic'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "DMS topic 互动消息话题",
        ];
        $config['fields']['dms_sub_key'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "DMS sub_key 必须确保dms状态正常并且开启系统消息通知，",
        ];
        $config['fields']['dms_pub_key'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "DMS pub_key",
        ];
        $config['fields']['aodian_uin'] = [
            'type' => $type::nonNull($type::Int()),
            'description' => "奥点云 uin",
        ];
        $config['fields']['lss_app'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "流媒体 app",
        ];
        $config['fields']['stream'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "流媒体 stream",
        ];
        $config['fields']['playerConfig'] = [
            'type' => $type::PlayerConfigUnion(),
            'description' => "播放器配置",
            'args' => [
                'player_type' => [
                    'type' => $type::nonNull($type::String()),
                    'description' => "播放器类型",
                    'defaultValue' => "mpsplayer",
                ],
            ],
        ];
        $config['fields']['currentUser'] = [
            'type' => $type::CurrentUser([], $type),
            'description' => "当前登录用户信息 dms参数",
        ];
        $config['fields']['topicUser'] = [
            'type' => $type::TopicUserPagination([], $type),
            'description' => "分页查询话题用户列表",
            'args' => [
                'num' => [
                    'type' => $type::nonNull($type::Int()),
                    'description' => "每页数量",
                    'defaultValue' => 20,
                ],
                'page' => [
                    'type' => $type::nonNull($type::Int()),
                    'description' => "页数",
                    'defaultValue' => 1,
                ],
            ],
        ];
        $config['fields']['historyMsg'] = [
            'type' => $type::RoomMsgPagination([], $type),
            'description' => "分页查询房间历史消息",
            'args' => [
                'num' => [
                    'type' => $type::nonNull($type::Int()),
                    'description' => "每页数量",
                    'defaultValue' => 20,
                ],
                'page' => [
                    'type' => $type::nonNull($type::Int()),
                    'description' => "页数",
                    'defaultValue' => 1,
                ],
                'user_id' => [
                    'type' => $type::ID(),
                    'description' => "发送者用户id",
                    'defaultValue' => "",
                ],
                'msg_type' => [
                    'type' => $type::nonNull($type::MsgTypeEnum()),
                    'description' => "消息类型",
                ],
                'msg_status' => [
                    'type' => $type::nonNull($type::MsgStatusEnum()),
                    'description' => "消息状态",
                ],
                'trade_type' => [
                    'type' => $type::String(),
                    'description' => "礼物消息 交易类型 TODO",
                    'defaultValue' => "",
                ],
                'msg_id_s' => [
                    'type' => $type::ID(),
                    'description' => "消息id开始，默认为0",
                    'defaultValue' => 0,
                ],
                'msg_id_e' => [
                    'type' => $type::ID(),
                    'description' => "消息id结束，默认为0",
                    'defaultValue' => 0,
                ],
                'timestamp_s' => [
                    'type' => $type::String(),
                    'description' => "时间字符串 开始 格式为 2012-03-04 05:06:07",
                    'defaultValue' => "",
                ],
                'timestamp_e' => [
                    'type' => $type::String(),
                    'description' => "时间字符串 结束",
                    'defaultValue' => "",
                ],
                'direction' => [
                    'type' => $type::String(),
                    'description' => "排序顺序 asc 或 desc",
                    'defaultValue' => "asc",
                ],
                'field' => [
                    'type' => $type::String(),
                    'description' => "排序依据字段",
                    'defaultValue' => "msg_id",
                ],
            ],
        ];
        $config['fields']['contentTabConfig'] = [
            'type' => $type::ContentTabConfig([], $type),
            'description' => "直播间切换tab栏配置",
        ];
        $config['fields']['chatConfig'] = [
            'type' => $type::ChatConfig([], $type),
            'description' => "聊天互动配置",
        ];
        $config['fields']['present_topic'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "用户进出房间 话题",
        ];
        $config['fields']['sync_room_topic'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "同步房间数据 话题",
        ];
        $config['fields']['sync_user_topic'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "同步用户数据 话题",
        ];
        $config['fields']['sys_notify_lss_topic'] = [
            'type' => $type::nonNull($type::String()),
            'description' => "流媒体直播消息 话题",
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