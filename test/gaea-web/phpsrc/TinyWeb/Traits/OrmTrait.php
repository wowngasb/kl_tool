<?php
/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017/3/14 0014
 * Time: 18:20
 */

namespace TinyWeb\Traits;

use TinyWeb\Application;
use TinyWeb\Exception\OrmStartUpError;
use TinyWeb\Helper\DbHelper;
use TinyWeb\OrmQuery\AbstractQuery;
use TinyWeb\OrmQuery\OrmConfig;
use TinyWeb\OrmQuery\Select;

/**
 * Class BaseOrmModel
 * array $where  检索条件数组 格式为 dict 每个元素都表示一个检索条件  条件之间为 and 关系
 * ① [  `filed` => `value`, ]
 *    key不为数值，value不是数组   表示 某个字段为某值的 where = 检索
 *    例如 ['votes' => 100, ]  对应 ->where('votes', '=', 100)
 * ② [  `filed` => [``, ``], ]
 *    key不为数值的元素 表示 某个字段为某值的 whereIn 检索
 *    例如 ['id' => [1, 2, 3], ] 对应  ->whereIn('id', [1, 2, 3])
 * ③ [ [``, ``], ]
 *    key为数值的元素 表示 使用某种检索
 * 例如 [   ['whereBetween', 'votes', [1, 100]],  ]   对应  ->whereBetween('votes', [1, 100])
 * 例如 [   ['whereIn', 'id', [1, 2, 3]],  ]   对应  ->whereIn('id', [1, 2, 3])
 * 例如 [   ['whereNull', 'updated_at'],  ]   对应  ->whereNull('updated_at')
 * ② [  `filed` => AbstractQuery, ]
 *    key不为数值的元素 value是 AbstractQuery 表示 某个字段为 AbstractQuery 定义的检索
 * 例如 [   'votes' => whereBetween([1, 100])  ]   对应  ->whereBetween('votes', [1, 100])
 * 例如 [   'id' => whereIn([1, 2, 3])  ]   对应  ->whereIn('id', [1, 2, 3])
 * 例如 [   'updated_at' => whereNull() ],  ]   对应  ->whereNull('updated_at')
 * 注意：
 * $_REDIS_PREFIX_DB 下级数据缓存 建议只用数据表级缓存
 * 同一分类下的缓存数据必须来源于同一张表  不可缓存连表数据 防止无法分析依赖
 * 缓存的key 需要自己生成有意义的字符串 及 匹配清除缓存的 匹配字符串
 * @package TinyWeb\Traits
 */
trait OrmTrait
{
    use CacheTrait, LogTrait;

    protected static $_CACHE_PREFIX_DB = 'DbCache';

    private static $_db = null;
    private static $_cache_dict = [];

    protected static $_orm_config = null;


    ####################################
    ############ 获取配置 ##############
    ####################################


    /**
     * @param array $where 检索条件数组 具体格式参见文档
     * @return \Illuminate\Database\Query\Builder
     */
    protected static function tableItem(array $where = [])
    {
        $table_name = static::getOrmConfig()->table_name;
        $table = static::_getDb()->table($table_name);
        if (empty($where)) {
            return $table;
        }
        $query_list = [];
        foreach ($where as $key => $item) {
            if (is_integer($key) && is_array($item)) {
                $tag = $item[0];
                $query = array_slice($item, 1);
                $query_list[] = [$tag, $query];
            } else if ($item instanceof AbstractQuery) {
                $query_list[] = $item->buildQuery($key);  //list($enable, $action, $query)
            } else {
                if (is_array($item)) {
                    $tag = 'whereIn';
                    $query = [$key, $item];
                } else {
                    $tag = 'where';
                    $query = [$key, '=', $item];
                }
                $query_list[] = [true, $tag, $query];
            }
        }
        foreach ($query_list as $query_item) {
            if (empty($query_item)) {
                continue;
            }
            list($enable, $tag, $query) = $query_item; //只有 $enable 为 true 的情况下 条件才会生效
            if (!$enable) {
                continue;
            }
            call_user_func_array([$table, $tag], $query);
        }
        return $table;
    }


    /**
     * 使用这个特性的子类必须 实现这个方法 返回特定格式的数组 表示数据表的配置
     * @return OrmConfig
     */
    protected static function getOrmConfig()
    {
        if (is_null(static::$_orm_config)) {
            static::$_orm_config = new OrmConfig('', '');
        }
        return static::$_orm_config;
    }

    ####################################
    ############ 可重写方法 #############
    ####################################

    /**
     * 根据主键获取数据 自动使用缓存
     * @param $id
     * @param string $action
     * @return array|null
     * @throws OrmStartUpError
     */
    public static function getDataById($id, $action = 'load')
    {
        $cfg = static::getOrmConfig();
        $tag = $cfg->buildSelectTag([$cfg->primary_key => $id]);
        $select = new Select($cfg, $tag, function () use ($id) {
            $tmp = static::getItem($id);
            return $tmp;
        }, function ($data) use ($cfg) {
            return !empty($data) ? $cfg->cache_time : 1;
        });
        $data = self::runSelect($select, $action);
        return $data;
    }

    /**
     * 根据主键更新数据 自动更新缓存
     * @param $id
     * @param array $data
     * @return array 返回更新后的数据
     */
    public static function setDataById($id, array $data)
    {
        $id = intval($id);
        if ($id <= 0) {
            return [];
        }
        if (!empty($data)) {
            static::getItem($id, $data);
        }
        return self::getDataById($id, 'fresh');
    }

    /**
     * 添加新数据 自动更新缓存
     * @param array $data
     * @return array
     */
    public static function newDataItem(array $data)
    {
        if (!empty($data)) {
            $id = static::newItem($data);
            return self::getDataById($id, 'fresh');
        } else {
            return [];
        }
    }

    /**
     * @param $val
     * @return mixed
     */
    protected static function _fixItem($val)
    {
        return (array)($val);
    }

    ####################################
    ############ 辅助函数 ##############
    ####################################

    /**
     * 运行查询 并给出缓存的key 缓存结果  默认只缓存非空结果
     * @param Select $select
     * @param string $action
     * @param string $prefix
     * @param bool $is_log
     * @return array
     * @throws OrmStartUpError
     */
    protected static function runSelect(Select $select, $action = 'load', $prefix = null, $is_log = false)
    {
        $prefix = !is_null($prefix) ? $prefix : static::$_CACHE_PREFIX_DB;
        return static::_cacheDataManager($select->method, $select->key, $select->func, $select->filter, $action, $select->tags, $prefix, $is_log);
    }

    ####################################
    ############ 辅助函数 ##############
    ####################################

    /**
     * 根据主键获取某个字段的值
     * @param string $name
     * @param int $id
     * @param mixed $default
     * @return mixed
     */
    public static function getFiledById($name, $id, $default = null)
    {
        $tmp = self::getDataById($id);
        return isset($tmp[$name]) ? $tmp[$name] : $default;
    }

    /**
     * @return \Illuminate\Database\Connection
     * @throws OrmStartUpError
     */
    private static function _getDb()
    {
        if (!empty(self::$_db)) {
            return self::$_db;
        }
        $cfg = static::getOrmConfig();
        if (empty($cfg->table_name) || empty($cfg->primary_key) || empty($cfg->max_select) || empty($cfg->db_name)) {
            throw new OrmStartUpError('Orm:' . __CLASS__ . 'with error config');
        }
        self::$_db = DbHelper::initDb()->getConnection($cfg->db_name);
        return self::$_db;
    }

    protected static function debugSql($time, $sql, $param, $tag = 'sql')
    {
        $db_name = static::getOrmConfig()->db_name;
        $table_name = static::getOrmConfig()->table_name;

        $sql_str = static::showQuery($sql, $param);
        $use_str = round($time * 1000, 2) . 'ms';
        self::debug("SQL({$use_str}) {$sql_str}", $tag, __CLASS__, __LINE__);
        $_tag = str_replace(__TRAIT__, "SQL >> {$db_name}.{$table_name}({$use_str})", $tag);
        Application::_D($sql_str, $_tag);
    }

    protected static function showQuery($query, $params)
    {
        $keys = [];
        $values = [];

        # build a regular expression for each parameter
        foreach ($params as $key => $value) {
            if (is_string($key)) {
                $keys[] = '/:' . $key . '/';
            } else {
                $keys[] = '/[?]/';
            }
            if (is_numeric($value)) {
                $values[] = intval($value);
            } else {
                $values[] = '"' . $value . '"';
            }
        }
        $query = preg_replace($keys, $values, $query, 1, $count);
        return $query;
    }

    ####################################
    ########### 条目操作函数 ############
    ####################################

    /**
     * 查询数据总量
     * @param array $where 检索条件数组 具体格式参见文档
     * @param array $columns 需要获取的列 格式为[`column_1`, ]  默认为所有
     * @return int  数据条目数
     */
    public static function countItem(array $where = [], array $columns = ['*'])
    {
        $start_time = microtime(true);
        $table = static::tableItem($where);
        $count = $table->count($columns);
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);
        return $count;
    }

    /**
     * 分页查询数据  不允许超过最大数量限制
     * @param int $start 起始位置 skip
     * @param int $limit 数量限制 take 上限为 $this->_max_select_item_counts
     * @param array $sort_option 排序依据 格式为 [`field` => `column`, `direction` => `asc|desc`]
     * @param array $where 检索条件数组 具体格式参见文档
     * @param array $columns 需要获取的列 格式为[`column_1`, ]  默认为所有
     * @return array 数据 list 格式为 [`item`, ]
     */
    public static function selectItem($start = 0, $limit = 0, array $sort_option = [], array $where = [], array $columns = ['*'])
    {
        $start_time = microtime(true);
        $max_select = static::getOrmConfig()->max_select;
        $table = static::tableItem($where);
        $start = $start <= 0 ? 0 : $start;
        $limit = $limit > $max_select ? $max_select : $limit;
        if ($start > 0) {
            $table->skip($start);
        }
        if ($limit > 0) {
            $table->take($limit);
        } else {
            $table->take($max_select);
        }
        if (!empty($sort_option['field']) && !empty($sort_option['direction'])) {
            $table->orderBy($sort_option['field'], $sort_option['direction']);
        }
        $data = $table->get($columns);
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);

        $rst = [];
        foreach ($data as $key => $val) {
            $val = (array)$val;
            $rst[$key] = static::_fixItem($val);
        }
        return $rst;
    }

    /**
     * 获取以主键为key的dict   不允许超过最大数量限制
     * @param array $where 检索条件数组 具体格式参见文档
     * @param array $columns 需要获取的列 格式为[`column_1`, ]  默认为所有
     * @return array 数据 dict 格式为 [`item.primary_key` => `item`, ]
     */
    public static function dictItem(array $where = [], array $columns = ['*'])
    {
        $start_time = microtime(true);
        $max_select = static::getOrmConfig()->max_select;
        $primary_key = static::getOrmConfig()->primary_key;
        $table = static::tableItem($where);
        $table->take($max_select);
        $data = $table->get($columns);
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);

        $rst = [];
        foreach ($data as $key => $val) {
            $val = (array)$val;
            $id = $val[$primary_key];
            $rst[$id] = static::_fixItem($val);
        }
        return $rst;
    }

    /**
     * 根据某个字段的值 获取第一条记录
     * @param mixed $value 需匹配的字段的值
     * @param string $filed 字段名 默认为 null 表示使用主键
     * @param array $columns 需要获取的列 格式为[`column_1`, ]  默认为所有
     * @return array
     */
    public static function getItem($value, $filed = null, array $columns = ['*'])
    {
        $primary_key = static::getOrmConfig()->primary_key;
        $filed = $filed ?: $primary_key;
        return static::firstItem([strtolower($filed) => $value], $columns);
    }

    /**
     * 根据查询条件 获取第一条记录
     * @param array $where 检索条件数组 具体格式参见文档
     * @param array $columns 需要获取的列 格式为[`column_1`, ]  默认为所有
     * @return array
     */
    public static function firstItem(array $where, array $columns = ['*'])
    {
        $start_time = microtime(true);
        $table = static::tableItem($where);
        $item = $table->first($columns);
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);
        return static::_fixItem((array)$item);
    }

    /**
     * 插入数据 返回插入的自增id
     * @param array $data 数据[`filed` => `value`, ]
     * @return int
     */
    public static function newItem(array $data)
    {
        $start_time = microtime(true);
        $primary_key = static::getOrmConfig()->primary_key;
        unset($data[$primary_key]);
        $default = [
        ];
        $data = array_merge($default, $data);
        foreach ($data as $key => $value) {
            if (is_array($value)) {
                $data[$key] = json_encode($value);
            }
        }
        $table = static::tableItem();
        $id = $table->insertGetId($data, $primary_key);
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);
        return $id;
    }

    /**
     * 根据主键修改数据
     * @param int $id 主键值
     * @param array $data 更新的数据 格式为 [`filed` => `value`, ]
     * @return int 操作影响的行数
     */
    public static function setItem($id, array $data)
    {
        $start_time = microtime(true);
        $primary_key = static::getOrmConfig()->primary_key;
        unset($data[$primary_key]);
        $table = static::tableItem()->where($primary_key, $id);
        $update = $table->update($data);
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);
        return $update;
    }

    /**
     * 根据主键删除数据
     * @param int $id 主键值
     * @return int 操作影响的行数
     */
    public static function delItem($id)
    {
        $start_time = microtime(true);
        $primary_key = static::getOrmConfig()->primary_key;
        $table = static::tableItem()->where($primary_key, $id);
        $delete = $table->delete();
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);
        return $delete;
    }

    /**
     * 根据主键增加某字段的值
     * @param int $id 主键id
     * @param string $filed 需要增加的字段
     * @param int $value 需要改变的值 默认为 1
     * @return int  操作影响的行数
     */
    public static function incItem($id, $filed, $value = 1)
    {
        $start_time = microtime(true);
        $primary_key = static::getOrmConfig()->primary_key;
        $table = static::tableItem()->where($primary_key, $id);
        $increment = $table->increment($filed, $value);
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);
        return $increment;
    }

    /**
     * 根据主键减少某字段的值
     * @param int $id 主键id
     * @param string $filed 需要减少的字段
     * @param int $value 需要改变的值 默认为 1
     * @return int  操作影响的行数
     */
    public static function decItem($id, $filed, $value = 1)
    {
        $start_time = microtime(true);
        $primary_key = static::getOrmConfig()->primary_key;
        $table = static::tableItem()->where($primary_key, $id);
        $decrement = $table->decrement($filed, $value);
        static::debugSql(microtime(true) - $start_time, $table->toSql(), $table->getBindings(), __METHOD__);
        return $decrement;
    }

    /**
     * 更新或插入数据  优先根据条件查询数据 无法查询到数据时插入数据
     * @param array $where 检索条件数组 具体格式参见文档
     * @param array $data 需要插入的数据  格式为 [`filed` => `value`, ]
     * @return int 返回数据 主键 自增id
     */
    public static function upsertItem(array $where, array $data)
    {
        $primary_key = static::getOrmConfig()->primary_key;
        $tmp = static::firstItem($where);
        if (empty($tmp)) {
            return static::newItem($data);
        } else {
            $id = $tmp[$primary_key];
            static::setItem($id, $data);
            return $id;
        }
    }
}