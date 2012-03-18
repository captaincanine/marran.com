require 'date'
require 'active_support'

desc "Given a category and title as an argument, create a new post file"
task :post do

  print 'Enter the category (blog, recipes, travel, or tech): '
  category = $stdin.gets.chomp.strip
  
  today = DateTime::now().strftime('%Y-%m-%d')

  print 'Enter the post title: '
  title = $stdin.gets.chomp.strip

  slug = title.downcase
  slug = slug.gsub(/[^-\w\s]/, '')
  slug = slug.gsub(/^\s+|\s+$/, '')
  slug = slug.gsub(/[-\s]+/, '-')

  filename = "#{today}-#{slug}.textile"
  path = File.join("#{category}/_posts", filename)
  if File.exist? path; raise RuntimeError.new("Won't clobber #{path}"); end
  File.open(path, 'w') do |file|
    file.write <<-EOS
---
layout: post
title: #{title}
tags: 
- tag
description: Enter description here
---
Content goes here
EOS
  end
  sh "open #{path} -a bbedit"
end

task :generate => :clear do
    sh 'jekyll-s3'
end

task :commit do

  print 'Enter git commit message: '
  message = $stdin.gets.chomp.strip

  sh 'git add blog/*'
  sh 'git add recipes/*'
  sh 'git add travel/*'
  sh "git commit --all --message \"#{message}\""
  sh 'git push origin master'

end
