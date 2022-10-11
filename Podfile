# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

# fix xcode 14 sign issue
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end

target 'CopyBoard' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  # https://github.com/vsouza/awesome-ios
  # Pods for CopyBoard
  
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RealmSwift'
  
  pod 'SnapKit' # https://github.com/SnapKit/SnapKit
  pod 'SwiftDate' # https://github.com/malcommac/SwiftDate
  pod 'CircleMenu' # https://github.com/Ramotion/circle-menu
  pod 'Bugly' # https://bugly.qq.com/v2/product/apps/1867f49195?pid=2
  pod "TTGSnackbar" # https://github.com/zekunyan/TTGSnackbar
#  pod 'MagazineLayout' # https://github.com/airbnb/MagazineLayout
#  pod 'WhatsNewKit' # https://github.com/SvenTiigi/WhatsNewKit
  pod "ContextMenu"
  
  # private libs
  pod "UILibrary", :path => '../UILibrary'

  target 'CopyBoardTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'Keyboard' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  # Pods for Keyboard
  
  pod 'RealmSwift'
  pod 'SnapKit'
  pod "UILibrary", :path => '../UILibrary'
  
end

target 'StickerShare' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  # Pods for StickerShare
  pod 'RealmSwift'
  pod 'SnapKit'
  pod "UILibrary", :path => '../UILibrary'

end
