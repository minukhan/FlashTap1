import UIKit

class ViewController: UIViewController {
    
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
    
    // MARK: - 변수
        var score = 0
        var activeButtons: [UIButton] = [] // 노란색으로 바뀐 버튼을 추적하는 배열
        var buttonColors: [UIButton: UIColor] = [:] // 원래 색 저장
        var gameTimer: Timer?
        var remainingTime = 8 // 게임 시간 (초)
        var gameOver = false // 게임 종료 상태 추적
        var colorChangeTimer: Timer? // 색상 변경 타이머
        var colorChangeCount = 0 // 색상 변경 횟수 (최대 10번)
        let maxColorChanges = 10 // 색상 변경 횟수 제한
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 초기 설정 (버튼 색상 초기화)
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5, tapButton6, tapButton7, tapButton8, tapButton9]
        
        for button in buttons {
            button?.tintColor = .blue // 기본 색상은 파란색
            buttonColors[button!] = .blue // 원래 색 저장
            button?.setTitle("Click!", for: .normal)
        }
        
        // 점수 초기화
        score = 0
        scoreLabel.text = "\(score)"
        
        // 게임 시간 초기화
        remainingTime = 20
        timerLabel.text = "\(remainingTime) 초"
        
        self.view.tintColor = .white
        
        // 버튼에 대해 랜덤으로 노란색으로 바꾸는 타이머 설정
        changeButtonColorRandomly()
        
        // 게임 타이머 시작
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
            if sender.tintColor == .yellow {
                // 노란색 버튼을 맞게 눌렀을 때: 100점 증가
                self.score += 100
                self.scoreLabel.text = "\(self.score)"
                
                // 클릭된 버튼의 색을 파란색으로 복원합니다
                sender.tintColor = .blue
            } else {
                // 파란색 버튼을 잘못 눌렀을 때: 50점 감소
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
    
    func changeButtonColorRandomly() {
        guard !gameOver else { return }
        
        // 현재 노란색인 버튼들의 수를 확인합니다
        let currentYellowButtons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                                  tapButton6, tapButton7, tapButton8, tapButton9]
            .filter { $0?.tintColor == .yellow }
        
        // 노란색 버튼이 3개 이상이면 더 이상 생성하지 않습니다
        if currentYellowButtons.count >= 3 {
            // 0.2초 후에 다시 확인하여 새로운 버튼을 생성할 수 있는지 체크합니다
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.changeButtonColorRandomly()
            }
            return
        }
        
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5,
                      tapButton6, tapButton7, tapButton8, tapButton9]
        
        // 현재 파란색인 버튼들만 선택 가능하도록 필터링합니다
        let availableButtons = buttons.filter { $0?.tintColor == .blue }
        
        // 사용 가능한 버튼이 있고, 현재 노란색 버튼이 3개 미만일 때만 새로운 버튼을 생성합니다
        if let randomButton = availableButtons.randomElement()! {
            // 0.3~0.8초 사이의 랜덤한 시간으로 설정하여 자연스러운 등장 타이밍을 만듭니다
            let randomTime = TimeInterval(arc4random_uniform(5) + 3) / 10.0  // 0.3~0.8초
            
            DispatchQueue.main.asyncAfter(deadline: .now() + randomTime) { [weak self] in
                guard let self = self, !self.gameOver else { return }
                
                // 게임이 진행 중이고 해당 버튼이 아직 파란색일 때만 노란색으로 변경합니다
                if randomButton.tintColor == .blue {
                    randomButton.tintColor = .yellow
                    
                    // 1초 동안 노란색을 유지한 후 파란색으로 돌아갑니다
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let self = self, !self.gameOver else { return }
                        randomButton.tintColor = .blue
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
