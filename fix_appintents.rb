require 'xcodeproj'
project_path = 'GithubCounter.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  if target.name == 'GithubCounter' || target.name == 'GithubCounterWidgetExtension' || target.name == 'GithubCounterWidget'
    frameworks_build_phase = target.frameworks_build_phase
    file_ref = project.frameworks_group.new_reference("System/Library/Frameworks/AppIntents.framework")
    file_ref.source_tree = 'SDKROOT'
    
    unless frameworks_build_phase.files.any? { |file| file.file_ref && file.file_ref.name == "AppIntents.framework" || file.file_ref.path.include?("AppIntents") }
      build_file = frameworks_build_phase.add_file_reference(file_ref)
      puts "Added AppIntents.framework to #{target.name}"
    else
      puts "AppIntents.framework already in #{target.name}"
    end
  end
end

project.save
