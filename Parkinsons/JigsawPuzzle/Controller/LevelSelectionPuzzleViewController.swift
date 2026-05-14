
import UIKit
import SwiftUI

class LevelSelectionPuzzleViewController: UIViewController,
                                          UICollectionViewDataSource,
                                          UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var monthAndYearOutlet: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        return c
    }()

    private let today           = Calendar(identifier: .gregorian).startOfDay(for: Date())
    private var firstDayOfMonth: Date!
    private var daysInMonth         = 0
    private var firstWeekdayOffset  = 0
    private var selectedDate: Date?
    private var layoutConfigured    = false
    private var gradientView: UIView?

    private func setupGradientLayer() {
        if gradientView == nil {
            let gView = UIView()
            gView.isUserInteractionEnabled = false
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 0.545, green: 0.271, blue: 0.075, alpha: 0.35).cgColor, // SaddleBrown
                UIColor(red: 0.545, green: 0.271, blue: 0.075, alpha: 0.0).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint   = CGPoint(x: 0.5, y: 1)
            gView.layer.addSublayer(gradient)
            view.addSubview(gView)
            gradientView = gView
        }
        gradientView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
        gradientView?.layer.sublayers?.first?.frame = gradientView?.bounds ?? .zero
        if let gv = gradientView {
            view.bringSubviewToFront(gv)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupMonth()
        updateMonthLabel()
        title = "Jigsaw Puzzle"
        setupGradientLayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !layoutConfigured {
            layoutConfigured = true
            configureLayout()
            collectionView?.reloadData()
        }
        title = "Jigsaw Puzzle"
        setupGradientLayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCompletionCount()
        collectionView?.reloadData()
        title = "Jigsaw Puzzle"
        
        tabBarController?.tabBar.isHidden = true
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupGradientLayer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            tabBarController?.tabBar.isHidden = false
        }
    }

    private func setupCollectionView() {
        guard let cv = collectionView else { return }
        cv.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        cv.dataSource      = self
        cv.delegate        = self
        cv.backgroundColor = .clear
    }

    private func setupMonth() {
        let comps          = calendar.dateComponents([.year, .month], from: Date())
        firstDayOfMonth    = calendar.date(from: comps)!
        daysInMonth        = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        let weekday        = calendar.component(.weekday, from: firstDayOfMonth)
        firstWeekdayOffset = (weekday - calendar.firstWeekday + 7) % 7
        selectedDate       = today
        updateEmojiImage()
    }

    private func updateMonthLabel() {
        guard let label = monthAndYearOutlet, let date = firstDayOfMonth else { return }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        label.text = fmt.string(from: date)
    }

    private func updateEmojiImage() {
        guard let date = selectedDate, let iv = imageView else { return }
        let emoji      = PuzzleConstants.emoji(for: date)
        iv.image       = PuzzleGeneratorService.makeEmojiImage(emoji: emoji, size: CGSize(width: 300, height: 300))
        iv.contentMode = .scaleAspectFit
    }


    private func updateCompletionCount() {
        guard let label = completedLabel, let first = firstDayOfMonth else { return }
        let count = (0..<daysInMonth).filter { offset -> Bool in
            guard let d = calendar.date(byAdding: .day, value: offset, to: first) else { return false }
            return PuzzleGameManager.shared.isCompleted(date: calendar.startOfDay(for: d))
        }.count
        label.text = "\(count)/\(daysInMonth) Completed"
    }


    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        daysInMonth + firstWeekdayOffset
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DateCell", for: indexPath
        ) as! DateCell

        guard indexPath.item >= firstWeekdayOffset else {
            cell.configureEmpty()
            return cell
        }

        let day = indexPath.item - firstWeekdayOffset + 1
        guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) else {
            cell.configureEmpty()
            return cell
        }

        let cellDate         = calendar.startOfDay(for: date)
        let isToday          = calendar.isDate(cellDate, inSameDayAs: today)
        let isFuture         = cellDate > today
        let isCompleted      = PuzzleGameManager.shared.isCompleted(date: cellDate)
        let isSelected       = selectedDate.map { calendar.isDate(cellDate, inSameDayAs: $0) } ?? false
        let showTodayOutline = isToday && !isSelected

        cell.configure(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            isCompleted: isCompleted,
            showTodayOutline: showTodayOutline,
            enabled: !isFuture,
            themeColor: UIColor.systemBrown
        )
        return cell
    }


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.bounds.width / 7
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let offset = indexPath.item - firstWeekdayOffset
        guard offset >= 0, offset < daysInMonth else { return }

        guard let tapped = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return }
        let day = calendar.startOfDay(for: tapped)
        guard day <= today else { return }
        selectedDate = day
        updateEmojiImage()
        collectionView.reloadData()
    }


    private func configureLayout() {
        let layout  = UICollectionViewFlowLayout()
        let width   = collectionView.bounds.width > 0 ? collectionView.bounds.width : UIScreen.main.bounds.width
        let side    = width / 7
        layout.itemSize                = CGSize(width: side, height: side)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing      = 0
        layout.estimatedItemSize       = .zero
        collectionView.collectionViewLayout = layout
    }


    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let date = selectedDate else { return }

        if PuzzleGameManager.shared.isCompleted(date: date) {
            let alert = UIAlertController(
                title: "Challenge Completed",
                message: "You have already completed this daily challenge. Do you want to play again?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                self.performNavigation(to: date)
            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            present(alert, animated: true)
        } else {
            performNavigation(to: date)
        }
    }
}


extension LevelSelectionPuzzleViewController {

    private func performNavigation(to date: Date) {
        let viewModel = PuzzleViewModel()
        viewModel.startNewGame(difficulty: .medium, date: date)

        viewModel.onGameFinished = { [weak self] time in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.updateCompletionCount()
                self.collectionView?.reloadData()

                self.showResultScreen(timeTaken: time)
            }
        }

        tabBarController?.tabBar.isHidden = true

        let hostingController = UIHostingController(rootView: PuzzleGameView(viewModel: viewModel))
        hostingController.navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(hostingController, animated: true)
    }

    private func showResultScreen(timeTaken: Int) {
        tabBarController?.tabBar.isHidden = true

        navigationController?.setNavigationBarHidden(false, animated: true)

        if let resultVC = resultViewControllerFromStoryboard(timeTaken: timeTaken) {
            if let nav = navigationController {
                nav.pushViewController(resultVC, animated: true)
            } else {
                resultVC.modalPresentationStyle = .fullScreen
                present(resultVC, animated: true)
            }
            return
        }

        let resultVC = ResultViewController()
        resultVC.timeTaken = timeTaken
        if let nav = navigationController {
            nav.pushViewController(resultVC, animated: true)
        } else {
            resultVC.modalPresentationStyle = .fullScreen
            present(resultVC, animated: true)
        }
    }

    private func resultViewControllerFromStoryboard(timeTaken: Int) -> ResultViewController? {
        let sb = UIStoryboard(name: "Jigsaw Puzzle", bundle: nil)
        
        guard let vc = sb.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
            return nil
        }
        vc.timeTaken = timeTaken
        return vc
    }
}
