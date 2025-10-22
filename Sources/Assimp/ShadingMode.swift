@_implementationOnly import CAssimp

public struct ShadingMode: RawRepresentable {
  public let rawValue: UInt32

  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }

  init(_ shadingMode: aiShadingMode) {
    rawValue = shadingMode.rawValue
  }

  /** Flat shading. Shading is done on per-face base,
   *  diffuse only. Also known as 'faceted shading'.
   */
  public static let flat = ShadingMode(aiShadingMode_Flat)

  /** Simple Gouraud shading.
   */
  public static let gouraud = ShadingMode(aiShadingMode_Gouraud)

  /** Phong-Shading -
   */
  public static let phong = ShadingMode(aiShadingMode_Phong)

  /** Phong-Blinn-Shading
   */
  public static let blinn = ShadingMode(aiShadingMode_Blinn)

  /** Toon-Shading per pixel
   *
   *  Also known as 'comic' shader.
   */
  public static let toon = ShadingMode(aiShadingMode_Toon)

  /** OrenNayar-Shading per pixel
   *
   *  Extension to standard Lambertian shading, taking the
   *  roughness of the material into account
   */
  public static let orenNayar = ShadingMode(aiShadingMode_OrenNayar)

  /** Minnaert-Shading per pixel
   *
   *  Extension to standard Lambertian shading, taking the
   *  "darkness" of the material into account
   */
  public static let minnaert = ShadingMode(aiShadingMode_Minnaert)

  /** CookTorrance-Shading per pixel
   *
   *  Special shader for metallic surfaces.
   */
  public static let cookTorrance = ShadingMode(aiShadingMode_CookTorrance)

  /** No shading at all. Constant light influence of 1.0.
   */
  public static let noShading = ShadingMode(aiShadingMode_NoShading)

  /** Fresnel shading
   */
  public static let fresnel = ShadingMode(aiShadingMode_Fresnel)
}

extension ShadingMode: Equatable {}
extension ShadingMode: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .flat:
      return "flat"
    case .blinn:
      return "blinn"
    case .cookTorrance:
      return "cookTorrance"
    case .fresnel:
      return "fresnel"
    case .gouraud:
      return "gouraud"
    case .minnaert:
      return "minnaert"
    case .noShading:
      return "noShading"
    case .orenNayar:
      return "orenNayar"
    case .phong:
      return "phong"
    case .toon:
      return "toon"
    default:
      return "ShadingMode<Unknown>(\(rawValue))"
    }
  }
}
