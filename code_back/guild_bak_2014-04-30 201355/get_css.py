#-*- coding: utf-8 -*-

import sys,os,datetime,urllib2,re,urllib
from urlparse import urlparse
import chardet
import sqlite3

def read_file(in_file):
    try:
        fo = open(in_file, 'r')
        str_css = fo.read()
    except Exception, ex:
        print Exception,':',ex
    finally:
        if fo: fo.close()
    return str_css

def write_file(in_file, str_css):
    try:
        fo = open(in_file, 'w')
        fo.write(str_css)
    except Exception, ex:
        print Exception,':',ex
    finally:
        if fo: fo.close()

def read_url(in_url):
    str_css = ''
    try:
        req = urllib2.Request(in_url)
        str_css = urllib2.urlopen(req).read()
    except Exception, ex:
        print Exception,':',ex
    finally:
        pass
    return str_css


def get_url_path(in_url, in_path=None):
    url_path = None
    in_url = in_url if in_url else ''
    try:
        in_url = 'http://' + in_url if '://' not in in_url else in_url
        url_path = _get_url_path(in_url, in_path) if in_url[:in_url.index('://')] in ('http','https','ftp') else None
    except Exception, ex:
        print '\n','get_url_path err:', in_url, '->', ex
    return url_path

def _get_url_path(in_url, in_path):
    in_path = in_path if (in_path) else os.getcwd()
    if not os.path.exists(in_path): os.makedirs(in_path)
    de_url = in_url
    if '%' in in_url:
        de_url = url_decode_str(in_url)

    url = urlparse(de_url)
    url.in_url = in_url
    url.de_url = de_url

    url.fix_path = url.path
    if url.fix_path=='' or  url.fix_path[:1]!='/':
        url.fix_path = '/' + url.fix_path
    if '.' not in url.fix_path[url.fix_path.rindex("/")+1:] and url.fix_path[-1:]!='/':
        url.fix_path = url.fix_path + '/'

    while '/...' in url.fix_path or '/ ' in url.fix_path or '//' in url.fix_path or '/. ' in url.fix_path or '/.. ' in url.fix_path:
        url.fix_path = url.fix_path.replace('/...', '/..').replace('/ ', '/').replace('//', '/').replace('/. ', '/.').replace('/.. ', '/..')

    url.split_list = url.fix_path.split('/')
    i = 0L
    while i < len(url.split_list):
        if url.split_list[i] == '.':
            del url.split_list[i]
            i -= 1
        if url.split_list[i] == ' ':
            del url.split_list[i]
            i -= 1
        if url.split_list[i] == '..' :
            del url.split_list[i]
            if url.split_list[i-1]!='':
                del url.split_list[i-1]
                i -= 1
            i -= 1
        i += 1

    url.fix_path = '/'.join(url.split_list)

    try:
        url.fix_url = url.in_url.replace('%s://%s%s' % (url.scheme, url.netloc, url.path), '%s://%s%s' % (url.scheme, url.netloc, url_encode_str(url.fix_path)), 1)
    except:
        url.fix_url = url.in_url.replace('%s://%s%s' % (url.scheme, url.netloc, url.path), '%s://%s%s' % (url.scheme, url.netloc, url.fix_path), 1)

    try:
        #print url.fix_path.decode("utf-8").encode("gbk")
        url.fix_path = strToUnicode(url.fix_path, 'utf-8')
    except Exception, ex:
        print '\n','url decode err:', url.fix_path, '->', ex

    url.baseurl = url.fix_url.split('?')[0].split('#')[0]
    url.baseurl = url.baseurl[:url.baseurl.rindex("/")+1]
    url.filename = url.fix_path[url.fix_path.rindex("/")+1:] if url.fix_path[-1:]!='/' else 'index.html'
    url.filetype = url.filename[url.filename.rindex(".")+1:].lower() if '.' in url.filename else ''
    url.save_path = os.path.join(in_path, url.hostname, url.fix_path[1:]) if url.fix_path[-1:]!='/' else os.path.join(in_path, url.hostname, url.fix_path[1:], 'index.html')
    url.save_path = os.path.abspath(url.save_path)
    url.save_dir = os.path.dirname(url.save_path)

    #print url.fix_url.decode("utf-8").encode("gbk")
    #if not os.path.exists(url.save_dir): os.makedirs(url.save_dir)
    return url

def url_decode_str(in_url):
    out_url = urllib.unquote(in_url)
    return out_url

def url_encode_str(in_url):
    out_url = urllib.quote(in_url)
    return out_url

def strToUnicode(html, decoding=None):
    if not isinstance(html, unicode):
        if not decoding:
            decoding, charJust = '', chardet.detect(html)
            try: 
                decoding = 'gbk' if charJust['encoding'].lower() == 'gb2312' else charJust['encoding']
            except Exception, e: 
                print 'strToUnicode chardet detect error:', Exception, '->', e
        decoding = 'utf-8' if not decoding else decoding
        if decoding: 
            html = html.decode(decoding, 'ignore')
    return html

def unicodeToStr(html, encoding='utf-8'):
    if not isinstance(html, unicode):
        decoding, charJust = '', chardet.detect(html)
        try: 
            decoding = 'gbk' if charJust['encoding'].lower() == 'gb2312' else charJust['encoding']
        except Exception, e: 
            print 'unicodeToStr chardet detect error:', Exception, '->', e
        if encoding and decoding and decoding!=encoding : 
            html = html.decode(decoding, 'ignore').encode(encoding, 'ignore')
    else:
        if encoding: html = html.encode(encoding, 'ignore')
    return html


def try_get_css(in_url, in_path = None, in_file = None):
    if not in_url: return -1
    in_path = in_path if (in_path) else os.getcwd()
    if not os.path.exists(in_path): os.makedirs(in_path)

    print '\n\n\n',datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S  "),"CSS Download ing -> ",in_url

    str_css = read_file(in_file) if in_file else read_url(in_url)
    if len(str_css)<1: return -2
    print datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S  "),"CSS Download :",str(len(str_css)),' byte'

    # use re parse css and findall url('images/xxx.gif')
    p = re.compile('background(.*?)url\((.*?)\)', re.IGNORECASE)
    g = p.findall(str_css)

    css_path = get_url_path(in_url, in_path)
    #write_file(os.path.join(in_path, css_path.filename+'.bak') , str_css)
    write_file(os.path.join(css_path.save_path) , str_css)

    print datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S  "),"img Download :",
    count_download = 0L
    for item in g:
        item_url = item[1]
        item_url = item_url.replace('"','').replace("'",'')
        item_url = os.path.join(css_path.baseurl, item_url) if item_url[0] == '.' else item_url
        item_url = os.path.join('http://', css_path.hostname, item_url[1:]) if item_url[0] == '/' else item_url
        url_path = get_url_path(item_url.replace('\\','/'), in_path)

        if not url_path:
            print '\n\n','ERROR url_path  url -> ',item_url
            continue
        if ';base64,' in url_path.in_url:
            print '\n\n','base64 png  url -> ',item_url
            continue
        if os.path.isfile(url_path.save_path):
            print url_path.filename,'(pass)',
            continue

        data =  None
        try:
            if not os.path.exists(url_path.save_dir): os.makedirs(url_path.save_dir)
            data = urllib.urlretrieve(url_path.in_url, url_path.save_path) if not os.path.isfile(url_path.save_path) else None
        except Exception, ex:
            try:
                data = urllib.urlretrieve(url_path.in_url, url_path.save_path) if not os.path.isfile(url_path.save_path) else None
            except Exception, ex:
                try:
                    data = urllib.urlretrieve(url_path.in_url, url_path.save_path) if not os.path.isfile(url_path.save_path) else None
                except Exception, ex:
                    print '\n', 'urlretrieve error:', ex, '\n','in_url:', url_path.in_url
        data_len = int(data[1]['content-length']) if data else 0L
        count_download = count_download + 1 if data else count_download
        print url_path.filename,'(%s)' % data_len,
        #str_css = str_css.replace(item[1] ,'"./%s%s"' % (url_path.hostname,url_path.path))

    #write_file(os.path.join(in_path, css_path.hostname, css_path.filename) , str_css)
    return count_download

def try_get_css_url_list(in_url, in_path):
    if not in_url: return -1L
    in_path = in_path if (in_path) else os.getcwd()
    if not os.path.exists(in_path): os.makedirs(in_path)

    print '\n',datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S  "),"Link DB ing... "

    url_path = get_url_path(in_url, in_path)
    if not url_path: return -2L

    db_dir = os.path.join(in_path, url_path.hostname)
    if not os.path.exists(db_dir): os.makedirs(db_dir)
    db_path = os.path.join(db_dir, url_path.hostname+'.web_download.db')

    return _get_css_url_list_from_db(db_path)


def _get_css_url_list_from_db(db_path, table_name='wdb_vlink', col_name='filetype'):
    db_conn = sqlite3.connect(db_path)
    if not db_conn: return None
    db_cursor = db_conn.cursor()

    res_url_list = []

    sql_cmd = 'select url from %s where %s="css" ' % (table_name, col_name)

    try:
        db_cursor.execute(sql_cmd)
        result = db_cursor.fetchall()
    except Exception, ex:
        print '\n', '_get_css_url_list_from_db error:', ex, '\n','sql_cmd:', sql_cmd

    for css_item in result:
        res_url_list.append( unicodeToStr(css_item[0]) )

    return res_url_list

def main():
    main_start = datetime.datetime.now()
    main_count = 0L
    print sys.argv[0] + ' >>'

    main_url = sys.argv[1] if len(sys.argv)>1 else None
    main_path = sys.argv[1] if len(sys.argv)>2 else None
    main_file = sys.argv[1] if len(sys.argv)>3 else None

    main_url = r'http://www.battlenet.com.cn/'
    css_url_list = try_get_css_url_list(main_url, main_path)
    #css_url_list = ["http://www.battlenet.com.cn/wow/static/css/wow.css?v=37",]

    for item_url in css_url_list:
        css_url = item_url
        main_count +=  try_get_css(css_url, main_path, main_file)

    print '\n',datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S  '),str(main_count),' items OVER!'
    main_end = datetime.datetime.now()
    print '\nUSE Time : ',str(main_end - main_start)

if __name__ == '__main__':
    main()