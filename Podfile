# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'ProgrammingStart' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ProgrammingStart
  pod 'FSCalendar'
  pod 'CalculateCalendarLogic'
  pod 'Charts'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'MessageKit'
  pod 'MessageInputBar'
  pod 'PKHUD' 
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  
  target 'ProgrammingStartTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ProgrammingStartUITests' do
    # Pods for testing
  end

end
