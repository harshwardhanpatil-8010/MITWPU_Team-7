// BreakTheBrickLandingViewController.swift
// Parkinsons

import UIKit

class BreakTheBrickLandingViewController: UIViewController {

    @IBOutlet weak var monthAndYearOutlet: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!

    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2 // Monday start
        return c
    }()

    private let manager = BreakTheBrickManager.shared
    private let today = Calendar(identifier: .gregorian).startOfDay(for: Date())

    private var firstDayOfMonth: Date!
    private var daysInMonth = 0
    private var firstWeekdayOffset = 0
    private var selectedDate: Date?

    private var navGradientOverlay: CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemTeal.withAlphaComponent(0.15).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        return gradient
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupCollectionView()
        setupMonth()
        loadProgress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = true
        loadProgress()
        collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let gradient = navGradientOverlay
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 180)
        view.layer.insertSublayer(gradient, at: 0)

        playButton.backgroundColor = .systemTeal
        playButton.setTitleColor(.white, for: .normal)
        playButton.setTitle("Play", for: .normal)
        playButton.layer.cornerRadius = 25
    }

    private func setupNavigationBar() {
        self.title = "Break The Brick"

        let backImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backTappedAction))
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton

        let infoImage = UIImage(systemName: "questionmark.circle")
        let infoButton = UIBarButtonItem(image: infoImage, style: .plain, target: self, action: #selector(infoTappedAction))
        infoButton.tintColor = .label
        navigationItem.rightBarButtonItem = infoButton

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label, .font: UIFont.boldSystemFont(ofSize: 18)]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupCollectionView() {
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.width / 7
            layout.itemSize = CGSize(width: width, height: width)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.estimatedItemSize = .zero
        }
    }

    private func setupMonth() {
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)
        firstDayOfMonth = calendar.date(from: comps)!

        daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count

        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        firstWeekdayOffset = (weekday - calendar.firstWeekday + 7) % 7

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthAndYearOutlet.text = formatter.string(from: firstDayOfMonth)

        selectedDate = today
        collectionView.reloadData()
    }

    private func loadProgress() {
        guard firstDayOfMonth != nil else { return }

        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)!
        let summaries = manager.getSessionSummaries(from: firstDayOfMonth, to: endOfMonth)

        let completedDates = summaries.map { calendar.startOfDay(for: $0.date) }
        let uniqueCompleted = Set(completedDates)
        completedLabel.text = "\(uniqueCompleted.count)/\(daysInMonth) Completed"

        playButton.setTitle("Play", for: .normal)
    }

    @objc private func backTappedAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func infoTappedAction() {
        let storyboard = UIStoryboard(name: "BreakTheBrick", bundle: nil)
        if let infoVC = storyboard.instantiateViewController(withIdentifier: "BreakTheBrickInfoViewController") as? BreakTheBrickInfoViewController {
            let nav = UINavigationController(rootViewController: infoVC)
            present(nav, animated: true)
        }
    }

    @IBAction func playButtonTapped(_ sender: Any) {
        guard let selDate = selectedDate else { return }

        if manager.isCompleted(date: selDate) {
            let alert = UIAlertController(title: "Already Completed", message: "You have already completed the challenge for this date. Would you like to play again?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
                self.startGame(with: selDate)
            }))
            present(alert, animated: true)
        } else {
            startGame(with: selDate)
        }
    }

    private func startGame(with date: Date) {
        let storyboard = UIStoryboard(name: "BreakTheBrick", bundle: nil)
        if let gameVC = storyboard.instantiateViewController(withIdentifier: "BreakTheBrickGameViewController") as? BreakTheBrickGameViewController {
            gameVC.sessionDate = date
            navigationController?.pushViewController(gameVC, animated: true)
        }
    }
}

extension BreakTheBrickLandingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth + firstWeekdayOffset
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell

        guard indexPath.item >= firstWeekdayOffset else {
            cell.configureEmpty()
            return cell
        }

        let day = indexPath.item - firstWeekdayOffset + 1
        let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
        let cellDate = calendar.startOfDay(for: date)

        let isToday = calendar.isDate(cellDate, inSameDayAs: today)
        let isFuture = cellDate > today
        let isSelected = selectedDate.map { calendar.isDate(cellDate, inSameDayAs: $0) } ?? false
        let isCompleted = manager.isCompleted(date: cellDate)
        let showTodayOutline = isToday && !isSelected

        cell.configure(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            isCompleted: isCompleted,
            showTodayOutline: showTodayOutline,
            enabled: !isFuture,
            themeColor: .systemTeal
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item >= firstWeekdayOffset else { return }

        let day = indexPath.item - firstWeekdayOffset + 1
        let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
        let cellDate = calendar.startOfDay(for: date)

        guard cellDate <= today else { return }

        selectedDate = cellDate
        collectionView.reloadData()
    }
}
