# -*- coding: utf-8 -*-
#-------------------------------------------------------------------------------
#https://pypi.tuna.tsinghua.edu.cn/simple
import os
import json

def main():
    config = load_json( cwd('server_config.ignore') )
    _config = ext_config(config)
    cfg = fix_config(_config)

    for key, item in cfg.items():
        dump_file(cwd(key+'.ttl'), connect_ttl(key, item))
        # dump_file(cwd('clear_log', key+'_clear.ttl'), clear_log_ttl(key, item))
        # dump_file(cwd('glances', key+'_glances.ttl'), glances_ttl(key, item))
        # dump_file(cwd('update', key+'_update.ttl'), update_ttl(key, item))

def cwd(*f):
    return os.path.join(os.getcwd(), *f)

def dump_file(file_name, str_list):
    if not os.path.isdir(os.path.dirname(file_name)):
        os.makedirs(os.path.dirname(file_name))
    with open(file_name, 'w') as wf:
        wf.writelines(str_list)
        print "write file:%s" % (file_name, )

def load_file(file_name):
    if not os.path.isfile(file_name):
        return ''
    with open(file_name, 'r') as rf:
        return rf.read()

def ext_config(config):
    del_set = set()
    for key, item in config.items():
        if isinstance(item['Host'], dict):
            del_set.add(key)
            for kport, iplist in item['Host'].items():
                for ip in set(iplist):
                    fix_key = (key if key.startswith('_') else key + '_')+ ip.split('.')[-2] + '_' + ip.split('.')[-1]
                    copy_item = dict(item)
                    copy_item['Host'] = ip + ':' + kport
                    config[fix_key] = copy_item

    for key in del_set:
        del config[key]

    return config

def load_json(file_name):
    with open(file_name, 'r') as rf:
        return json.load(rf)

def fix_config(cfg):
    rst, base_ini = {}, load_file( cwd('_tt_config_ini', 'TERATERM_TPL.INI') )
    for key, item in cfg.items():
        dump_file(cwd('_tt_config_ini', 'tmp', key+'.INI'), base_ini.replace('{{TPL_TITLE}}', key, 1))
        item.setdefault('Ini', cwd('_tt_config_ini', 'tmp', key+'.INI') )  # 生成自定义的配置文件
        item.setdefault('Prompt', '#' if item['User']=='root' else '$')  # 根据不同的帐号设置不同的命令行提示符
        item['FirstCmd'] = 'ps -ef | grep node' if key.find('node')>=0 else 'ps -ef | grep "nginx\|httpd"'
        if item.get('Sudo', None):
           item['Sudo'].setdefault('Prompt', '#' if item['Sudo']['User']=='root' else '$')
        rst[key] = item
    return rst

def _append(str_list, *str_append):
    str_list.extend(str_append)
    return str_list

def base_ttl(key, item):
    if item['Password'].endswith('.pem'):
        connect_cmd = """
;++++++++++++++++++++++++++++++++++++++++++++
tmp_connect_cmd = ''
strconcat tmp_connect_cmd SET_Host
strconcat tmp_connect_cmd ' /ssh /2 /auth=publickey '
strconcat tmp_connect_cmd ' /user='
strconcat tmp_connect_cmd SET_User
strconcat tmp_connect_cmd ' /keyfile='
strconcat tmp_connect_cmd SET_Password
strconcat tmp_connect_cmd ' /f='
strconcat tmp_connect_cmd SET_Ini
connect tmp_connect_cmd
"""
    else:
        connect_cmd = """
;++++++++++++++++++++++++++++++++++++++++++++
tmp_connect_cmd = ''
strconcat tmp_connect_cmd SET_Host
strconcat tmp_connect_cmd ' /ssh /2 /auth=password'
strconcat tmp_connect_cmd ' /user='
strconcat tmp_connect_cmd SET_User
strconcat tmp_connect_cmd ' /passwd='
strconcat tmp_connect_cmd SET_Password
strconcat tmp_connect_cmd ' /f='
strconcat tmp_connect_cmd SET_Ini
connect tmp_connect_cmd
"""

    tmp_list = [
        "SET_Title ='%s' \n" % (key, ),
        "SET_Prompt = '%s' \n" % (item['Prompt'], ),
        "SET_Host = '%s' \n" % (item['Host'], ),
        "SET_User = '%s' \n" % (item['User'], ),
        "SET_Password = '%s' \n" % (item['Password'], ),
        "SET_Ini = '%s' \n" % (item['Ini'], ),
        "SET_FirstCmd  = '%s' \n" % (item['FirstCmd'], ),
        "SET_WorkPath = '%s' \n" % (item['WorkPath'], ),
        connect_cmd,
    ]
    if item.get('Sudo', None):
        tmp_list.extend([
            "wait SET_Prompt \n",
            "sendln 'su %s' \n" % (item['Sudo']['User'], ),
            "wait 'Password:' \n",
            "sendln '%s' \n" % (item['Sudo']['Password'], ),
            "SET_Prompt = '%s' \n" % (item['Sudo']['Prompt'], ),
        ])
    return tmp_list

def connect_ttl(key, item):
    return _append(base_ttl(key, item), """
;++++++++++++++++++++++++++++++++++++++++++++
tmp_cd_cmd = 'cd '
strconcat tmp_cd_cmd SET_WorkPath

wait SET_Prompt
sendln SET_FirstCmd
wait SET_Prompt
sendln tmp_cd_cmd
wait SET_Prompt
sendln 'pwd'
wait SET_Prompt
sendln 'git branch -a'
wait SET_Prompt
sendln 'pwd'
wait SET_Prompt
sendln 'git log -1'
wait SET_Prompt
;++++++++++++++++++++++++++++++++++++++++++++
settitle SET_Title
restoresetup SET_Ini
""")

def clear_log_ttl(key, item):
    return _append(base_ttl(key, item), """
;++++++++++++++++++++++++++++++++++++++++++++
tmp_cd_cmd = 'cd '
strconcat tmp_cd_cmd SET_WorkPath

wait SET_Prompt
sendln tmp_cd_cmd
wait SET_Prompt
sendln 'pwd'
wait SET_Prompt
sendln 'rm -rf ./log/*'
wait SET_Prompt
;++++++++++++++++++++++++++++++++++++++++++++
settitle SET_Title
restoresetup SET_Ini
disconnect
closett
""")

def glances_ttl(key, item):
    return _append(base_ttl(key, item), """
;++++++++++++++++++++++++++++++++++++++++++++
tmp_cd_cmd = 'cd '
strconcat tmp_cd_cmd SET_WorkPath

wait SET_Prompt
sendln tmp_cd_cmd
wait SET_Prompt
sendln 'netstat -apn | grep 61208  '
wait SET_Prompt
sendln 'glances -w'
wait '61208'
""", 'exec "explorer http://%s:%d"' % (item['Host'].split(':')[0], 61208), """
;++++++++++++++++++++++++++++++++++++++++++++
settitle SET_Title
restoresetup SET_Ini
disconnect
""" )

def update_ttl(key, item):
    return _append(base_ttl(key, item), """
;++++++++++++++++++++++++++++++++++++++++++++
tmp_cd_cmd = 'cd '
strconcat tmp_cd_cmd SET_WorkPath

wait SET_Prompt
sendln tmp_cd_cmd
wait SET_Prompt
sendln 'pwd'
wait SET_Prompt
sendln './update.sh'
wait 'clear:'
wait SET_Prompt
;++++++++++++++++++++++++++++++++++++++++++++
settitle SET_Title
restoresetup SET_Ini
disconnect
closett
""")

if __name__ == '__main__':
    main()
