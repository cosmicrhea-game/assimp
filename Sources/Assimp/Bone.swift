@_implementationOnly import CAssimp

public class Bone {
  private let bonePtr: UnsafePointer<aiBone>

  init(_ bone: aiBone) {
    bonePtr = withUnsafePointer(to: bone) { UnsafePointer($0) }
    name = String(bone.mName)
    offsetMatrix = Matrix4x4(bone.mOffsetMatrix)
    numberOfWeights = Int(bone.mNumWeights)
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
  public lazy var weights: [VertexWeight] = {
    guard numberOfWeights > 0 else { return [] }
    let bone = bonePtr.pointee
    return UnsafeBufferPointer(start: bone.mWeights, count: numberOfWeights).map(VertexWeight.init)
  }()
}

public struct VertexWeight {
  public let vertexIndex: Int
  public let weight: AssimpReal

  init(_ w: aiVertexWeight) {
    vertexIndex = Int(w.mVertexId)
    weight = w.mWeight
  }
}
