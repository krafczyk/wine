/* File generated automatically by tools/make_requests; DO NOT EDIT!! */

#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include "server.h"
#include "server/thread.h"

static int dump_new_thread_request( struct new_thread_request *req, int len )
{
    printf( " pid=%p", req->pid );
    return (int)sizeof(*req);
}

static int dump_new_thread_reply( struct new_thread_reply *req, int len )
{
    printf( " tid=%p,", req->tid );
    printf( " thandle=%d,", req->thandle );
    printf( " pid=%p,", req->pid );
    printf( " phandle=%d", req->phandle );
    return (int)sizeof(*req);
}

static int dump_set_debug_request( struct set_debug_request *req, int len )
{
    printf( " level=%d", req->level );
    return (int)sizeof(*req);
}

static int dump_init_thread_request( struct init_thread_request *req, int len )
{
    printf( " unix_pid=%d,", req->unix_pid );
    printf( " cmd_line=\"%.*s\"", len - (int)sizeof(*req), (char *)(req+1) );
    return len;
}

static int dump_terminate_process_request( struct terminate_process_request *req, int len )
{
    printf( " handle=%d,", req->handle );
    printf( " exit_code=%d", req->exit_code );
    return (int)sizeof(*req);
}

static int dump_terminate_thread_request( struct terminate_thread_request *req, int len )
{
    printf( " handle=%d,", req->handle );
    printf( " exit_code=%d", req->exit_code );
    return (int)sizeof(*req);
}

static int dump_get_process_info_request( struct get_process_info_request *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_get_process_info_reply( struct get_process_info_reply *req, int len )
{
    printf( " pid=%p,", req->pid );
    printf( " exit_code=%d", req->exit_code );
    return (int)sizeof(*req);
}

static int dump_get_thread_info_request( struct get_thread_info_request *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_get_thread_info_reply( struct get_thread_info_reply *req, int len )
{
    printf( " pid=%p,", req->pid );
    printf( " exit_code=%d", req->exit_code );
    return (int)sizeof(*req);
}

static int dump_close_handle_request( struct close_handle_request *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_dup_handle_request( struct dup_handle_request *req, int len )
{
    printf( " src_process=%d,", req->src_process );
    printf( " src_handle=%d,", req->src_handle );
    printf( " dst_process=%d,", req->dst_process );
    printf( " dst_handle=%d,", req->dst_handle );
    printf( " access=%08x,", req->access );
    printf( " inherit=%d,", req->inherit );
    printf( " options=%d", req->options );
    return (int)sizeof(*req);
}

static int dump_dup_handle_reply( struct dup_handle_reply *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_open_process_request( struct open_process_request *req, int len )
{
    printf( " pid=%p,", req->pid );
    printf( " access=%08x,", req->access );
    printf( " inherit=%d", req->inherit );
    return (int)sizeof(*req);
}

static int dump_open_process_reply( struct open_process_reply *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_select_request( struct select_request *req, int len )
{
    printf( " count=%d,", req->count );
    printf( " flags=%d,", req->flags );
    printf( " timeout=%d", req->timeout );
    return (int)sizeof(*req);
}

static int dump_select_reply( struct select_reply *req, int len )
{
    printf( " signaled=%d", req->signaled );
    return (int)sizeof(*req);
}

static int dump_create_event_request( struct create_event_request *req, int len )
{
    printf( " manual_reset=%d,", req->manual_reset );
    printf( " initial_state=%d,", req->initial_state );
    printf( " inherit=%d,", req->inherit );
    printf( " name=\"%.*s\"", len - (int)sizeof(*req), (char *)(req+1) );
    return len;
}

static int dump_create_event_reply( struct create_event_reply *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_event_op_request( struct event_op_request *req, int len )
{
    printf( " handle=%d,", req->handle );
    printf( " op=%d", req->op );
    return (int)sizeof(*req);
}

static int dump_create_mutex_request( struct create_mutex_request *req, int len )
{
    printf( " owned=%d,", req->owned );
    printf( " inherit=%d,", req->inherit );
    printf( " name=\"%.*s\"", len - (int)sizeof(*req), (char *)(req+1) );
    return len;
}

static int dump_create_mutex_reply( struct create_mutex_reply *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_release_mutex_request( struct release_mutex_request *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_create_semaphore_request( struct create_semaphore_request *req, int len )
{
    printf( " initial=%08x,", req->initial );
    printf( " max=%08x,", req->max );
    printf( " inherit=%d", req->inherit );
    return (int)sizeof(*req);
}

static int dump_create_semaphore_reply( struct create_semaphore_reply *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_release_semaphore_request( struct release_semaphore_request *req, int len )
{
    printf( " handle=%d,", req->handle );
    printf( " count=%08x", req->count );
    return (int)sizeof(*req);
}

static int dump_release_semaphore_reply( struct release_semaphore_reply *req, int len )
{
    printf( " prev_count=%08x", req->prev_count );
    return (int)sizeof(*req);
}

static int dump_open_named_obj_request( struct open_named_obj_request *req, int len )
{
    printf( " type=%d,", req->type );
    printf( " access=%08x,", req->access );
    printf( " inherit=%d", req->inherit );
    return (int)sizeof(*req);
}

static int dump_open_named_obj_reply( struct open_named_obj_reply *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_create_file_request( struct create_file_request *req, int len )
{
    printf( " access=%08x,", req->access );
    printf( " inherit=%d", req->inherit );
    return (int)sizeof(*req);
}

static int dump_create_file_reply( struct create_file_reply *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_get_unix_handle_request( struct get_unix_handle_request *req, int len )
{
    printf( " handle=%d,", req->handle );
    printf( " access=%08x", req->access );
    return (int)sizeof(*req);
}

static int dump_get_file_info_request( struct get_file_info_request *req, int len )
{
    printf( " handle=%d", req->handle );
    return (int)sizeof(*req);
}

static int dump_get_file_info_reply( struct get_file_info_reply *req, int len )
{
    printf( " attr=%d,", req->attr );
    printf( " access_time=%ld,", req->access_time );
    printf( " write_time=%ld,", req->write_time );
    printf( " size_high=%d,", req->size_high );
    printf( " size_low=%d,", req->size_low );
    printf( " links=%d,", req->links );
    printf( " index_high=%d,", req->index_high );
    printf( " index_low=%d,", req->index_low );
    printf( " serial=%08x", req->serial );
    return (int)sizeof(*req);
}

struct dumper
{
    int (*dump_req)( void *data, int len );
    void (*dump_reply)( void *data );
};

static const struct dumper dumpers[REQ_NB_REQUESTS] =
{
    { (int(*)(void *,int))dump_new_thread_request,
      (void(*)())dump_new_thread_reply },
    { (int(*)(void *,int))dump_set_debug_request,
      (void(*)())0 },
    { (int(*)(void *,int))dump_init_thread_request,
      (void(*)())0 },
    { (int(*)(void *,int))dump_terminate_process_request,
      (void(*)())0 },
    { (int(*)(void *,int))dump_terminate_thread_request,
      (void(*)())0 },
    { (int(*)(void *,int))dump_get_process_info_request,
      (void(*)())dump_get_process_info_reply },
    { (int(*)(void *,int))dump_get_thread_info_request,
      (void(*)())dump_get_thread_info_reply },
    { (int(*)(void *,int))dump_close_handle_request,
      (void(*)())0 },
    { (int(*)(void *,int))dump_dup_handle_request,
      (void(*)())dump_dup_handle_reply },
    { (int(*)(void *,int))dump_open_process_request,
      (void(*)())dump_open_process_reply },
    { (int(*)(void *,int))dump_select_request,
      (void(*)())dump_select_reply },
    { (int(*)(void *,int))dump_create_event_request,
      (void(*)())dump_create_event_reply },
    { (int(*)(void *,int))dump_event_op_request,
      (void(*)())0 },
    { (int(*)(void *,int))dump_create_mutex_request,
      (void(*)())dump_create_mutex_reply },
    { (int(*)(void *,int))dump_release_mutex_request,
      (void(*)())0 },
    { (int(*)(void *,int))dump_create_semaphore_request,
      (void(*)())dump_create_semaphore_reply },
    { (int(*)(void *,int))dump_release_semaphore_request,
      (void(*)())dump_release_semaphore_reply },
    { (int(*)(void *,int))dump_open_named_obj_request,
      (void(*)())dump_open_named_obj_reply },
    { (int(*)(void *,int))dump_create_file_request,
      (void(*)())dump_create_file_reply },
    { (int(*)(void *,int))dump_get_unix_handle_request,
      (void(*)())0 },
    { (int(*)(void *,int))dump_get_file_info_request,
      (void(*)())dump_get_file_info_reply },
};

static const char * const req_names[REQ_NB_REQUESTS] =
{
    "new_thread",
    "set_debug",
    "init_thread",
    "terminate_process",
    "terminate_thread",
    "get_process_info",
    "get_thread_info",
    "close_handle",
    "dup_handle",
    "open_process",
    "select",
    "create_event",
    "event_op",
    "create_mutex",
    "release_mutex",
    "create_semaphore",
    "release_semaphore",
    "open_named_obj",
    "create_file",
    "get_unix_handle",
    "get_file_info",
};

void trace_request( enum request req, void *data, int len, int fd )
{
    int size;
    current->last_req = req;
    printf( "%08x: %s(", (unsigned int)current, req_names[req] );
    size = dumpers[req].dump_req( data, len );
    if ((len -= size) > 0)
    {
        unsigned char *ptr = (unsigned char *)data + size;
        while (len--) printf( ", %02x", *ptr++ );
    }
    if (fd != -1) printf( " ) fd=%d\n", fd );
    else printf( " )\n" );
}

void trace_timeout(void)
{
    printf( "%08x: *timeout*\n", (unsigned int)current );
}

void trace_kill( int exit_code )
{
    printf( "%08x: *killed* exit_code=%d\n",
            (unsigned int)current, exit_code );
}

void trace_reply( struct thread *thread, int type, int pass_fd,
                  struct iovec *vec, int veclen )
{
    if (!thread) return;
    printf( "%08x: %s() = %d",
            (unsigned int)thread, req_names[thread->last_req], type );
    if (veclen)
    {
	printf( " {" );
	if (dumpers[thread->last_req].dump_reply)
	{
	    dumpers[thread->last_req].dump_reply( vec->iov_base );
	    vec++;
	    veclen--;
	}
	for (; veclen; veclen--, vec++)
	{
	    unsigned char *ptr = vec->iov_base;
	    int len = vec->iov_len;
	    while (len--) printf( ", %02x", *ptr++ );
	}
	printf( " }" );
    }
    if (pass_fd != -1) printf( " fd=%d\n", pass_fd );
    else printf( "\n" );
}
