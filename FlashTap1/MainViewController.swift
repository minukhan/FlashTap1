//
//  MainViewController.swift
//  FlashTap1
//
//  Created by 전우정 on 12/20/24.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.borderWidth = 4.0
            button.layer.borderColor = UIColor(hex: "06C5D8").cgColor
            button.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var buttonGameStart: UIButton! {
        didSet {
            buttonGameStart.layer.borderWidth = 4.0
            buttonGameStart.layer.borderColor = UIColor(hex: "06C5D8").cgColor
            buttonGameStart.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var buttonShowRanking: UIButton! {
        didSet {
            buttonShowRanking.layer.borderWidth = 4.0
            buttonShowRanking.layer.borderColor = UIColor(hex: "06C5D8").cgColor
            buttonShowRanking.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var textFieldNickname: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.tintColor = UIColor(hex: "F377BC")
        buttonGameStart.tintColor = UIColor(hex: "F377BC")
        buttonShowRanking.tintColor = UIColor(hex: "F377BC")
        // TextField 설정
        textFieldNickname.delegate = self
    }
    
    private func isValidNickname() -> Bool {
        guard let nickname = textFieldNickname.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !nickname.isEmpty else {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameViewController" {
            
            if let gameVC = segue.destination as? GameViewController {
                let trimmedNickname = textFieldNickname.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                gameVC.nickname = trimmedNickname
            } else {
                print("❌ GameViewController로 닉네임 전달 실패")
            }
        }
        textFieldNickname.text = ""
    }
    
    // 경고 알림창 표시
    private func showNicknameAlert() {
        let alert = UIAlertController(
            title: "⚠️",
            message: "닉네임을 입력하지 않으면 기록이 저장되지 않습니다.\n그래도 계속하시겠습니까?",
            preferredStyle: .alert
        )
        
        // 계속하기 액션
        let continueAction = UIAlertAction(title: "계속하기", style: .destructive) { [weak self] _ in
            // 닉네임 없이 게임 화면으로 이동
            self?.performSegue(withIdentifier: "gameViewController", sender: nil)
        }
        
        // 취소 액션
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(continueAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // segue 실행 전 호출되는 함수
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "gameViewController" {
            if !isValidNickname() {
                showNicknameAlert()
                return false
            }
        }
        return true
    }
}


