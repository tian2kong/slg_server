#ifndef _AOI_H
#define _AOI_H

#include <stdint.h>
#include <stddef.h>

//AOI 服务的设计与实现 具体介绍http://blog.codingnow.com/2012/03/dev_note_13.html

typedef void * (*aoi_Alloc)(void *ud, void * ptr, size_t sz);
typedef void (aoi_Callback)(void *ud, uint32_t watcher, uint32_t marker);

struct aoi_space;

struct aoi_space * aoi_create(aoi_Alloc alloc, void *ud, float raids);
struct aoi_space * aoi_new(float radis);
void aoi_release(struct aoi_space *);

// w(atcher) m(arker) d(rop)
void aoi_update(struct aoi_space * space, uint32_t id, const char * mode, float pos[3], float radis);
void aoi_message(struct aoi_space *space, aoi_Callback cb, void *ud);

#endif
