/*
 * DirectPlay8 ThreadPool
 *
 * Copyright 2004 Raphael Junqueira
 * Copyright 2008 Alexander N. Sørnes <alex@thehandofagony.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 */

#include "config.h"

#include <stdarg.h>

#define COBJMACROS
#include "windef.h"
#include "winbase.h"
#include "wingdi.h"
#include "winuser.h"
#include "objbase.h"
#include "wine/debug.h"

#include "dpnet_private.h"

WINE_DEFAULT_DEBUG_CHANNEL(dpnet);

static inline IDirectPlay8ThreadPoolImpl *impl_from_IDirectPlay8ThreadPool(IDirectPlay8ThreadPool *iface)
{
    return CONTAINING_RECORD(iface, IDirectPlay8ThreadPoolImpl, IDirectPlay8ThreadPool_iface);
}

/* IUnknown interface follows */
static HRESULT WINAPI IDirectPlay8ThreadPoolImpl_QueryInterface(IDirectPlay8ThreadPool *iface,
        REFIID riid, void **ppobj)
{
    IDirectPlay8ThreadPoolImpl *This = impl_from_IDirectPlay8ThreadPool(iface);

    if(IsEqualGUID(riid, &IID_IUnknown) ||
       IsEqualGUID(riid, &IID_IDirectPlay8ThreadPool))
    {
        IUnknown_AddRef(iface);
        *ppobj = This;
        return DPN_OK;
    }

    WARN("(%p)->(%s,%p): not found\n", This, debugstr_guid(riid), ppobj);
    return E_NOINTERFACE;
}

static ULONG WINAPI IDirectPlay8ThreadPoolImpl_AddRef(IDirectPlay8ThreadPool *iface)
{
    IDirectPlay8ThreadPoolImpl* This = impl_from_IDirectPlay8ThreadPool(iface);
    ULONG RefCount = InterlockedIncrement(&This->ref);

    return RefCount;
}

static ULONG WINAPI IDirectPlay8ThreadPoolImpl_Release(IDirectPlay8ThreadPool *iface)
{
    IDirectPlay8ThreadPoolImpl* This = impl_from_IDirectPlay8ThreadPool(iface);
    ULONG RefCount = InterlockedDecrement(&This->ref);

    if(!RefCount)
        HeapFree(GetProcessHeap(), 0, This);

    return RefCount;
}

/* IDirectPlay8ThreadPool interface follows */
static HRESULT WINAPI IDirectPlay8ThreadPoolImpl_Initialize(IDirectPlay8ThreadPool *iface,
        void * const pvUserContext, const PFNDPNMESSAGEHANDLER pfn, const DWORD dwFlags)
{
    FIXME("(%p)->(%p,%p,%x): stub\n", iface, pvUserContext, pfn, dwFlags);
    return DPN_OK;
}

static HRESULT WINAPI IDirectPlay8ThreadPoolImpl_Close(IDirectPlay8ThreadPool *iface,
        const DWORD dwFlags)
{
    return DPN_OK;
}

static HRESULT WINAPI IDirectPlay8ThreadPoolImpl_GetThreadCount(IDirectPlay8ThreadPool *iface,
        const DWORD dwProcessorNum, DWORD * const pdwNumThreads, const DWORD dwFlags)
{
    FIXME("(%p)->(%x,%p,%x): stub\n", iface, dwProcessorNum, pdwNumThreads, dwFlags);
    *pdwNumThreads = 0;
    return DPN_OK;
}

static HRESULT WINAPI IDirectPlay8ThreadPoolImpl_SetThreadCount(IDirectPlay8ThreadPool *iface,
        const DWORD dwProcessorNum, const DWORD dwNumThreads, const DWORD dwFlags)
{
    FIXME("(%p)->(%x,%x,%x): stub\n", iface, dwProcessorNum, dwNumThreads, dwFlags);
    return DPN_OK;
}

static HRESULT WINAPI IDirectPlay8ThreadPoolImpl_DoWork(IDirectPlay8ThreadPool *iface,
        const DWORD dwAllowedTimeSlice, const DWORD dwFlags)
{
    static BOOL Run = FALSE;

    if(!Run)
        FIXME("(%p)->(%x,%x): stub\n", iface, dwAllowedTimeSlice, dwFlags);

    Run = TRUE;

    return DPN_OK;
}

static const IDirectPlay8ThreadPoolVtbl DirectPlay8ThreadPool_Vtbl =
{
    IDirectPlay8ThreadPoolImpl_QueryInterface,
    IDirectPlay8ThreadPoolImpl_AddRef,
    IDirectPlay8ThreadPoolImpl_Release,
    IDirectPlay8ThreadPoolImpl_Initialize,
    IDirectPlay8ThreadPoolImpl_Close,
    IDirectPlay8ThreadPoolImpl_GetThreadCount,
    IDirectPlay8ThreadPoolImpl_SetThreadCount,
    IDirectPlay8ThreadPoolImpl_DoWork
};

HRESULT DPNET_CreateDirectPlay8ThreadPool(LPCLASSFACTORY iface, LPUNKNOWN punkOuter, REFIID riid, LPVOID *ppobj)
{
    IDirectPlay8ThreadPoolImpl* Client;

    Client = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, sizeof(IDirectPlay8ThreadPoolImpl));

    if(Client == NULL)
    {
        *ppobj = NULL;
        WARN("Not enough memory\n");
        return E_OUTOFMEMORY;
    }

    Client->IDirectPlay8ThreadPool_iface.lpVtbl = &DirectPlay8ThreadPool_Vtbl;
    Client->ref = 0;

    return IDirectPlay8ThreadPoolImpl_QueryInterface(&Client->IDirectPlay8ThreadPool_iface, riid,
            ppobj);
}
