#include "assimp_shim.h"

#include <assimp/Importer.hpp>
#include <assimp/ProgressHandler.hpp>
#include <assimp/scene.h>
#include <assimp/DefaultLogger.hpp>
#include <mutex>
#include <string>

namespace {

// Thread-local last error string
thread_local std::string g_last_error;

class CallbackProgressHandler : public Assimp::ProgressHandler {
public:
    CallbackProgressHandler(assimp_progress_callback callback, void* user_data)
    : callback_(callback), user_data_(user_data) {}

    bool Update(float percentage) override {
        if (!callback_) return true;
        return callback_(percentage, user_data_);
    }

private:
    assimp_progress_callback callback_;
    void* user_data_;
};

}

extern "C" {

const aiScene* assimp_read_file_with_progress(const char* path,
                                              unsigned int flags,
                                              assimp_progress_callback cb,
                                              void* user_data) {
    g_last_error.clear();
    try {
        Assimp::Importer importer;
        auto handler = std::make_unique<CallbackProgressHandler>(cb, user_data);
        importer.SetProgressHandler(handler.release());

        const aiScene* scene = importer.ReadFile(path, flags);
        if (!scene) {
            g_last_error = importer.GetErrorString();
            return nullptr;
        }
        // Transfer ownership to caller
        return importer.GetOrphanedScene();
    } catch (const std::exception& ex) {
        g_last_error = ex.what();
        return nullptr;
    } catch (...) {
        g_last_error = "Unknown error";
        return nullptr;
    }
}

const char* assimp_shim_get_last_error(void) {
    return g_last_error.c_str();
}

}


