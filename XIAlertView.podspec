
Pod::Spec.new do |s|

  s.name         = "XIAlertView"
  s.version      = "1.0.0"
  s.summary      = "A short description of XIAlertView."
  s.description  = "https://github.com/Banzuofan/XIAlertView"

  s.homepage     = "https://github.com/Banzuofan/XIAlertView"

  s.license      = "MIT FREE OF USE"
  
  s.author             = { "YXLONG" => "banzuofan@hotmial.com" }

  s.platform    = :ios, "8.0"    

  s.source       = { :git => "https://github.com/Banzuofan/XIAlertView.git", :tag => "#{s.version}" }

  s.source_files  = "classes"
  s.exclude_files = "Classes/Exclude"
end
