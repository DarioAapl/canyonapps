// Puts an app screenshot into Apple's official iPhone 17 Pro bezel PNG (frame unmodified, drawn on top).
// Usage: swift frame-screenshot.swift <bezel.png> <screenshot.png> <out.png>
import AppKit

func cg(_ path: String) -> CGImage {
    let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
    return CGImageSourceCreateImageAtIndex(src, 0, nil)!
}
let a = CommandLine.arguments
let bezel = cg(a[1]), shot = cg(a[2])
let W = bezel.width, H = bezel.height
precondition(shot.width == 1206 && shot.height == 2622, "expected an iPhone 17 Pro screenshot (1206x2622)")
// Screen is centred in the bezel.
let screen = CGRect(x: (W - shot.width) / 2, y: (H - shot.height) / 2, width: shot.width, height: shot.height)
let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
// Clip to the display's rounded corners (iPhone 17 Pro: ~55 pt radius at 3x) so no square corner shows outside the bezel.
ctx.saveGState()
ctx.addPath(CGPath(roundedRect: screen, cornerWidth: 168, cornerHeight: 168, transform: nil))
ctx.clip()
ctx.draw(shot, in: screen)
ctx.restoreGState()
ctx.draw(bezel, in: CGRect(x: 0, y: 0, width: W, height: H))
let out = CGImageDestinationCreateWithURL(URL(fileURLWithPath: a[3]) as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(out, ctx.makeImage()!, nil)
CGImageDestinationFinalize(out)
print("framed \(a[2]) into \(W)x\(H)")
