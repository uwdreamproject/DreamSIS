namespace :assets do
  
  desc 'Check that assets do not generate compile errors'
  task :verify_syntax => :environment do
    JS_PATH = Rails.root.join("app/assets/javascripts/**/*.js");
    Dir[JS_PATH].each do |file_name|
      puts "Verifying syntax of #{file_name}"
      begin
        Uglifier.compile(File.read(file_name))
      rescue => e
        abort "Error compiling #{file_name}", e
      end
    end
    puts "All files compiled successfully"
  end
  
end
