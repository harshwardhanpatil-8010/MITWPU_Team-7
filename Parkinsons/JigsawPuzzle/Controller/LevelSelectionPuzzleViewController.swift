
import UIKit
import SwiftUI

class LevelSelectionPuzzleViewController: UIViewController,
                                          UICollectionViewDataSource,
                                          UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    @IBOutlet weak var monthAndYearOutlet: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    // MARK: - Calendar state
    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2   // Monday first
        return c
    }()

    private let today           = Calendar(identifier: .gregorian).startOfDay(for: Date())
    private var firstDayOfMonth: Date!
    private var daysInMonth         = 0
    private var firstWeekdayOffset  = 0
    private var selectedDate: Date?
    private var layoutConfigured    = false   // guard to avoid duplicate layout setup

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupMonth()
        updateMonthLabel()
        title = "Jigsaw Puzzle"
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Re-configure layout once actual bounds are known (avoids zero-width on first pass)
        if !layoutConfigured {
            layoutConfigured = true
            configureLayout()
            collectionView?.reloadData()
        }
        title = "Jigsaw Puzzle"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCompletionCount()
        collectionView?.reloadData()
        title = "Jigsaw Puzzle"
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Setup

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

    // MARK: - Completion count

    private func updateCompletionCount() {
        guard let label = completedLabel, let first = firstDayOfMonth else { return }
        let count = (0..<daysInMonth).filter { offset -> Bool in
            guard let d = calendar.date(byAdding: .day, value: offset, to: first) else { return false }
            return PuzzleGameManager.shared.isCompleted(date: calendar.startOfDay(for: d))
        }.count
        label.text = "\(count)/\(daysInMonth) Completed"
    }

    // MARK: - UICollectionViewDataSource

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
        // Show today's ring only when it is today but NOT currently selected
        let showTodayOutline = isToday && !isSelected

        cell.configure(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            isCompleted: isCompleted,
            showTodayOutline: showTodayOutline,
            enabled: !isFuture,
            themeColor: UIColor(hex: "BF5AF2")
        )
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.bounds.width / 7
        return CGSize(width: side, height: side)
    }

    /// Tapping a past/today date selects it AND immediately launches the puzzle.
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let offset = indexPath.item - firstWeekdayOffset
        guard offset >= 0, offset < daysInMonth else { return }

        guard let tapped = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return }
        let day = calendar.startOfDay(for: tapped)
        guard day <= today else { return }   // Block future dates

        // Update selection & preview image
        selectedDate = day
        updateEmojiImage()
        collectionView.reloadData()

        // Launch the puzzle immediately for the selected date
        performNavigation(to: day)
    }

    // MARK: - Layout

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

    // MARK: - Play button (still works as fallback)

    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let date = selectedDate else { return }
        performNavigation(to: date)
    }
}

// MARK: - Game navigation

extension LevelSelectionPuzzleViewController {

    private func performNavigation(to date: Date) {
        let viewModel = PuzzleViewModel()
        viewModel.startNewGame(difficulty: .medium, date: date)

        viewModel.onGameFinished = { [weak self] time in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // Dismiss the fullScreen SwiftUI hosting controller
                self.dismiss(animated: true) {
                    // Refresh calendar so the completed date fills with colour
                    self.updateCompletionCount()
                    self.collectionView?.reloadData()

                    // Navigate to ResultViewController
                    self.showResultScreen(timeTaken: time)
                }
            }
        }

        let hostingController = UIHostingController(rootView: PuzzleGameView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }

    private func showResultScreen(timeTaken: Int) {
        // Try to load from the "Jigsaw Puzzle" storyboard first
        if let resultVC = resultViewControllerFromStoryboard(timeTaken: timeTaken) {
            if let nav = navigationController {
                nav.pushViewController(resultVC, animated: true)
            } else {
                resultVC.modalPresentationStyle = .fullScreen
                present(resultVC, animated: true)
            }
            return
        }

        // Fallback: instantiate programmatically if storyboard lookup fails
        let resultVC = resultViewController()
        resultVC.timeTaken = timeTaken
        if let nav = navigationController {
            nav.pushViewController(resultVC, animated: true)
        } else {
            resultVC.modalPresentationStyle = .fullScreen
            present(resultVC, animated: true)
        }
    }

    /// Attempts to load resultViewController from the "Jigsaw Puzzle" storyboard.
    private func resultViewControllerFromStoryboard(timeTaken: Int) -> resultViewController? {
        let sb = UIStoryboard(name: "Jigsaw Puzzle", bundle: nil)
        // The storyboard identifier must match exactly: "ResultViewController"
        guard let vc = sb.instantiateViewController(withIdentifier: "ResultViewController") as? resultViewController else {
            return nil
        }
        vc.timeTaken = timeTaken
        return vc
    }
}
