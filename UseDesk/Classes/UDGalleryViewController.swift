// UDL.swift
// Copyright (c) 2025

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

protocol UDGalleryViewControllerDelegate: AnyObject {
    func didFinishPicking(_ assets: [PHAsset])
    func didAddAssets(_ assets: [PHAsset])
}

class UDGalleryViewController: UIViewController {
    
    private var availableAssets: [PHAsset]
    private let imageManager = PHCachingImageManager()
    private var selectedAssets = [PHAsset]()
    private var galleryStyle = GalleryStyle()
    
    private var collectionView: UICollectionView!
    private var collectionViewBottomConstraint: NSLayoutConstraint!
    private var limitedAccessView = UIView()
    private var limitedAccessTopConstraint: NSLayoutConstraint!
    private var limitedAccessBottomConstraint: NSLayoutConstraint!
    private let limitedAccessTextLabel = UILabel()
    private let limitedAccessEditButton = UIButton(type: .system)
    private let limitedAccessStack = UIStackView()
    
    weak var delegate: UDGalleryViewControllerDelegate?
    weak var usedesk: UseDeskSDK?
    
    init(availableAssets: [PHAsset], usedesk: UseDeskSDK?) {
        self.availableAssets = availableAssets
        self.usedesk = usedesk
        self.galleryStyle = usedesk?.configurationStyle.galleryStyle ?? GalleryStyle()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }
    
    deinit {
        if #available(iOS 14, *) {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        }
        setupCollectionView()
        setupLimitedAccessView()
        updateLimitedAccessViewVisibility()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: usedesk?.model.stringFor("Done"), style: .done, target: self, action: #selector(doneButtonTapped))
        title = usedesk?.model.stringFor("Gallery")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLimitedAccessViewVisibility()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "UDAttachSmallCollectionViewCell", bundle: BundleId.thisBundle), forCellWithReuseIdentifier: "UDAttachSmallCollectionViewCell")
        
        view.addSubview(collectionView)

        collectionViewBottomConstraint = collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionViewBottomConstraint
        ])
    }
    
    private func setupLimitedAccessView() {
        limitedAccessView.translatesAutoresizingMaskIntoConstraints = false
        limitedAccessView.backgroundColor = galleryStyle.limitedAccessBackgroundColor
        limitedAccessView.layer.cornerRadius = galleryStyle.limitedAccessCornerRadius
        limitedAccessView.layer.shadowColor = galleryStyle.limitedAccessViewShadowColor.cgColor
        limitedAccessView.layer.shadowOffset = galleryStyle.limitedAccessViewShadowOffset
        limitedAccessView.layer.shadowOpacity = galleryStyle.limitedAccessViewShadowOpacity
        limitedAccessView.layer.shadowRadius = galleryStyle.limitedAccessViewShadowRadius
        view.addSubview(limitedAccessView)

        limitedAccessTextLabel.text = usedesk?.model.stringFor("MediaAccessLimited")
        limitedAccessTextLabel.font = galleryStyle.limitedAccessTextFont
        limitedAccessTextLabel.numberOfLines = galleryStyle.limitedAccessTextNumberOfLines
        limitedAccessTextLabel.lineBreakMode = galleryStyle.limitedAccessTextLineBreakMode
        limitedAccessTextLabel.translatesAutoresizingMaskIntoConstraints = false
        limitedAccessTextLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        limitedAccessTextLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        limitedAccessTextLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.7).isActive = true

        limitedAccessEditButton.setTitle(usedesk?.model.stringFor("Edit"), for: .normal)
        limitedAccessEditButton.setTitleColor(galleryStyle.limitedAccessEditButtonColor, for: .normal)
        limitedAccessEditButton.titleLabel?.font = galleryStyle.limitedAccessEditButtonFont
        limitedAccessEditButton.titleLabel?.textAlignment = galleryStyle.limitedAccessEditButtonTextAlignment
        limitedAccessEditButton.backgroundColor = galleryStyle.limitedAccessEditButtonBackgroundColor
        limitedAccessEditButton.layer.cornerRadius = galleryStyle.limitedAccessEditButtonCornerRadius
        limitedAccessEditButton.layer.masksToBounds = true
        limitedAccessEditButton.addTarget(self, action: #selector(addMorePhotosTapped), for: .touchUpInside)
        limitedAccessEditButton.translatesAutoresizingMaskIntoConstraints = false

        limitedAccessStack.addArrangedSubview(limitedAccessTextLabel)
        limitedAccessStack.addArrangedSubview(limitedAccessEditButton)
        limitedAccessStack.axis = .horizontal
        limitedAccessStack.spacing = 12
        limitedAccessStack.alignment = .center
        limitedAccessStack.translatesAutoresizingMaskIntoConstraints = false
        limitedAccessStack.setContentHuggingPriority(.required, for: .vertical)
        limitedAccessStack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        limitedAccessView.addSubview(limitedAccessStack)
        
        NSLayoutConstraint.activate([
            limitedAccessStack.topAnchor.constraint(equalTo: limitedAccessView.topAnchor, constant: galleryStyle.limitedAccessStackMargin.top),
            limitedAccessStack.bottomAnchor.constraint(equalTo: limitedAccessView.bottomAnchor, constant: -galleryStyle.limitedAccessStackMargin.bottom),
            limitedAccessStack.leadingAnchor.constraint(equalTo: limitedAccessView.leadingAnchor, constant: galleryStyle.limitedAccessStackMargin.left),
            limitedAccessStack.trailingAnchor.constraint(equalTo: limitedAccessView.trailingAnchor, constant: -galleryStyle.limitedAccessStackMargin.right)
        ])

        limitedAccessTopConstraint = limitedAccessView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10)
        limitedAccessBottomConstraint = limitedAccessView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            limitedAccessTopConstraint,
            limitedAccessBottomConstraint,
            limitedAccessView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: galleryStyle.limitedAccessViewMargin.left),
            limitedAccessView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -galleryStyle.limitedAccessViewMargin.right)
        ])
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didFinishPicking(selectedAssets)
        dismiss(animated: true)
    }

    @objc private func addMorePhotosTapped() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            PHPhotoLibrary.shared().register(self)
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            if usedesk?.isSupportedAttachmentOnlyPhoto ?? false {
                picker.mediaTypes = ["public.image"]
            } else if usedesk?.isSupportedAttachmentOnlyVideo ?? false {
                picker.mediaTypes = ["public.movie"]
            } else {
                picker.mediaTypes = ["public.image", "public.movie"]
            }
            present(picker, animated: true)
        }
    }
    
    private func reloadGalleryAssets() {
        availableAssets = []
        let options = PHFetchOptions()
        let sortDescriptor = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.isAccessibilityElement = false
        options.sortDescriptors = sortDescriptor
        if usedesk?.isSupportedAttachmentOnlyPhoto ?? false {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        }
        if usedesk?.isSupportedAttachmentOnlyVideo ?? false {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        }
        let assets = PHAsset.fetchAssets(with: options)
        assets.enumerateObjects({ (object, count, stop) in
            self.availableAssets.append(object)
        })
        
        self.collectionView.reloadData()
    }
    
    private func updateLimitedAccessViewVisibility() {
        let limited = isLimitedPhotoAccess()
        limitedAccessView.isHidden = !limited
        limitedAccessTopConstraint.isActive = limited
        limitedAccessBottomConstraint.isActive = limited
        collectionViewBottomConstraint.isActive = !limited
    }
    
    private func isLimitedPhotoAccess() -> Bool {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return status == .limited
        } else {
            // На iOS ниже 14 нет ограниченного доступа
            return false
        }
    }
}

// MARK: - UICollectionView
extension UDGalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableAssets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UDAttachSmallCollectionViewCell", for: indexPath) as! UDAttachSmallCollectionViewCell
        let asset = availableAssets[indexPath.item]
        let manager = PHImageManager.default()

        let width = 100
        let height = 146

        manager.requestImage(for: asset, targetSize: CGSize(width: width, height: height), contentMode: .aspectFill, options: nil) { result, _ in
            cell.imageView.image = result
        }

        if asset.mediaType == .video {
            cell.videoView.alpha = 1
            cell.videoTimeLabel.text = Int(asset.duration).timeString()
        } else {
            cell.videoView.alpha = 0
        }

        if selectedAssets.contains(asset) {
            if let number = selectedAssets.firstIndex(of: asset) {
                cell.setSelected(number: number + 1)
            }
        } else {
            cell.notSelected()
        }

        cell.indexPath = indexPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = availableAssets[indexPath.item]

        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
        } else {
            selectedAssets.append(asset)
        }

        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension UDGalleryViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.reloadGalleryAssets()
        }
    }
}


// MARK: - UIImagePicker (iOS <14)

extension UDGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        var assetURL: URL?

        if let url = info[.imageURL] as? URL {
            assetURL = url
        } else if let url = info[.mediaURL] as? URL {
            assetURL = url
        }

        guard let finalURL = assetURL else {
            return
        }

        let assets = PHAsset.fetchAssets(withALAssetURLs: [finalURL], options: nil)
        var newAssets: [PHAsset] = []

        assets.enumerateObjects { (asset, _, _) in
            if !self.selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                newAssets.append(asset)
            }
        }

        self.availableAssets.append(contentsOf: newAssets)
        self.collectionView.reloadData()
        self.delegate?.didAddAssets(newAssets)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
