#define DLL_API extern "C" _declspec(dllexport)
#include "dll.h"
#include <stdio.h>
#include <string.h>

#define MAX_BUFFER_SIZE 8192
#define FILE_BUFFER_SIZE 1024*1024
#define FILE_MAX_SIZE 64*1024*1024

#define S11 7
#define S12 12
#define S13 17
#define S14 22
#define S21 5
#define S22 9
#define S23 14
#define S24 20
#define S31 4
#define S32 11
#define S33 16
#define S34 23
#define S41 6
#define S42 10
#define S43 15
#define S44 21

#define F(x, y, z) (((x) & (y)) | ((~x) & (z)))
#define G(x, y, z) (((x) & (z)) | ((y) & (~z)))
#define H(x, y, z) ((x) ^ (y) ^ (z))
#define I(x, y, z) ((y) ^ ((x) | (~z)))

#define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32-(n))))

#define FF(a, b, c, d, x, s, ac) { \
 (a) += F ((b), (c), (d)) + (x) + (unsigned long)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }
#define GG(a, b, c, d, x, s, ac) { \
 (a) += G ((b), (c), (d)) + (x) + (unsigned long)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }
#define HH(a, b, c, d, x, s, ac) { \
 (a) += H ((b), (c), (d)) + (x) + (unsigned long)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }
#define II(a, b, c, d, x, s, ac) { \
 (a) += I ((b), (c), (d)) + (x) + (unsigned long)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }

typedef struct {
  unsigned long state[4];                                  
  unsigned long count[2];        
  unsigned char buffer[64];                        
} MD5_CTX;

void MD5Transform (unsigned long state[4],unsigned  char block[64]);
void Encode (unsigned char *output, unsigned long *input, unsigned int len);
void Decode (unsigned long *output, unsigned char *input, unsigned int len);
void MD5_memcpy (unsigned char *output, unsigned char *input, unsigned int charlen);
void MD5_memset (unsigned char *output, int vavle, unsigned int charlen);

void MD5Init (MD5_CTX *context);
void MD5Update (MD5_CTX *context,unsigned char *input,unsigned int inputLen);
void MD5Final (unsigned char digest[16], MD5_CTX *context);

bool _stdcall addMD5(LPSTR md5str,LPSTR astr,long sta,long end);


char buffer[MAX_BUFFER_SIZE];
unsigned char MD5buffer[17];
MD5_CTX xmd5[10];
int xmds[10];

unsigned char PADDING[64] = {
  0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

int  _stdcall MD5Initx (int ix)
{
	if ( ix < 0 && ix > 9 ) return -1 ;
	MD5_CTX *tmp = &xmd5[ix];
	MD5Init(tmp);
	xmds[ix] = 1;
	return xmds[ix];
}

int  _stdcall MD5Updatex (int ix , LPSTR astr , long len)
{
	if ( ix < 0 && ix > 9 ) return -1 ;
	if ( xmds[ix] < 1 ) return -1 ;

	unsigned int slen;
	MD5_CTX *tmp = &xmd5[ix];
	if (ix==8)
	{	
		if ( strlen(astr) < (MAX_BUFFER_SIZE-1) ) strcpy(buffer,astr);
		else return -1 ;
		slen = strlen(astr);
		buffer[slen]='\0';		
		MD5Update ( tmp ,(unsigned char *)buffer, slen);
	}
		else if (ix==9)
	{
		if ( strlen(astr) < (MAX_BUFFER_SIZE-1) ) strcpy(buffer,astr);
		else return -1 ;
		slen = strlen(astr);
		buffer[slen]='\0';		
		MD5Update ( tmp ,(unsigned char *)buffer, len);
		MD5Final((unsigned char*)buffer, tmp);
		MD5Init(tmp);
		MD5Update ( tmp ,(unsigned char *)buffer, slen);
	}
		else
		MD5Update ( tmp ,(unsigned char *)astr, (unsigned int)len);
	return ++xmds[ix];
}

int  _stdcall MD5Finalx (int ix , LPSTR md5str)
{
	if ( ix < 0 && ix > 9 ) return -1 ;
	if ( xmds[ix] < 1 ) return -1 ;

	MD5_CTX *tmp = &xmd5[ix];
	char ctmp[2];
	int j;

	MD5Final((unsigned char*)MD5buffer, tmp);
	MD5buffer[16]='\0';

	for(j=0;j<16;j++)
	{
		sprintf(ctmp, "%02x", MD5buffer[j]);
		md5str[2*j]=ctmp[0];
		md5str[2*j+1]=ctmp[1];
	}
	md5str[32]='\0';
	j = xmds[ix];
	xmds[ix] = 0;
	return j;
}

int  _stdcall MD5state (int ix)
{
	if ( ix < 0 && ix > 9 ) return -1 ;
	if (ix==10) 
	{
		for (int i=0;i<8;i++) if (xmds[i]==0) return i;
		return -1 ;
	}
	return xmds[ix];
}



bool _stdcall getMD5(LPSTR a)
{
	for (int j=0;j<16;j++)
	{
   	 a[j] = MD5buffer[j];
	 }
	a[16]='\0';
	return TRUE;
}

int  _stdcall getStringSize()
{
	return strlen(buffer);
}


void MD5Init (MD5_CTX *context)     
{
  context->count[0] = context->count[1] = 0;
  context->state[0] = 0x67452301;
  context->state[1] = 0xefcdab89;
  context->state[2] = 0x98badcfe;
  context->state[3] = 0x10325476;
}

void MD5Update (MD5_CTX *context,unsigned char *input,unsigned int inputLen)    
{
  unsigned int i, index, partLen;
 
  index = (unsigned int)((context->count[0] >> 3) & 0x3F);
 
  if ((context->count[0] += ((unsigned long)inputLen << 3)) < ((unsigned long)inputLen << 3))
		context->count[1]++;

	context->count[1] += ((unsigned long)inputLen >> 29);
	partLen = 64 - index;

	if (inputLen >= partLen)
  {
	 MD5_memcpy ((unsigned char *)&context->buffer[index], (unsigned char *)input, partLen);
	 MD5Transform (context->state, context->buffer);
	 for (i = partLen; i + 63 < inputLen; i += 64)
		MD5Transform (context->state, &input[i]);
	 index = 0;
  }
  else
	 i = 0;
 
  MD5_memcpy ((unsigned char *)&context->buffer[index], (unsigned char *)&input[i], inputLen-i);
}


void MD5Final (unsigned char digest[16], MD5_CTX *context)      
{
  unsigned char bits[8];
  unsigned int index, padLen;
 
  Encode (bits, context->count, 8);
 
  index = (unsigned int)((context->count[0] >> 3) & 0x3f);
  padLen = (index < 56) ? (56 - index) : (120 - index);
  MD5Update (context, (unsigned char *)PADDING, padLen);
 
  MD5Update (context, bits, 8);
 
  Encode (digest, context->state, 16);
 
  MD5_memset ((unsigned char *)context, 0, sizeof (*context));
}


void MD5Transform (unsigned long state[4],unsigned char block[64])
{
  unsigned long a = state[0], b = state[1], c = state[2], d = state[3], x[16];

  Decode (x, block, 64);

 
  FF (a, b, c, d, x[ 0], S11, 0xd76aa478);
  FF (d, a, b, c, x[ 1], S12, 0xe8c7b756);
  FF (c, d, a, b, x[ 2], S13, 0x242070db);
  FF (b, c, d, a, x[ 3], S14, 0xc1bdceee);
  FF (a, b, c, d, x[ 4], S11, 0xf57c0faf);
  FF (d, a, b, c, x[ 5], S12, 0x4787c62a);
  FF (c, d, a, b, x[ 6], S13, 0xa8304613);
  FF (b, c, d, a, x[ 7], S14, 0xfd469501);
  FF (a, b, c, d, x[ 8], S11, 0x698098d8);
  FF (d, a, b, c, x[ 9], S12, 0x8b44f7af);
  FF (c, d, a, b, x[10], S13, 0xffff5bb1);
  FF (b, c, d, a, x[11], S14, 0x895cd7be);
  FF (a, b, c, d, x[12], S11, 0x6b901122);
  FF (d, a, b, c, x[13], S12, 0xfd987193);
  FF (c, d, a, b, x[14], S13, 0xa679438e);
  FF (b, c, d, a, x[15], S14, 0x49b40821);

 
  GG (a, b, c, d, x[ 1], S21, 0xf61e2562);
  GG (d, a, b, c, x[ 6], S22, 0xc040b340);
  GG (c, d, a, b, x[11], S23, 0x265e5a51);
  GG (b, c, d, a, x[ 0], S24, 0xe9b6c7aa);
  GG (a, b, c, d, x[ 5], S21, 0xd62f105d);
  GG (d, a, b, c, x[10], S22,  0x2441453);
  GG (c, d, a, b, x[15], S23, 0xd8a1e681);
  GG (b, c, d, a, x[ 4], S24, 0xe7d3fbc8);
  GG (a, b, c, d, x[ 9], S21, 0x21e1cde6);
  GG (d, a, b, c, x[14], S22, 0xc33707d6);
  GG (c, d, a, b, x[ 3], S23, 0xf4d50d87);
  GG (b, c, d, a, x[ 8], S24, 0x455a14ed);
  GG (a, b, c, d, x[13], S21, 0xa9e3e905);
  GG (d, a, b, c, x[ 2], S22, 0xfcefa3f8);
  GG (c, d, a, b, x[ 7], S23, 0x676f02d9);
  GG (b, c, d, a, x[12], S24, 0x8d2a4c8a);

 
  HH (a, b, c, d, x[ 5], S31, 0xfffa3942);
  HH (d, a, b, c, x[ 8], S32, 0x8771f681);
  HH (c, d, a, b, x[11], S33, 0x6d9d6122);
  HH (b, c, d, a, x[14], S34, 0xfde5380c);
  HH (a, b, c, d, x[ 1], S31, 0xa4beea44);
  HH (d, a, b, c, x[ 4], S32, 0x4bdecfa9);
  HH (c, d, a, b, x[ 7], S33, 0xf6bb4b60);
  HH (b, c, d, a, x[10], S34, 0xbebfbc70);
  HH (a, b, c, d, x[13], S31, 0x289b7ec6);
  HH (d, a, b, c, x[ 0], S32, 0xeaa127fa);
  HH (c, d, a, b, x[ 3], S33, 0xd4ef3085);
  HH (b, c, d, a, x[ 6], S34,  0x4881d05);
  HH (a, b, c, d, x[ 9], S31, 0xd9d4d039);
  HH (d, a, b, c, x[12], S32, 0xe6db99e5);
  HH (c, d, a, b, x[15], S33, 0x1fa27cf8);
  HH (b, c, d, a, x[ 2], S34, 0xc4ac5665);

 
  II (a, b, c, d, x[ 0], S41, 0xf4292244);
  II (d, a, b, c, x[ 7], S42, 0x432aff97);
  II (c, d, a, b, x[14], S43, 0xab9423a7);
  II (b, c, d, a, x[ 5], S44, 0xfc93a039);
  II (a, b, c, d, x[12], S41, 0x655b59c3);
  II (d, a, b, c, x[ 3], S42, 0x8f0ccc92);
  II (c, d, a, b, x[10], S43, 0xffeff47d);
  II (b, c, d, a, x[ 1], S44, 0x85845dd1);
  II (a, b, c, d, x[ 8], S41, 0x6fa87e4f);
  II (d, a, b, c, x[15], S42, 0xfe2ce6e0);
  II (c, d, a, b, x[ 6], S43, 0xa3014314);
  II (b, c, d, a, x[13], S44, 0x4e0811a1);
  II (a, b, c, d, x[ 4], S41, 0xf7537e82);
  II (d, a, b, c, x[11], S42, 0xbd3af235);
  II (c, d, a, b, x[ 2], S43, 0x2ad7d2bb);
  II (b, c, d, a, x[ 9], S44, 0xeb86d391);

  state[0] += a;
  state[1] += b;
  state[2] += c;
  state[3] += d;

 
  MD5_memset ((unsigned char *)x, 0, sizeof (x));
}

void Encode (unsigned char *output,unsigned long *input,unsigned int len)
{
  unsigned int i, j;

  for (i = 0, j = 0; j < len; i++, j += 4) {
 output[j] = (char)(input[i] & 0xff);
 output[j+1] = (char)((input[i] >> 8) & 0xff);
 output[j+2] = (char)((input[i] >> 16) & 0xff);
 output[j+3] = (char)((input[i] >> 24) & 0xff);
  }
}

void Decode (unsigned long *output,unsigned char *input,unsigned int len)
{
  unsigned int i, j;

  for (i = 0, j = 0; j < len; i++, j += 4)
 output[i] = ((unsigned long)input[j]) | (((unsigned long)input[j+1]) << 8) |
   (((unsigned long)input[j+2]) << 16) | (((unsigned long)input[j+3]) << 24);
}


void MD5_memcpy (unsigned char * output,unsigned char * input,unsigned int len)
{
  unsigned int i;

  for (i = 0; i < len; i++)
    output[i] = input[i];
}

void MD5_memset (unsigned char * output,int value,unsigned int len)
{
  unsigned int i;

  for (i = 0; i < len; i++)
 ((char *)output)[i] = (char)value;
}


bool _stdcall addMD5(LPSTR md5str,LPSTR astr,long sta,long end)
{
	MD5_CTX md5;
	int j,stal;
    for(j=0;j<17;j++) MD5buffer[j]='\0';
	if (end ==0)
	{
		if ( sta>=0 || sta<(MAX_BUFFER_SIZE-1) || strlen(astr)<(MAX_BUFFER_SIZE-1))
		{
			if (sta==0) 
			{
				stal=strlen(astr);
				strcpy(buffer,astr);
				buffer[stal]='\0';
			}
			else if (sta==1)
			{
				stal=strlen(astr);
				strcpy(buffer,astr);
				buffer[stal]='\0';
				MD5Init(&md5);
				MD5Update(&md5,(unsigned char*)buffer,stal);
				MD5Final((unsigned char*)buffer,&md5);
				stal=strlen(buffer);
			}
			else
			{
				for (j=0;j<sta;j++) ((char *)buffer)[j] = astr[j];
				stal = sta;
			}
		}
		else
		{	
			return false;
		}
		MD5Init(&md5);
		MD5Update(&md5,(unsigned char*)buffer,stal);
		MD5Final((unsigned char*)MD5buffer,&md5);
	}
	else
	{
		FILE *fp;
		long fsize,result;
		char *encrypt;
		if((fp=fopen(astr,"rb"))==NULL) return false;
		fseek(fp, 0, SEEK_END);  
		fsize = ftell(fp); 

        if (fsize<1 || sta>=fsize || end>=fsize )
		{
			fclose(fp);
			return false;
		}
		if (end==1) end=fsize;
		fseek(fp, sta, SEEK_SET);
		fsize=end-sta;
		if (fsize<1 )
		{
			fclose(fp);
			return false;
		}
		if (sta==1 || fsize>FILE_MAX_SIZE)
		{
			if (sta==0) 
			{
				fclose(fp);
				return false;
			}
			if (sta==1) 
			{
				fseek(fp, 0, SEEK_SET);
				fsize = fsize + sta;
			}
			encrypt=(char*)malloc(FILE_BUFFER_SIZE+1);
			if (encrypt == NULL) 
			{
				fclose(fp);
				return false;
			}
			MD5Init(&md5);

			for (j=0;j<(fsize/(FILE_BUFFER_SIZE))+1;j++)
			{
			result = fread (encrypt,1,FILE_BUFFER_SIZE,fp);
			encrypt[result]='\0';
			if (result==FILE_BUFFER_SIZE)
				MD5Update(&md5,(unsigned char*)encrypt,result);
			else
				{
				result=fsize-j*FILE_BUFFER_SIZE;
				MD5Update(&md5,(unsigned char*)encrypt,result);
				}
			}

			fclose(fp);
			MD5Final((unsigned char*)MD5buffer,&md5);
			free(encrypt);
		}
		else
		{
			encrypt=(char*)malloc(fsize+1);
			 if (encrypt == NULL) 
			{
				fclose(fp);
				return false;
			}
			result = fread (encrypt,1,fsize,fp);
			if (result != fsize) 
			{
				fclose(fp);
				return false;
			}
			fclose(fp);
			encrypt[fsize]='\0';

			MD5Init(&md5);
			MD5Update(&md5,(unsigned char*)encrypt,fsize);
			MD5Final((unsigned char*)MD5buffer,&md5);
			free(encrypt);
		}
	}
MD5buffer[16]='\0';

char tmp[2];
for(j=0;j<16;j++)
{
	sprintf(tmp, "%02x", MD5buffer[j]);
	md5str[2*j]=tmp[0];
	md5str[2*j+1]=tmp[1];
}
md5str[32]='\0';

return true;
}



/**
bool  _stdcall addString(LPSTR a)
{
    if (strlen(a)<MAX_BUFFER_SIZE-1)
	{
		strcpy(buffer,a);
		return TRUE;
	}
	else
		return FALSE;
}

bool  _stdcall getString(LPSTR a)
{
	strcpy(a,buffer);
	return TRUE;
}

long _stdcall testdll(long s1,long s2)
{
return s1+s2;
}
**/


