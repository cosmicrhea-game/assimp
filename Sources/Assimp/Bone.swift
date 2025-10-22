@_implementationOnly import CAssimp

public class Bone {
  private let bonePtr: UnsafePointer<aiBone>
  private let _weights: [VertexWeight]

  init(_ bone: aiBone) {
    bonePtr = withUnsafePointer(to: bone) { UnsafePointer($0) }
    name = String(bone.mName)
    offsetMatrix = Matrix4x4(bone.mOffsetMatrix)
    numberOfWeights = Int(bone.mNumWeights)

    // Copy bone weights immediately to avoid memory ownership issues
    if numberOfWeights > 0, let startPtr = bone.mWeights {
      let buffer = UnsafeBufferPointer(start: startPtr, count: numberOfWeights)
      _weights = buffer.map(VertexWeight.init)
    } else {
      _weights = []
    }
  }

  convenience init?(_ bone: aiBone?) {
    guard let bone = bone else {
      return nil
    }
    self.init(bone)
  }

  /// The name of the bone.
  ///
  /// Multiple bones can affect a single mesh.
  public var name: String?

  /// Matrix that transforms from mesh space to bone space in bind pose.
  public var offsetMatrix: Matrix4x4

  /// The number of vertex weights this bone contains.
  public var numberOfWeights: Int

  /// The vertex weights of this bone.
  public var weights: [VertexWeight] {
    return _weights
  }
}

public struct VertexWeight {
  public let vertexIndex: Int
  public let weight: AssimpReal

  init(_ w: aiVertexWeight) {
    vertexIndex = Int(w.mVertexId)
    weight = w.mWeight
  }
}
