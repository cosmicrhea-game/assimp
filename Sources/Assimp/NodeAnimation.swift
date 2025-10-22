@_implementationOnly import CAssimp

public class NodeAnimation {
  private let channelPtr: UnsafePointer<aiNodeAnim>

  init(_ channel: aiNodeAnim) {
    channelPtr = withUnsafePointer(to: channel) { UnsafePointer($0) }
    nodeName = String(channel.mNodeName)
    numberOfPositionKeys = Int(channel.mNumPositionKeys)
    numberOfRotationKeys = Int(channel.mNumRotationKeys)
    numberOfScalingKeys = Int(channel.mNumScalingKeys)
    preState = AnimationBehavior(channel.mPreState)
    postState = AnimationBehavior(channel.mPostState)
  }

  convenience init?(_ channel: aiNodeAnim?) {
    guard let channel = channel else { return nil }
    self.init(channel)
  }

  /// The name of the node affected by this animation. The node must exist and its name must be unique.
  public var nodeName: String?

  /// The position keys of this animation channel.
  public var numberOfPositionKeys: Int
  public lazy var positionKeys: [VectorKey] = {
    guard numberOfPositionKeys > 0 else { return [] }
    let ch = channelPtr.pointee
    return UnsafeBufferPointer(start: ch.mPositionKeys, count: numberOfPositionKeys).map(
      VectorKey.init)
  }()

  /// The rotation keys of this animation channel.
  public var numberOfRotationKeys: Int
  public lazy var rotationKeys: [QuatKey] = {
    guard numberOfRotationKeys > 0 else { return [] }
    let ch = channelPtr.pointee
    return UnsafeBufferPointer(start: ch.mRotationKeys, count: numberOfRotationKeys).map(
      QuatKey.init)
  }()

  /// The scaling keys of this animation channel.
  public var numberOfScalingKeys: Int
  public lazy var scalingKeys: [VectorKey] = {
    guard numberOfScalingKeys > 0 else { return [] }
    let ch = channelPtr.pointee
    return UnsafeBufferPointer(start: ch.mScalingKeys, count: numberOfScalingKeys).map(
      VectorKey.init)
  }()

  /// Defines how the animation behaves before the first and after the last key.
  public var preState: AnimationBehavior
  public var postState: AnimationBehavior
}

public enum AnimationBehavior {
  case defaultBehavior
  case constant
  case linear
  case repeatBehavior

  init(_ b: aiAnimBehaviour) {
    switch b {
    case aiAnimBehaviour_DEFAULT: self = .defaultBehavior
    case aiAnimBehaviour_CONSTANT: self = .constant
    case aiAnimBehaviour_LINEAR: self = .linear
    case aiAnimBehaviour_REPEAT: self = .repeatBehavior
    default: self = .defaultBehavior
    }
  }
}

public struct VectorKey {
  public let time: Double
  public let value: AssimpVec3

  init(_ k: aiVectorKey) {
    time = k.mTime
    value = AssimpVec3(k.mValue)
  }
}

public struct QuatKey {
  public let time: Double
  public let value: SIMD4<Float>

  init(_ k: aiQuatKey) {
    time = k.mTime
    // aiQuaternion is (w, x, y, z)
    value = SIMD4<Float>(k.mValue.x, k.mValue.y, k.mValue.z, k.mValue.w)
  }
}
