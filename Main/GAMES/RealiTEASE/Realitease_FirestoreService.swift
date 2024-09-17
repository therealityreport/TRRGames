//
//  Realitease_FirestoreService.swift
//  TRR-Project
//
//  Created by thomas hulihan on 6/1/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class RealiteaseFirestoreService {
    private let db = Firestore.firestore()

    func fetchTodayAnswer(completion: @escaping (Result<RealiteaseAnswerKey, Error>) -> Void) {
        let todayString = getTodayString()
        db.collection("realitease_answerkey").document(todayString).getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let answerKey = try document.data(as: RealiteaseAnswerKey.self)
                    completion(.success(answerKey))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }

    func fetchAllCastNames(completion: @escaping (Result<[String], Error>) -> Void) {
        db.collection("realitease_data").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                let castNames = snapshot.documents.compactMap { document in
                    return document.data()["CastName"] as? String
                }
                completion(.success(castNames))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }

    func fetchCorrectCastInfo(castID: Int, completion: @escaping (Result<RealiteaseCastInfo, Error>) -> Void) {
        db.collection("realitease_data").document("\(castID)").getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let castInfo = try document.data(as: RealiteaseCastInfo.self)
                    completion(.success(castInfo))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }

    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}


