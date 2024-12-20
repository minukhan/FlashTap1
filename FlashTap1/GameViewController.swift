import UIKit

class GameViewController: UIViewController {
    
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
    // MARK: - 점수 라벨
    @IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: - 게임 시간 라벨
    @IBOutlet weak var timerLabel: UILabel!
    
    // 카운트다운 레이블 추가
        private lazy var countdownLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 100, weight: .bold)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0
            return label
        }()
        
        // 변수
        var score = 0
        var activeButtons: [UIButton] = []
        var buttonColors: [UIButton: UIColor] = [:]
        var gameTimer: Timer?
        var remainingTime = 20
        var gameOver = false
        var colorChangeTimer: Timer?
        var colorChangeCount = 0
        var maxColorChanges = 10
        var countdownTimer: Timer?
        var countdownTime = 3
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupCountdownLabel()
            setupButtons()
            setupInitialState()
            startCountdown()
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
        
        private func setupButtons() {
            let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                          tapButton6, tapButton7, tapButton8, tapButton9]
            
            for button in buttons {
                button?.tintColor = .white
                buttonColors[button!] = .white
                button?.setTitle(" ", for: .normal)
                button?.isEnabled = false
                button?.alpha = 0.5 // 비활성화된 상태를 시각적으로 표시
                button?.layer.borderWidth = 2.0 // 테두리 두께
                button?.layer.borderColor = UIColor(hex: "F377BC").cgColor
                button?.layer.cornerRadius = 8
            }
        }
        
        private func setupInitialState() {
            score = 0
            scoreLabel.text = "0"
            remainingTime = 20
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
            countdownLabel.text = "START!"
            countdownLabel.textColor = .systemGreen
            
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
            timerLabel.text = "\(remainingTime) 초"
            changeButtonColorRandomly()
            startGameTimer()
        }
    // MARK: - 버튼 클릭 액션
    @IBAction func buttonTapped(_ sender: UIButton) {
        // 버튼을 눌렀을 때 작아지는 애니메이션을 실행합니다
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (completed) in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity  // 원래 크기로 복원
            }
            
            // 버튼의 색상에 따라 다른 점수 로직을 적용합니다
            if sender.tintColor == UIColor(hex: "F377BC") {
                // 초록색 버튼을 맞게 눌렀을 때: 100점 증가
                self.score += 100
                self.scoreLabel.text = "\(self.score)"
                
                // 클릭된 버튼의 색을 흰색으로 복원합니다
                sender.tintColor = .white
            } else {
                // 흰색 버튼을 잘못 눌렀을 때: 50점 감소
                self.score = max(0, self.score - 50)  // 점수가 0 미만으로 내려가지 않도록 합니다
                self.scoreLabel.text = "\(self.score)"
            }
        }
    }
    
    // MARK: - 게임 타이머 시작
    func startGameTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    // MARK: - 타이머 업데이트
    @objc func updateTimer() {
        remainingTime -= 1
        timerLabel.text = "\(remainingTime) 초"
        
        if remainingTime <= 0 {
            endGame()
        }
    }
    
    // MARK: - 게임 종료
    func endGame() {
        gameTimer?.invalidate() // 타이머 종료
        timerLabel.text = "Game Over!"
        
        // 모든 버튼 비활성화
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5, tapButton6, tapButton7, tapButton8, tapButton9]
        for button in buttons {
            button?.isEnabled = false
        }
        
        // 게임 종료 상태 설정
        gameOver = true
    }
    
    // MARK: - 버튼
    func changeButtonColorRandomly() {
        guard !gameOver else { return }
        
        // 현재 초록색인 버튼들의 수를 확인합니다
        let currentYellowButtons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                                  tapButton6, tapButton7, tapButton8, tapButton9]
            .filter { $0?.tintColor == UIColor(hex: "F377BC") }
        
        // 초록색 버튼이 5개 이상이면 더 이상 생성하지 않습니다
        if currentYellowButtons.count >= 5 {
            // 0.2초 후에 다시 확인하여 새로운 버튼을 생성할 수 있는지 체크합니다
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.changeButtonColorRandomly()
            }
            return
        }
        
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                      tapButton6, tapButton7, tapButton8, tapButton9]
        
        // 현재 흰색인 버튼들만 선택 가능하도록 필터링합니다
        let availableButtons = buttons.filter { $0?.tintColor == .white }
        
        // 사용 가능한 버튼이 있고, 현재 초록색 버튼이 3개 미만일 때만 새로운 버튼을 생성합니다
        if let randomButton = availableButtons.randomElement()! {
            // 0.3~0.8초 사이의 랜덤한 시간으로 설정하여 자연스러운 등장 타이밍을 만듭니다
            let randomTime = TimeInterval(arc4random_uniform(5) + 1) / 10.0  // 0.1~0.6초
            
            DispatchQueue.main.asyncAfter(deadline: .now() + randomTime) { [weak self] in
                guard let self = self, !self.gameOver else { return }
                
                // 게임이 진행 중이고 해당 버튼이 아직 흰색일 때만 초록색으로 변경합니다
                if randomButton.tintColor == .white {
                    randomButton.tintColor = UIColor(hex: "F377BC")
                    
                    // 1초 동안 초록색을 유지한 후 흰색으로 돌아갑니다
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let self = self, !self.gameOver else { return }
                        randomButton.tintColor = .white
                    }
                }
                
                // 다음 버튼 생성을 위해 0.2초 후에 함수를 다시 호출합니다
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.changeButtonColorRandomly()
                }
            }
        } else {
            // 사용 가능한 버튼이 없다면 0.2초 후에 다시 시도합니다
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
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
