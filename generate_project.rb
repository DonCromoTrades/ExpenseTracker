require 'xcodeproj'

project_path = 'ExpenseTracker.xcodeproj'
project = Xcodeproj::Project.new(project_path)

app_target = project.new_target(:application, 'ExpenseTrackerApp', :ios, '16.0')

['ExpenseTrackerApp', 'ReceiptCapture', 'DataModel', 'ChartsModule'].each do |group_name|
  group = project.new_group(group_name, "Sources/#{group_name}")
  Dir.glob("Sources/#{group_name}/*.swift").each do |file|
    group.new_file(file)
  end
end

app_target.add_system_framework('UIKit')
app_target.add_system_framework('Vision')
app_target.add_system_framework('CoreData')

app_target.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION'] = '5.9'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.expensetracker'
end

project.save
puts "Created #{project_path}"
