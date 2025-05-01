
import UIKit

public class CarouselView: UIView {
    // MARK: - Properties
    
    private let collectionView: UICollectionView
    private let pageControl = UIPageControl()
    private let flowLayout = UICollectionViewFlowLayout()
    
    private var timer: Timer?
    private var currentIndex = 0
    private var items: [CarouselItem] = []
    
    // Customizable properties
    private let cellSpacing: CGFloat = 10
    private let autoScrollTimeInterval: TimeInterval = 3.0
    private let scrollAnimationDuration: TimeInterval = 0.5
    
    // Animation flags
    private var isAnimating = false
    private var shouldScrollToBeginningWhenReachingEnd = true
    private var isPagingEnabled = true
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = cellSpacing
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        super.init(frame: frame)
        setupCollectionView()
        setupPageControl()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = cellSpacing
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        super.init(coder: coder)
        setupCollectionView()
        setupPageControl()
        setupConstraints()
    }
    
    deinit {
        stopAutoScroll()
    }
    
    // MARK: - Setup Methods
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = isPagingEnabled
        collectionView.backgroundColor = .clear
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.identifier)
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.decelerationRate = .fast
        
        addSubview(collectionView)
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = true
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.systemBlue
        
        pageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)
        
        addSubview(pageControl)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -10),
            
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Public Methods
    
    /// Configure the carousel with items
    func configure(with items: [CarouselItem]) {
        self.items = items
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        currentIndex = 0
        collectionView.reloadData()
        
        // Layout update needed for proper cell sizing
        setNeedsLayout()
        layoutIfNeeded()
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        
        if items.count > 1 {
            startAutoScroll()
        }
    }
    
    /// Sets the visual effect when scrolling
    func setScrollEffect(effect: CarouselEffect) {
        switch effect {
        case .none:
            break
        case .zoom:
            collectionView.isPagingEnabled = false
        case .rotation:
            collectionView.isPagingEnabled = false
        case .depth:
            collectionView.isPagingEnabled = false
        }
        isPagingEnabled = collectionView.isPagingEnabled
    }
    
    /// Start automatic scrolling
    func startAutoScroll() {
        stopAutoScroll()
        guard items.count > 1 else { return }
        
        timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    /// Stop automatic scrolling
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Set custom colors for page control
    func setPageControlColors(current: UIColor, inactive: UIColor) {
        pageControl.currentPageIndicatorTintColor = current
        pageControl.pageIndicatorTintColor = inactive
    }
    
    /// Hide or show page control
    func showPageControl(_ show: Bool) {
        pageControl.isHidden = !show
    }
    
    // MARK: - Actions
    
    @objc private func scrollToNextItem() {
        guard !isAnimating, items.count > 1 else { return }
        
        var nextIndex = currentIndex + 1
        
        // Handle loop back to start
        if nextIndex >= items.count {
            if shouldScrollToBeginningWhenReachingEnd {
                nextIndex = 0
                // For smooth looping, scroll without animation to beginning
                collectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0), at: .centeredHorizontally, animated: false)
                currentIndex = nextIndex
                pageControl.currentPage = nextIndex
                return
            } else {
                nextIndex = items.count - 1
                stopAutoScroll()
                return
            }
        }
        
        scrollToItem(at: nextIndex, animated: true)
    }
    
    @objc private func pageControlChanged(_ sender: UIPageControl) {
        scrollToItem(at: sender.currentPage, animated: true)
    }
    
    private func scrollToItem(at index: Int, animated: Bool) {
        guard index >= 0, index < items.count else { return }
        
        isAnimating = true
        currentIndex = index
        pageControl.currentPage = index
        
        // Use custom animation for smoother transition
        let indexPath = IndexPath(item: index, section: 0)
        UIView.animate(withDuration: animated ? scrollAnimationDuration : 0,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }) { _ in
            self.isAnimating = false
        }
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update flow layout item size to match collection view size
        flowLayout.itemSize = CGSize(width: collectionView.frame.width - 40, height: collectionView.frame.height)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        if let firstVisibleCell = collectionView.visibleCells.first,
           let indexPath = collectionView.indexPath(for: firstVisibleCell) {
            currentIndex = indexPath.item
            pageControl.currentPage = currentIndex
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension CarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.identifier, for: indexPath) as? CarouselCell else {
            return UICollectionViewCell()
        }
        
        let item = items[indexPath.item]
        cell.configure(with: item)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle item selection if needed
    }
}

// MARK: - UIScrollViewDelegate

extension CarouselView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isAnimating, !items.isEmpty else { return }
        
        // Calculate the current page based on scroll position
        let pageWidth = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        
        if currentPage >= 0 && currentPage < items.count && currentPage != currentIndex {
            currentIndex = currentPage
            pageControl.currentPage = currentPage
        }
        
        // Apply visual effects based on scroll position
        applyVisualEffects()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCurrentCell()
            startAutoScroll()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerCurrentCell()
        startAutoScroll()
    }
    
    private func centerCurrentCell() {
        // Center the current cell when scrolling ends
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func applyVisualEffects() {
        for cell in collectionView.visibleCells {
            guard collectionView.indexPath(for: cell) != nil else { continue }
            
            // Calculate cell position relative to center
            let cellCenter = collectionView.convert(cell.center, to: collectionView.superview)
            let centerX = collectionView.center.x
            let offset = abs(cellCenter.x - centerX)
            let maxOffset = collectionView.frame.width / 2
            let normalizedOffset = min(offset / maxOffset, 1.0)
            
            // Scale and transform
            let scale = 1.0 - (0.2 * normalizedOffset)
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            
            // Add rotation effect (slight tilt)
            let angle = (cellCenter.x < centerX) ? normalizedOffset * 0.1 : -normalizedOffset * 0.1
            let rotationTransform = transform.rotated(by: angle)
            
            // Apply transform with animation
            UIView.animate(withDuration: 0.2) {
                cell.transform = rotationTransform
                cell.alpha = 1.0 - (normalizedOffset * 0.3)
            }
        }
    }
}
