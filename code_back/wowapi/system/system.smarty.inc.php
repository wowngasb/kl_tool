<?php
require("smarty/smarty/libs/Smarty.class.php");

class SmartyProject extends Smarty {

	function __construct($array_sql_in = null, $is_sina = true ) {
		parent::__construct();

		if ($array_sql_in) {
			$this->left_delimiter = $array_sql_in['left_delimiter'];
	        $this->right_delimiter= $array_sql_in['right_delimiter'];
			$this->compile_dir = $array_sql_in['compile_dir'];			// For SAE �����ļ������memcache��
			$this->cache_dir = $array_sql_in['cache_dir'];
			$this->compile_locking = $array_sql_in['compile_locking'];	// ��ֹ����touch,saemc���Զ�����ʱ�䣬����Ҫtouch
			$this->template_dir = $array_sql_in['template_dir'];
			$this->config_dir = $array_sql_in['config_dir'];
		}
	}
	
} 


?>