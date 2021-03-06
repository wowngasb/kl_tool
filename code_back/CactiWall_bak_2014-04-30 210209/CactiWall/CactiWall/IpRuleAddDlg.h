#pragma once
#include "afxwin.h"


typedef struct _PROTOCOL_TYPE_TABLE
{
    DWORD index;
    DWORD protocolType;
    TCHAR *name;
}PROTOCOL_TYPE_TABLE,*PPROTOCOL_TYPE_TABLE;

typedef struct _ICMP_TYPE_TABLE
{
    DWORD index;
    USHORT icmpType;
    TCHAR *name;
}ICMP_TYPE_TABLE,*PICMP_TYPE_TABLE;


static PROTOCOL_TYPE_TABLE  protocolType[7] = {
    {0,0,_T("任意")},
    {1,IPPROTO_TCP,_T("TCP")},
    {2,IPPROTO_UDP,_T("UDP")},
    {3,IPPROTO_ICMP,_T("ICMP")},
    {4,IPPROTO_IGMP,_T("IGMP")},
    {5,IPPROTO_AH,_T("AH")},
    {6,IPPROTO_RDP,_T("RDP")}
};

static ICMP_TYPE_TABLE  icmpType[16] = {
    {0,0,_T("回显应答")},
    {1,3,_T("目标不可达")},
    {2,4,_T("源端被关闭")},
    {3,5,_T("重定向")},
    {4,8,_T("请求回显")},
    {5,9,_T("路由器通告")},
    {6,10,_T("路由器请求")},
    {7,11,_T("超时")},
    {8,12,_T("参数错误")},
    {9,13,_T("时间戮请求")},
    {10,14,_T("时间戮应答")},
    {11,15,_T("信息请求")},
    {12,16,_T("信息应答")},
    {13,17,_T("地址掩码请求")},
    {14,18,_T("地址掩码应答")},
    {16,31,_T("任意类型")}
};

// CIpRuleAddDlg 对话框

class CIpRuleAddDlg : public CDialog
{
	DECLARE_DYNAMIC(CIpRuleAddDlg)

public:
	CIpRuleAddDlg(CWnd* pParent = NULL);   // 标准构造函数
	virtual ~CIpRuleAddDlg();

// 对话框数据
	enum { IDD = IDD_DIALOG_IPRULE_ADD };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持
    BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
public:
//控件相关变量
    CComboBox m_ComboProtoType;
    CComboBox m_ComboIcmpType;
    DWORD m_LocalAddr1;
    DWORD m_LocalAddr2;
    DWORD m_RemoteAddr1;
    DWORD m_RemoteAddr2;
    DWORD m_LocalPort1;
    DWORD m_LocalPort2;
    DWORD m_RemotePort1;
    DWORD m_RemotePort2;
    BYTE m_IcmpType;
    BYTE m_IcmpCode;
    CString m_RuleName;

//自定义变量
    BOOL m_bAllow;
	BYTE m_Reserved;

    BYTE m_Direction;
    BYTE m_LocalAddrType;
    BYTE m_RemoteAddrType;
    BYTE m_LocalPortType;
    BYTE m_RemotePortType;
    BYTE m_ProtocolType;
    CString m_Title;

//消息映射函数
    afx_msg void OnBnClickedRadioAllow();
    afx_msg void OnBnClickedRadioAnydirection();
    afx_msg void OnBnClickedRadioUpdirection();
    afx_msg void OnBnClickedRadioDowndirection();
    afx_msg void OnBnClickedRadioLocalAnyip();
    afx_msg void OnBnClickedRadioLocalUniqueip();
    afx_msg void OnBnClickedRadioLocalRangeip();
    afx_msg void OnBnClickedRadioRemoteAnyip();
    afx_msg void OnBnClickedRadioRemoteUniqueip();
    afx_msg void OnBnClickedRadioRemoteRangeip();
    afx_msg void OnCbnSelchangeComboProtocoltype();
    afx_msg void OnBnClickedRadioLocalAnyport();
    afx_msg void OnBnClickedRadioLocalUniqueport();
    afx_msg void OnBnClickedRadioLocalRangeport();
    afx_msg void OnBnClickedRadioRemoteAnyport();
    afx_msg void OnBnClickedRadioRemoteUniqueport();
    afx_msg void OnBnClickedRadioRemoteRangeport();
    afx_msg void OnBnClickedOk();
    afx_msg void OnCbnSelchangeComboIcmptype();
	afx_msg void OnBnClickedRadioRewrite();
	afx_msg void OnBnClickedRadioDeny();
};
                                    