//
//  FaceEmbedder.swift
//  IOS-App
//
//  Created by SDC-USER on 14/01/26.
//

import CoreML
import UIKit
import Vision

final class FaceEmbedder {

    static let shared = try! FaceEmbedder()

    private let model: ArcFaceResNet50
    private let ciContext = CIContext(options: nil)

    private init() throws {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly
        self.model = try ArcFaceResNet50(configuration: config)
    }

    func embedding(from faceImage: UIImage) -> [Float]? {
        guard let cgImage = faceImage.cgImage else { return nil }
        return generateEmbedding(from: cgImage)
    }

    private func generateEmbedding(from faceImage: CGImage) -> [Float]? {
        guard let resized = resize(faceImage, to: 112),
              let input = imageToMultiArray(resized),
              let output = try? model.prediction(input: input)
        else {
            return nil
        }

        let raw = output.var_1312
        var vector = [Float](repeating: 0, count: 512)
        for i in 0..<512 {
            vector[i] = raw[i].floatValue
        }
        return l2Normalize(vector)
    }

    private func imageToMultiArray(_ image: CGImage) -> MLMultiArray? {
        let size = 112
        guard let array = try? MLMultiArray(
            shape: [1, 3, size, size] as [NSNumber],
            dataType: .float32
        ) else { return nil }

        guard let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else { return nil }

        ctx.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
        let pixels = ctx.data!.bindMemory(to: UInt8.self, capacity: size * size * 4)

        for y in 0..<size {
            for x in 0..<size {
                let p = (y * size + x) * 4
                let r = (Float(pixels[p]) / 127.5) - 1
                let g = (Float(pixels[p+1]) / 127.5) - 1
                let b = (Float(pixels[p+2]) / 127.5) - 1

                let idx = y * size + x
                array[idx] = NSNumber(value: r)
                array[size*size + idx] = NSNumber(value: g)
                array[2*size*size + idx] = NSNumber(value: b)
            }
        }
        return array
    }

    private func resize(_ image: CGImage, to size: Int) -> CGImage? {
        let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        )
        ctx?.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
        return ctx?.makeImage()
    }

    private func l2Normalize(_ v: [Float]) -> [Float] {
        let norm = sqrt(v.reduce(0) { $0 + $1*$1 })
        return v.map { $0 / norm }
    }
}
