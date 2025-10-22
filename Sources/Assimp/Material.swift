@_implementationOnly import CAssimp

// Ref: https://github.com/helix-toolkit/helix-toolkit/blob/master/Source/HelixToolkit.SharpDX.Assimp.Shared/ImporterPartial_Material.cs
public class Material {
  private let materialPtr: UnsafePointer<aiMaterial>

  init(_ materialPtr: UnsafePointer<aiMaterial>) {
    self.materialPtr = materialPtr
    let material = materialPtr.pointee
    let numberOfProperties = Int(material.mNumProperties)
    self.numberOfProperties = numberOfProperties
    let numberAllocated = Int(material.mNumAllocated)
    self.numberAllocated = numberAllocated
    properties = {
      guard numberOfProperties > 0 else {
        return []
      }
      return [MaterialProperty](unsafeUninitializedCapacity: numberOfProperties) {
        buffer, written in
        for idx in 0..<numberOfProperties {
          if let prop = material.mProperties[idx] {
            buffer[idx] = MaterialProperty(prop.pointee)
            written += 1
          }
        }
      }
    }()
  }

  convenience init?(_ mat: UnsafePointer<aiMaterial>?) {
    guard let mat = mat else {
      return nil
    }
    self.init(mat)
  }

  /// Number of properties in the data base
  public var numberOfProperties: Int

  /// Storage allocated
  public var numberAllocated: Int

  /// List of all material properties loaded.
  public var properties: [MaterialProperty]

  public lazy var typedProperties: [MaterialPropertyIdentifiable] = properties.compactMap {
    prop -> MaterialPropertyIdentifiable? in
    switch prop.type {
    case .string:
      return AiMaterialPropertyString(prop)

    case .float:
      return AiMaterialPropertyFloat(prop)

    case .int:
      return AiMaterialPropertyInt(prop)

    case .buffer:
      return AiMaterialPropertyBuffer(prop)

    case .double:
      return AiMaterialPropertyDouble(prop)

    default:
      return nil
    }
  }

  /*
   - aiGetMaterialProperty
   - aiGetMaterialTextureCount
   - aiGetMaterialTexture
   - aiGetMaterialString
   - aiGetMaterialColor
  
   - aiGetMaterialFloat
   - aiGetMaterialFloatArray
   - aiGetMaterialInteger
   - aiGetMaterialIntegerArray
   - aiGetMaterialUVTransform
   - aiGetMaterialXXX
   */
  public func getMaterialProperty(_ key: MaterialKey) -> MaterialProperty? {
    let matPropPtr = UnsafeMutablePointer<UnsafePointer<aiMaterialProperty>?>.allocate(
      capacity: MemoryLayout<aiMaterialProperty>.stride)
    defer {
      matPropPtr.deinitialize(count: 1)
      matPropPtr.deallocate()
    }

    let result = aiGetMaterialProperty(
      materialPtr,
      key.baseName,
      key.texType,
      key.texIndex,
      matPropPtr)

    guard result == aiReturn_SUCCESS, let property = matPropPtr.pointee?.pointee else {
      return nil
    }
    return MaterialProperty(property)
  }

  /// Get the number of textures for a particular texture type.
  public func getMaterialTextureCount(texType: TextureType) -> Int {
    Int(aiGetMaterialTextureCount(materialPtr, texType.type))
  }

  public func getMaterialTexture(texType: TextureType, texIndex: Int) -> String? {
    var path = aiString()
    // Pass nil for optional out-parameters we don't need; Assimp accepts nulls here.
    let result = aiGetMaterialTexture(
      materialPtr,
      texType.type,
      UInt32(texIndex),
      &path,
      nil,  // mapping
      nil,  // uvIndex
      nil,  // blend
      nil,  // texOp
      nil,  // mapmode
      nil)  // flags

    guard result == aiReturn_SUCCESS else {
      return nil
    }

    return String(path)
  }

  public func getMaterialString(_ key: MaterialKey) -> String? {
    var string = aiString()
    let result = aiGetMaterialString(
      materialPtr,
      key.baseName,
      key.texType,
      key.texIndex,
      &string)

    guard result == aiReturn_SUCCESS else {
      return nil
    }

    return String(string)
  }

  public func getMaterialColor(_ key: MaterialKey) -> SIMD4<AssimpReal>? {
    var color = aiColor4D()
    let result = aiGetMaterialColor(
      materialPtr,
      key.baseName,
      key.texType,
      key.texIndex,
      &color)
    guard result == aiReturn_SUCCESS else {
      return nil
    }
    return SIMD4<Float>(color.r, color.g, color.b, color.a)
  }

  public func getMaterialFloatArray(_ key: MaterialKey) -> [AssimpReal]? {
    let count = MemoryLayout<aiUVTransform>.stride / MemoryLayout<ai_real>.stride
    return [ai_real](unsafeUninitializedCapacity: count) { buffer, written in
      var pMax: UInt32 = 0
      let result = aiGetMaterialFloatArray(
        materialPtr,
        key.baseName,
        key.texType,
        key.texIndex,
        buffer.baseAddress!,
        &pMax)
      guard result == aiReturn_SUCCESS else {
        return
      }

      written = Int(pMax)
    }
  }

  public func getMaterialIntegerArray(_ key: MaterialKey) -> [Int32] {
    [Int32](unsafeUninitializedCapacity: 4) { buffer, written in
      var pMax: UInt32 = 0
      let result = aiGetMaterialIntegerArray(
        materialPtr,
        key.baseName,
        key.texType,
        key.texIndex,
        buffer.baseAddress!,
        &pMax)

      guard result == aiReturn_SUCCESS, pMax > 0 else {
        return
      }

      written = Int(pMax)
    }
  }
}

extension Material {
  @inlinable public var name: String? { getMaterialString(.NAME) }

  @inlinable public var shadingModel: ShadingMode? {
    guard let int = getMaterialProperty(.SHADING_MODEL)?.int.first else {
      return nil
    }
    return ShadingMode(rawValue: UInt32(int))
  }

  @inlinable public var cullBackfaces: Bool? {
    guard let int = getMaterialProperty(.TWOSIDED)?.int.first else {
      return nil
    }

    return !(int == 1)
  }

  public var blendMode: AiBlendMode? {
    guard let int = getMaterialProperty(.BLEND_FUNC)?.int.first else {
      return nil
    }

    return AiBlendMode(aiBlendMode(UInt32(int)))
  }
}

/// Defines alpha-blend flags.
///
/// If you're familiar with OpenGL or D3D, these flags aren't new to you.
/// They define *how* the final color value of a pixel is computed, basing
/// on the previous color at that pixel and the new color value from the
/// material.
/// The blend formula is:
/// ```
///   SourceColor * SourceBlend + DestColor * DestBlend
/// ```
/// where DestColor is the previous color in the frame-buffer at this
/// position and SourceColor is the material color before the transparency
/// calculation.<br>
/// This corresponds to the #AI_MATKEY_BLEND_FUNC property.
///
public enum AiBlendMode {
  /// Default blend mode
  ///
  /// Formula:
  /// ```
  /// SourceColor*SourceAlpha + DestColor*(1-SourceAlpha)
  /// ```
  case `default`

  ///  Additive blending
  ///
  /// Formula:
  /// ```
  /// SourceColor*1 + DestColor*1
  /// ```
  case additive

  init?(_ blendMode: aiBlendMode) {
    switch blendMode {
    case aiBlendMode_Default:
      self = .default

    case aiBlendMode_Additive:
      self = .additive

    default:
      return nil
    }
  }
}

extension Material: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Material(\(name ?? "<no name>"); \(shadingModel?.debugDescription ?? "<no shading>"); \(getMaterialTextureCount(texType: .diffuse)) diffuse textures)"
  }
}
