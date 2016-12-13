# Uncomment the next line to define a global platform for your project
# set to Xcode iOS Deployment Target
platform :ios, '9.0'

# Uncomment the next line if you're using Swift or would like to use dynamic frameworks
use_frameworks!

# http://stackoverflow.com/questions/37320194/cocoapods-1-0-same-pods-for-multiple-targets?rq=1
def commonPods
    pod 'MagicalRecord'
    pod 'RestKit', '~> 0.27.0'
    pod 'RestKit/Testing', '~> 0.27.0'
    pod 'RestKit/Search', '~> 0.27.0'
    pod 'CorePlot', '~> 2.2'
    pod 'PPiFlatSegmentedControl', '~> 1.4.0'
    pod 'JVFloatLabeledTextField'
    pod 'RETableViewManager'
    pod 'EAIntroView', '~> 2.2.0'
    pod 'EFCircularSlider', '~> 0.1.0'
    pod 'BlurryModalSegue'
    pod 'RMDateSelectionViewController', '~> 2.1.0'
    pod 'Reachability'
end

target 'BGCompass' do

    commonPods

    target 'BGCompassTests' do
        inherit! :search_paths
        commonPods
    end
    
end
