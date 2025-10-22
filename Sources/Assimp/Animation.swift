@_implementationOnly import CAssimp

public class Animation {
  private let animData: aiAnimation

  init(_ anim: aiAnimation) {
    animData = anim
    name = String(anim.mName)
    duration = anim.mDuration
    ticksPerSecond = anim.mTicksPerSecond
    numberOfChannels = Int(anim.mNumChannels)
    numberOfMeshChannels = Int(anim.mNumMeshChannels)
    numberOfMorphMeshChannels = Int(anim.mNumMorphMeshChannels)
  }

  convenience init?(_ anim: aiAnimation?) {
    guard let anim = anim else { return nil }
    self.init(anim)
  }

  /// The name of the animation. If the modeling package which exported the scene does support only a single animation channel, this name may be empty.
  public var name: String?

  /// Duration of the animation in ticks.
  public var duration: Double

  /// Ticks per second. 0 if not specified in the imported file.
  public var ticksPerSecond: Double

  /// Channels describe node transformations over time.
  public var numberOfChannels: Int
  public lazy var channels: [NodeAnimation] = {
    guard numberOfChannels > 0 else { return [] }
    guard let startPtr = animData.mChannels else { return [] }
    return UnsafeBufferPointer(start: startPtr, count: numberOfChannels)
      .compactMap { $0?.pointee }
      .map(NodeAnimation.init)
  }()

  /// Mesh channels are currently unsupported in this wrapper.
  public var numberOfMeshChannels: Int
  /// Morph mesh channels are currently unsupported in this wrapper.
  public var numberOfMorphMeshChannels: Int
}

extension Animation: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Animation('\(name ?? "")'; ticks: \(duration); channels: \(numberOfChannels))"
  }
}
