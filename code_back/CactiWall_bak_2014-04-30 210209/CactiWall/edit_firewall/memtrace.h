#pragma once

#include<ntddk.h>

#define MEM_TAG 'WALL'


#define MEM_MAGIC 'WALL'

#if DBG
typedef struct _MEM_NODE {
    ULONG        magic;
    struct        _MEM_NODE *next;
    struct        _MEM_NODE *prev;
    ULONG        size;
    const char    *file;
    ULONG        line;
    PVOID        data[];
}MEM_NODE,*PMEM_NODE;

PVOID   DbgExAllocatePool( IN ULONG size,IN const char *file,IN ULONG line );
VOID    DbgExFreePool( IN PVOID ptr );
VOID    DbgMemTraceInit();
BOOLEAN DbgIsMemLeak();

#define MyExAllocatePool(_x_) DbgExAllocatePool((_x_),__FILE__,__LINE__ )
#define MyExFreePool(_x_) DbgExFreePool((_x_))
#else
#define MyExAllocatePool(_x_) ExAllocatePoolWithTag(NonPagedPool,(_x_),MEM_TAG)
#define MyExFreePool(_x_) ExFreePool((_x_))
#endif





                                                                                                                                                                                                                                