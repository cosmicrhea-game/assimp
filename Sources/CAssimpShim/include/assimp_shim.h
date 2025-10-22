#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

struct aiScene;

typedef bool (*assimp_progress_callback)(float progress, void* user_data);

// Reads a file using Assimp::Importer with an optional progress callback.
// Returns a detached aiScene* (ownership transferred to caller via GetOrphanedScene).
// On failure, returns NULL and stores a readable message accessible via assimp_shim_get_last_error().
const struct aiScene* assimp_read_file_with_progress(const char* path,
                                                     unsigned int flags,
                                                     assimp_progress_callback cb,
                                                     void* user_data);

// Returns the last error message produced by assimp_read_file_with_progress() in this thread.
// Pointer remains valid until the next call on the same thread.
const char* assimp_shim_get_last_error(void);

#ifdef __cplusplus
}
#endif



