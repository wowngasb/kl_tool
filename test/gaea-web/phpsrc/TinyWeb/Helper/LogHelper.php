<?php

namespace TinyWeb\Helper;

/*
 *  日志辅助类  需要 LOG_PATH 常量 指定日志存放目录 LOG_LEVEL 表示记录级别的字符串
 *  日志记录器(Logger)是日志处理的核心组件。log4j具有5种正常级别(Level)。:
 *  1.static Level DEBUG :
 *  DEBUG Level 指出 细粒度信息事件对调试应用程序是非常有帮助的。
 *  2.static Level INFO
 *  INFO level 表明 消息在粗粒度级别上突出强调应用程序的运行过程。
 *  3.static Level WARN
 *  WARN level 表明 会出现潜在错误的情形。
 *  4.static Level ERROR
 *  ERROR level 指出 虽然发生错误事件，但仍然不影响系统的继续运行。
 *  5.static Level FATAL
 *  FATAL level 指出 每个严重的错误事件将会导致应用程序的退出。
 *
 *  另外，还有两个可用的特别的日志记录级别:
 *  1.static Level ALL
 *  ALL Level是最低等级的，用于打开所有日志记录。
 *  2.static Level OFF
 *  OFF Level是最高等级的，用于关闭所有日志记录。
*/
use TinyWeb\Application;

class LogHelper
{

    private static $log_level_dict = [
        'ALL' => 0,
        'DEBUG' => 10,
        'INFO' => 20,
        'WARN' => 30,
        'ERROR' => 40,
        'FATAL' => 50,
        'OFF' => 60,
    ];
    private static $m_instance_dict = [];

    private $log_path = null;
    private $log_level = 'INFO';
    private $module = 'sys_log';

    /**
     * 单实例模式
     * @param string $module
     * @return $this
     */
    public static function create($module = 'sys_log')
    {
        if (isset(self::$m_instance_dict[$module]) || !empty(self::$m_instance_dict[$module])) {
            return self::$m_instance_dict[$module];
        } else {
            self::$m_instance_dict[$module] = new self($module, null, null);
            return self::$m_instance_dict[$module];
        }
    }

    public function __construct($module = 'sys_log', $log_path = null, $log_level = null)
    {
        $this->module = is_null($module) ? $this->module : $module;
        $this->log_path = is_null($log_path) ? Application::getInstance()->getEnv('LOG_PATH') : $log_path;
        $this->log_level = is_null($log_level) ? Application::getInstance()->getEnv('LOG_LEVEL', $this->log_level) : $log_level;
    }

    public function debug($content)
    {
        return $this->writeLog($content, 'DEBUG');
    }

    public function info($content)
    {
        return $this->writeLog($content, 'INFO');
    }

    public function warn($content)
    {
        return $this->writeLog($content, 'WARN');
    }

    public function error($content)
    {
        return $this->writeLog($content, 'ERROR');
    }

    public function fatal($content)
    {
        return $this->writeLog($content, 'FATAL');
    }

    /**
     * 以指定级别写日志
     * @param string $content
     * @param string $type
     * @return string
     */
    public function writeLog($content, $type = 'INFO')
    {
        $type = strtoupper($type);
        $level = isset(self::$log_level_dict[$type]) ? self::$log_level_dict[$type] : -1;
        $level = ($level >= 10 && $level <= 50) ? $level : -10;
        $level_need = isset(self::$log_level_dict[$this->log_level]) ? self::$log_level_dict[$this->log_level] : 30;  //未指定日志级别时只记录WARN及以上信息
        if ($level < $level_need) {  //级别低于当前级别直接返回空字符串
            return '';
        }

        $logPath = $this->log_path . '/' . $this->module;

        if (!is_dir($logPath)) {
            mkdir($logPath, 0777, true);
        }
        $file = $logPath . '/' . date('Y-m-d') . '.log';
        $content = date('Y-m-d H:i:s') . " [{$type}] {$content}\n";
        file_put_contents($file, $content, FILE_APPEND | LOCK_EX);
        return $content;
    }

    /**
     * 遍历文件夹 得到目录结构
     * @param string $path
     * @param string $base_path
     * @return array
     */
    public static function getLogPathArray($path = '', $base_path = '')
    {
        $LOG_PATH = Application::getInstance()->getEnv('LOG_PATH');
        if (empty($path)) {
            $path = $LOG_PATH;
            $base_path = $path;
        }
        if (!is_dir($path) || !is_readable($path)) {
            return [];
        }

        $result = [];
        $temp = [];
        $allfiles = scandir($path);  //获取目录下所有文件与文件夹 
        foreach ($allfiles as $key => $filename) {  //遍历一遍目录下的文件与文件夹 
            if ($filename == '.' || $filename == '..') {
                continue;
            }
            $fullname = $path . '/' . $filename;  //得到完整文件路径
            $file_item = [
                'name' => $filename,
                'fullname' => $fullname,
                'ctime' => filectime($fullname),
                'mtime' => filemtime($fullname),
                'path' => str_replace($base_path, '', $fullname),
            ];
            if (is_dir($fullname)) { //是目录的话继续递归
                $file_item['type'] = 'dir';
                $file_item['sub'] = self::getLogPathArray($fullname, $base_path);
                $file_item['size'] = 0;
                foreach ($file_item['sub'] as $k => $v) {
                    $file_item['size'] += $v['size'];
                }
                $result[] = $file_item;
            } else if (is_file($fullname)) {
                $file_item['type'] = 'file';
                $file_item['size'] = filesize($fullname);
                $temp[] = $file_item;
            }
        }

        foreach ($temp as $key => $tmp) {
            $result[] = $tmp; //这样可以让文件夹排前面，文件在后面 
        }
        return $result;
    }

    /**
     * 读取指定日志文件内容
     * @param $path
     * @return string
     */
    public static function readLogByPath($path)
    {
        $LOG_PATH = Application::getInstance()->getEnv('LOG_PATH');
        $file = $LOG_PATH . $path;
        if (strpos($file, '..') !== false || empty($path)) {
            return '';  //防止恶意访问 只允许访问log文件夹下文件
        }
        if (is_file($file)) {
            $file_str = file_get_contents($file);
            return $file_str;
        } else {
            return '';
        }
    }

    /**
     * 清空当前文件内容 把原日志文件备份 只可操作 今天的日志
     * @param $path
     * @return bool
     */
    public static function clearLogByPath($path)
    {
        $LOG_PATH = Application::getInstance()->getEnv('LOG_PATH');
        $file = $LOG_PATH . $path;
        if (strpos($file, '..') > 0 || empty($path)) {
            return false;  //防止恶意访问 只允许访问log文件夹下文件
        }
        if (is_file($file)) {
            $new_path = $path . '.' . time();
            $content = date('Y-m-d H:i:s') . " [WARN] superAdmin cut this file by syslog, rename file：{$new_path}\n";
            file_put_contents($file, $content, FILE_APPEND | LOCK_EX);
            usleep(100 * 1000);  //暂停一下等待文件关闭
            $test = @rename($file, $LOG_PATH . $new_path) ? true : false;
            if ($test) {
                $content = date('Y-m-d H:i:s') . " [WARN] superAdmin cut last file by syslog, last file：{$new_path}\n";
                file_put_contents($file, $content, FILE_APPEND | LOCK_EX);
            }
            return $test;
        } else {
            return false;
        }
    }

} 