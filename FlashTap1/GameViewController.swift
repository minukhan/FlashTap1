import UIKit
import FirebaseFirestore

class GameViewController: UIViewController {
    let db = Firestore.firestore()
    
    var nickname: String = ""
    
    // MARK: - IBOutlet 연결 (버튼 9개)
    @IBOutlet weak var tapButton1: UIButton!
    @IBOutlet weak var tapButton2: UIButton!
    @IBOutlet weak var tapButton3: UIButton!
    @IBOutlet weak var tapButton4: UIButton!
    @IBOutlet weak var tapButton5: UIButton!
    @IBOutlet weak var tapButton6: UIButton!
    @IBOutlet weak var tapButton7: UIButton!
    @IBOutlet weak var tapButton8: UIButton!
    @IBOutlet weak var tapButton9: UIButton!
    // MARK: - 라벨
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    private lazy var countdownLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 100, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    private lazy var feverLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🔥 FEVER TIME 🔥"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = UIColor(hex: "F377BC")
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    // 변수
    var score = 0
    var activeButtons: [UIButton] = []
    var buttonColors: [UIButton: UIColor] = [:]
    var gameTimer: Timer?
    var remainingTime = 30
    var gameOver = false
    var colorChangeTimer: Timer?
    var colorChangeCount = 0
    var maxColorChanges = 10
    var countdownTimer: Timer?
    var countdownTime = 3
    var isFeverTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(nickname)
        setupFeverLabel()
        setupCountdownLabel()
        setupButtons()
        setupInitialState()
        startCountdown()
    }
    
    // MARK: - 랭킹 저장 함수
    private func saveScore(completion: @escaping (Error?) -> Void) {
        // 닉네임이 공백일 경우 기록을 저장하지 않습니다
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNickname.isEmpty {
            return
        }
        
        print("🔍 닉네임 확인:", nickname)
        
        // 저장할 데이터 구성
        let rankingData: [String: Any] = [
            "nickname": trimmedNickname,
            "score": score,
            "date": Timestamp(date: Date())
        ]
        
        print("📝 저장할 데이터:", rankingData)
        
        // Firestore에 저장
        db.collection("rankings").addDocument(data: rankingData) { error in
            if let error = error {
                print("❌ 서버에 저장 실패:", error.localizedDescription)
                completion(error)
            } else {
                print("✅ 서버에 저장 성공")
                completion(nil)
            }
        }
    }
    
    // MARK: - 초기 설정 함수들
    private func setupCountdownLabel() {
        view.addSubview(countdownLabel)
        
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countdownLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            countdownLabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupFeverLabel() {
        view.addSubview(feverLabel)
        NSLayoutConstraint.activate([
            feverLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feverLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            feverLabel.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    private func setupButtons() {
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                       tapButton6, tapButton7, tapButton8, tapButton9]
        
        for button in buttons {
            button?.tintColor = UIColor(hex: "01264B")
            buttonColors[button!] = UIColor(hex: "01264B")
            button?.setTitle(" ", for: .normal)
            button?.isEnabled = false
            button?.alpha = 0.5 // 비활성화된 상태를 시각적으로 표시
            button?.layer.borderWidth = 4.0
            button?.layer.borderColor = UIColor(hex: "06C5D8").cgColor
            button?.layer.cornerRadius = 6
        }
    }
    
    private func setupInitialState() {
        score = 0
        scoreLabel.text = "0"
        remainingTime = 30
        timerLabel.text = "Ready!"
        self.view.tintColor = UIColor(hex: "F377BC")
    }
    
    // MARK: - 카운트다운 관련 함수
    private func startCountdown() {
        countdownTime = 3
        animateCountdown()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.countdownTime -= 1
            
            if self.countdownTime > 0 {
                self.animateCountdown()
            } else {
                timer.invalidate()
                self.animateGameStart()
            }
        }
    }
    
    private func animateCountdown() {
        // 이전 애니메이션 리셋
        countdownLabel.transform = .identity
        countdownLabel.alpha = 0
        
        // 카운트다운 텍스트 설정
        countdownLabel.text = "\(countdownTime)"
        
        // 줌인 애니메이션과 페이드인
        UIView.animate(withDuration: 0.5, animations: {
            self.countdownLabel.alpha = 1
            self.countdownLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            // 줌아웃 애니메이션과 페이드아웃
            UIView.animate(withDuration: 0.5, delay: 0.2, animations: {
                self.countdownLabel.alpha = 0
                self.countdownLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
        }
    }
    
    private func animateGameStart() {
        countdownLabel.text = "TAP!"
        countdownLabel.textColor = UIColor(hex: "F377BC")
        
        // 시작 애니메이션
        UIView.animate(withDuration: 0.5, animations: {
            self.countdownLabel.alpha = 1
            self.countdownLabel.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.countdownLabel.alpha = 0
                self.countdownLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.startGame()
            }
        }
    }
    
    // MARK: - 게임 시작 함수
    private func startGame() {
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                       tapButton6, tapButton7, tapButton8, tapButton9]
        
        // 버튼 활성화 애니메이션
        UIView.animate(withDuration: 0.3) {
            for button in buttons {
                button?.isEnabled = true
                button?.alpha = 1.0
            }
        }
        
        // 게임 시작
        timerLabel.text = "\(remainingTime) sec"
        changeButtonColorRandomly()
        startGameTimer()
    }
    
    // MARK: - 버튼 클릭 액션
    // 버튼 클릭 액션 수정
    @IBAction func buttonTapped(_ sender: UIButton) {
        // 1. 햅틱 피드백 추가
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // 2. 버튼 애니메이션
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            sender.alpha = 0.7
        }) { (completed) in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
                sender.alpha = 1.0
            }
            
            // 3. 점수 로직 및 추가 효과
            if sender.tintColor == UIColor(hex: "F377BC") {
                // 성공 시 반짝이는 효과
                self.addSparkleAnimation(to: sender)
                
                let points = self.isFeverTime ? 200 : 100
                self.score += points
                self.animateScoreLabel(points: points)
                
                sender.tintColor = UIColor(hex: "01264B")
            } else {
                // 실패 시 흔들리는 효과
                self.addShakeAnimation(to: sender)
                
                let penalty = self.isFeverTime ? 100 : 50
                self.score = max(0, self.score - penalty)
                self.scoreLabel.text = "\(self.score)"
            }
        }
    }
    
    // 반짝이는 효과 추가
    private func addSparkleAnimation(to button: UIButton) {
        let sparkle = CAEmitterLayer()
        sparkle.emitterPosition = CGPoint(x: button.bounds.width/2, y: button.bounds.height/2)
        
        let cell = CAEmitterCell()
        cell.birthRate = 100
        cell.lifetime = 0.5
        cell.velocity = 50
        cell.scale = 0.1
        cell.scaleRange = 0.2
        cell.emissionRange = .pi * 2
        
        // 원형 파티클 이미지 생성
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        let particleImage = renderer.image { context in
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: CGSize(width: 8, height: 8)))
        }
        
        cell.contents = particleImage.cgImage
        cell.color = UIColor(hex: "efbf04").cgColor
        
        sparkle.emitterCells = [cell]
        button.layer.addSublayer(sparkle)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sparkle.removeFromSuperlayer()
        }
    }
    
    // 점수 라벨 애니메이션
    private func animateScoreLabel(points: Int) {
        // 현재 점수 업데이트
        scoreLabel.text = "\(score)"
        
        // 획득 점수 표시 레이블 생성
        let pointsLabel = UILabel()
        pointsLabel.text = "+\(points)"
        pointsLabel.textColor = UIColor(hex: "F377BC")
        pointsLabel.font = .systemFont(ofSize: 24, weight: .bold)
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pointsLabel)
        
        // 위치 설정
        NSLayoutConstraint.activate([
            pointsLabel.centerXAnchor.constraint(equalTo: scoreLabel.centerXAnchor),
            pointsLabel.bottomAnchor.constraint(equalTo: scoreLabel.topAnchor, constant: -10)
        ])
        
        // 애니메이션
        UIView.animate(withDuration: 0.2, animations: {
            pointsLabel.transform = CGAffineTransform(translationX: 0, y: -30)
            pointsLabel.alpha = 0
        }) { _ in
            pointsLabel.removeFromSuperview()
        }
    }
    
    // 흔들리는 효과
    private func addShakeAnimation(to button: UIButton) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.2
        animation.values = [-5.0, 5.0, -5.0, 5.0, -2.5, 2.5, -1.0, 1.0, 0.0]
        button.layer.add(animation, forKey: "shake")
    }
    
    // MARK: - 게임 타이머 시작
    func startGameTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    // MARK: - 타이머 업데이트
    @objc func updateTimer() {
        remainingTime -= 1
        timerLabel.text = "\(remainingTime) sec"
        
        // FEVER 타임 체크
        if remainingTime == 10 {
            isFeverTime = true
            UIView.animate(withDuration: 0.5) {
                self.feverLabel.alpha = 1
            }
        }
        
        if remainingTime <= 0 {
            endGame()
        }
    }
    
    // MARK: - 게임 종료
    func endGame() {
        gameTimer?.invalidate()
        timerLabel.text = "Game Over!"
        
        // 버튼 비활성화
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                       tapButton6, tapButton7, tapButton8, tapButton9]
        for button in buttons {
            button?.isEnabled = false
        }
        
        gameOver = true
        
        // 점수 저장
        saveScore { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                var message = "점수: \(self.score)점"
                if let error = error {
                    message += "\n점수 저장 실패: \(error.localizedDescription)"
                } else {
                    message += "\n랭킹을 확인해보세요!"
                }
                
                let alert = UIAlertController(
                    title: "게임 종료!",
                    message: message,
                    preferredStyle: .alert
                )
                
                let restartAction = UIAlertAction(title: "다시 하기", style: .default) { [weak self] _ in
                    self?.resetGame()
                }
                
                let quitAction = UIAlertAction(title: "종료", style: .cancel)
                
                alert.addAction(restartAction)
                alert.addAction(quitAction)
                
                self.present(alert, animated: true)
            }
        }
    }
    
    private func resetGame() {
        score = 0
        remainingTime = 30
        gameOver = false
        isFeverTime = false
        feverLabel.alpha = 0
        setupInitialState()
        startCountdown()
    }
    
    // MARK: - 버튼
    func changeButtonColorRandomly() {
        guard !gameOver else { return }
        // 현재 분홍색인 버튼들의 수를 확인합니다
        let currentYellowButtons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                                    tapButton6, tapButton7, tapButton8, tapButton9]
            .filter { $0?.tintColor == UIColor(hex: "F377BC") }
        
        // 버튼이 5개 이상이면 더 이상 생성하지 않습니다
        if currentYellowButtons.count >= 5 {
            // 0.2초 후에 다시 확인하여 새로운 버튼을 생성할 수 있는지 체크합니다
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.changeButtonColorRandomly()
            }
            return
        }
        
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                       tapButton6, tapButton7, tapButton8, tapButton9]
        
        // 현재 배경색인 버튼들만 선택 가능하도록 필터링합니다
        let availableButtons = buttons.filter { $0?.tintColor == UIColor(hex: "01264B") }
        
        if let randomButton = availableButtons.randomElement()! {
            // 랜덤하게 시간 설정
            let randomTime = TimeInterval(arc4random_uniform(5) + 1) / 10.0  // 0.1~0.5초
            
            DispatchQueue.main.asyncAfter(deadline: .now() + randomTime) { [weak self] in
                guard let self = self, !self.gameOver else { return }
                
                // 게임이 진행 중이고 해당 버튼이 아직 배경색일 때만 분홍색으로 변경합니다
                if randomButton.tintColor == UIColor(hex: "01264B") {
                    randomButton.tintColor = UIColor(hex: "F377BC")
                    
                    // 1초 동안 분홍색을 유지한 후 배경색으로 돌아갑니다
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let self = self, !self.gameOver else { return }
                        randomButton.tintColor = UIColor(hex: "01264B")
                    }
                }
                
                // 다음 버튼 생성을 위해 0.2초 후에 함수를 다시 호출합니다
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.changeButtonColorRandomly()
                }
            }
        } else {
            // 사용 가능한 버튼이 없다면 0.2초 후에 다시 시도합니다
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.changeButtonColorRandomly()
            }
        }
        
    }
}

// MARK: - UIColor Extension for Hex
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
