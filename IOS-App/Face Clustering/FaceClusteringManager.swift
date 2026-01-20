//
//  FaceClusteringManager.swift
//  IOS-App
//
//  Created by SDC-USER on 14/01/26.
//

import Foundation
internal import CoreData

struct FaceCluster {
    let id: UUID
    var centroid: [Float]
    var count: Int
}


final class FaceClusteringManager {

    static let shared = FaceClusteringManager()
    private init() {}

    private(set) var clusters: [FaceCluster] = []

    private let similarityThreshold: Float = 0.50

    func addFace(embedding: [Float]) -> (cluster: FaceCluster, isNew: Bool) {

        if let index = bestMatchingClusterIndex(for: embedding) {
            clusters[index] = update(cluster: clusters[index], with: embedding)
            return (clusters[index], false)
        }

        let cluster = FaceCluster(
            id: UUID(),
            centroid: embedding,
            count: 1
        )
        clusters.append(cluster)
        return (cluster, true)
    }

    private func bestMatchingClusterIndex(for embedding: [Float]) -> Int? {
        var bestIndex: Int?
        var bestSim: Float = similarityThreshold

        for (i, cluster) in clusters.enumerated() {
            let sim = cosineSimilarity(embedding, cluster.centroid)
            print("Similarity vs cluster:", sim)

            if sim > bestSim {
                bestSim = sim
                bestIndex = i
            }
        }
        
        return bestIndex
    }

    private func update(cluster: FaceCluster, with embedding: [Float]) -> FaceCluster {
        let newCount = cluster.count + 1
        let newCentroid = zip(cluster.centroid, embedding).map {
            ($0 * Float(cluster.count) + $1) / Float(newCount)
        }
        return FaceCluster(
            id: cluster.id,
            centroid: l2Normalize(newCentroid),
            count: newCount
        )
    }

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        zip(a, b).map(*).reduce(0, +)
    }

    private func l2Normalize(_ v: [Float]) -> [Float] {
        let norm = sqrt(v.reduce(0) { $0 + $1*$1 })
        return v.map { $0 / norm }
    }
        
    func bootstrapFromCoreData() {
        clusters.removeAll()

        let context = PersistenceController.shared.context
        let request: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()

        do {
            let people = try context.fetch(request)

            for person in people {

                guard
                    let clusterId = person.clusterId,
                    let faces = person.faces as? Set<FaceImageEntity>,
                    !faces.isEmpty
                else { continue }

                var embeddings: [[Float]] = []

                for face in faces {
                    guard
                        let path = face.imagePath,
                        let image = ImageStorageManager.shared.loadImage(from: path),
                        let embedding = FaceEmbedder.shared.embedding(from: image)
                    else { continue }

                    embeddings.append(embedding)
                }

                guard !embeddings.isEmpty else { continue }

                let centroid = averageAndNormalize(embeddings)

                clusters.append(
                    FaceCluster(
                        id: clusterId,
                        centroid: centroid,
                        count: embeddings.count
                    )
                )
            }

            print("🔁 Bootstrapped clusters:", clusters.count)

        } catch {
            print("❌ Cluster bootstrap failed:", error)
        }
    }

    private func averageAndNormalize(_ vectors: [[Float]]) -> [Float] {
        let count = Float(vectors.count)
        let summed = vectors.reduce(into: [Float](repeating: 0, count: 512)) {
            for i in 0..<512 {
                $0[i] += $1[i]
            }
        }
        let avg = summed.map { $0 / count }
        let norm = sqrt(avg.reduce(0) { $0 + $1*$1 })
        return avg.map { $0 / norm }
    }

    
    func mergeSimilarClusters() {
        guard clusters.count > 1 else { return }
        var merged = Set<Int>()
        for i in 0..<clusters.count {
            if merged.contains(i) { continue }
            for j in (i+1)..<clusters.count {
                if merged.contains(j) { continue }
                let sim = cosineSimilarity(
                    clusters[i].centroid,
                    clusters[j].centroid
                )
                if sim >= 0.75 {
                    mergeCluster(at: j, into: i)
                    merged.insert(j)
                    print("🔀 Merged clusters:", clusters[j].id, "→", clusters[i].id)
                }
            }
        }

        clusters = clusters.enumerated()
            .filter { !merged.contains($0.offset) }
            .map { $0.element }
    }

    private func mergeCluster(at from: Int, into to: Int) {
        let c1 = clusters[to]
        let c2 = clusters[from]

        let total = Float(c1.count + c2.count)

        let newCentroid = zip(c1.centroid, c2.centroid).map {
            ($0 * Float(c1.count) + $1 * Float(c2.count)) / total
        }

        clusters[to] = FaceCluster(
            id: c1.id,
            centroid: l2Normalize(newCentroid),
            count: c1.count + c2.count
        )

        mergePersons(from: c2.id, into: c1.id)
    }

    private func mergePersons(from sourceId: UUID, into targetId: UUID) {
        let context = PersistenceController.shared.context

        let request: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "clusterId IN %@",
            [sourceId, targetId]
        )

        guard let people = try? context.fetch(request),
              people.count == 2
        else { return }

        let source = people.first { $0.clusterId == sourceId }!
        let target = people.first { $0.clusterId == targetId }!

        if let faces = source.faces as? Set<FaceImageEntity> {
            for face in faces {
                face.person = target
            }
        }

        context.delete(source)
        try? context.save()
    }


}
