@_implementationOnly import CAssimp
@_implementationOnly import CAssimpShim

extension Scene {
  public typealias ProgressCallback = (_ progress: Float) -> Bool

  public convenience init(
    file filePath: String,
    flags: PostProcessStep = [],
    progress: ProgressCallback?
  ) throws {
    if let progress {
      // Bridge Swift closure to C callback
      class Box {
        let callback: ProgressCallback
        init(_ cb: @escaping ProgressCallback) { self.callback = cb }
      }
      let box = Box(progress)
      let unmanaged = Unmanaged.passRetained(box)
      let ctx = unmanaged.toOpaque()

      let cCallback: assimp_progress_callback = { pct, userData in
        guard let userData else { return true }
        let box = Unmanaged<Box>.fromOpaque(userData).takeUnretainedValue()
        return box.callback(pct)
      }

      guard let scenePtr = assimp_read_file_with_progress(filePath, flags.rawValue, cCallback, ctx)
      else {
        // Balance retain in error path
        unmanaged.release()
        if let err = assimp_shim_get_last_error() {
          throw Error.importFailed(String(cString: err))
        } else {
          throw Error.importFailed(String(cString: aiGetErrorString()))
        }
      }

      try self.init(scenePtr: scenePtr, filePath: filePath)

      // Now that init succeeded, release the retained box
      unmanaged.release()
    } else {
      try self.init(file: filePath, flags: flags)
    }
  }
}

