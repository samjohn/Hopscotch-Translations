
desc "Pull down translation files and write them to s3"
task save_translations: :environment do
  puts `bundle exec rake gengo:sync_all localizable_strings:write`
end

desc "Pull the files from S3 then send them to gengo for translation"
task do_translations: :environment do
  puts `bundle exec rake db:seed gengo:translate`
end
