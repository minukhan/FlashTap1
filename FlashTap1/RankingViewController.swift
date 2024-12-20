import Foundation
import UIKit
import FirebaseFirestore

// 랭킹 데이터 모델 수정
struct RankingData {
    let rank: Int
    let nickname: String
    let score: Int
    let date: Date
}

class RankingViewController: UIViewController, UITableViewDelegate {
    
    let db = Firestore.firestore()
    
    var nickname: String = ""
    
    @IBOutlet weak var rankingTableView: UITableView!
    
    private var rankings: [RankingData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rankingTableView.backgroundColor = UIColor(hex: "01264B")
        setupTableView()
        loadRankings()
    }
    
    private func setupTableView() {
        rankingTableView.delegate = self
        rankingTableView.dataSource = self
        rankingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
    }

    
    // 랭킹 데이터 저장 - 에러 핸들링 추가
    func saveRanking(nickname: String, score: Int, completion: @escaping (Error?) -> Void) {
        db.collection("rankings").addDocument(data: [
            "nickname": nickname,
            "score": score,
            "date": Timestamp(date: Date())
        ]) { error in
            completion(error)
        }
    }
    
    // 랭킹 데이터 불러오기 - 에러 핸들링 추가
    func loadRankings() {
        db.collection("rankings")
            .order(by: "score", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading rankings: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self?.rankings = documents.enumerated().map { index, doc in
                    let data = doc.data()
                    return RankingData(
                        rank: index + 1,
                        nickname: data["nickname"] as? String ?? "Unknown",
                        score: data["score"] as? Int ?? 0,
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                
                DispatchQueue.main.async {
                    self?.rankingTableView.reloadData()
                }
            }
    }
    
    
    // 순위별 메달 이모지 반환 함수
    private func medalEmoji(for rank: Int) -> String {
        switch rank {
        case 1: return "🥇 "
        case 2: return "🥈 "
        case 3: return "🥉 "
        default: return ""
        }
    }
}
    
extension RankingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.backgroundColor = UIColor(hex: "01264B")
        
        let ranking = rankings[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .white
        
        let medal = medalEmoji(for: ranking.rank)
        content.text = "\(medal)\(ranking.rank)등  \(ranking.nickname)"
        content.secondaryText = "\(ranking.score)점  (\(dateFormatter.string(from: ranking.date)))"
        
        cell.contentConfiguration = content
        return cell
    }
}
