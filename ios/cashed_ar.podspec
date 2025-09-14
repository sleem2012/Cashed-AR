#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cashed_ar.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cashed_ar'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for displaying AR models with intelligent caching on both Android and iOS platforms.'
  s.description      = <<-DESC
A comprehensive Flutter plugin that provides AR model viewing capabilities with smart caching mechanisms.
On iOS, it uses QuickLook for native AR viewing with USDZ files.
On Android, it integrates with model_viewer_plus for GLB file support.
Features include intelligent file caching, download progress tracking, retry mechanisms, and automatic cleanup.
                       DESC
  s.homepage         = 'https://github.com/sleem2012/cashed_ar'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ahmed Sleem' => 'sleem.ahmed98@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
