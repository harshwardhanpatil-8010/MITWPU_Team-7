import UIKit

class EmojiLandingScreen: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    @IBOutlet weak var monthAndYearOutlet: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var calendarViewOutlet: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private let calendar = Calendar.current
    private var currentMonthDate = Date()
    private var daysInMonth = 0
    private var firstWeekday = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        setupMonth()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }

    private func setupMonth() {
        daysInMonth = calendar.range(of: .day, in: .month, for: currentMonthDate)?.count ?? 0
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonthDate))!
        firstWeekday = calendar.component(.weekday, from: firstDay) - 1

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthAndYearOutlet.text = formatter.string(from: currentMonthDate)

        collectionView.reloadData()
    }

    // MARK: - CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth + firstWeekday
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        
        if indexPath.item < firstWeekday {
            cell.configureEmpty()
            return cell
        }

        let day = indexPath.item - firstWeekday + 1
        cell.configure(day: day, isToday: false, isPast: false, isCompleted: false)
        
        return cell
    }

    // MARK: - Updated Action Logic
    @IBAction func playButtonTapped(_ sender: UIButton) {
        // 1. Update this name from "Main" to your actual storyboard file name
        // If it's the same as your card game, use "Match the Cards"
        let storyboard = UIStoryboard(name: "MimicTheEmoji", bundle: nil)
        
        // 2. Safely instantiate
        guard let gameVC = storyboard.instantiateViewController(withIdentifier: "EmojiGameViewController") as? EmojiGameViewController else {
            print("❌ ERROR: Storyboard ID 'EmojiGameViewController' not found in the selected storyboard.")
            return
        }
        
        // 3. Navigate
        if let nav = self.navigationController {
            nav.pushViewController(gameVC, animated: true)
        } else {
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true, completion: nil)
        }
    }
}
