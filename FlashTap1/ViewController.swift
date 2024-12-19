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
            button?.backgroundColor = .blue // 기본 색상은 파란색
            buttonColors[button!] = .blue // 원래 색 저장
            button?.setTitle("나잡아봐라~", for: .normal)
        }
        
        // 점수 초기화
        score = 0
        scoreLabel.text = "\(score)"
        
        // 게임 시간 초기화
        remainingTime = 8
        timerLabel.text = "\(remainingTime) 초"
        
        self.view.backgroundColor = .white
        
        // 버튼에 대해 랜덤으로 노란색으로 바꾸는 타이머 설정
        changeButtonColorRandomly()
        
        // 게임 타이머 시작
        startGameTimer()
    }
    
    // MARK: - 버튼 클릭 액션
    @IBAction func buttonTapped(_ sender: UIButton) {
        // 노란색 버튼 클릭 시 점수 1점 증가
        if sender.backgroundColor == .yellow {
            score += 1
            scoreLabel.text = "\(score)"
            
            // 클릭된 버튼의 색을 원래 색으로 복원
            sender.backgroundColor = .blue
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
        
        guard !gameOver else { return } // 게임 종료 상태라면 더 이상 실행하지 않음
        
        // 버튼들을 랜덤하게 5초 후에 노란색으로 변경
        let buttons = [tapButton1, tapButton2, tapButton3, tapButton4, tapButton5, tapButton6, tapButton7, tapButton8, tapButton9]
        
        for button in buttons {
            // 랜덤 시간(1초 ~ 5초 후)에 버튼을 노란색으로 변경
            let randomTime = TimeInterval(arc4random_uniform(5) + 1) // 1초 ~ 5초 사이 랜덤 시간
            
            DispatchQueue.main.asyncAfter(deadline: .now() + randomTime) {
                if let btn = button {
                    btn.backgroundColor = .yellow
                    self.activeButtons.append(btn) // 노란색으로 변경된 버튼을 추적
                    
                    // 계속 랜덤하게 색상 변경하도록 재귀 호출
                    self.changeButtonColorRandomly()
                }
            }
        }
    }
}
