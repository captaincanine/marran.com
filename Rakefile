require 'git'
require 'date'
require 'active_support'
require 'ruby-debug'

namespace "post" do

  desc "Given a category and title as an argument, create a new post file"
  task :new, [:category, :title] do |t, args|

    today = DateTime::now().strftime('%Y-%m-%d')

    slug = args.title.downcase
    slug = slug.gsub(/[^-\w\s]/, '')
    slug = slug.gsub(/^\s+|\s+$/, '')
    slug = slug.gsub(/[-\s]+/, '-')
    slug = slug.gsub(/-$/, '')

    filename = "#{today}-#{slug}.textile"
    path = File.join("#{args.category}/_posts", filename)
    if File.exist? path; raise RuntimeError.new("Won't clobber #{path}"); end
    File.open(path, 'w') do |file|
      file.write <<-EOS
---
layout: post
title: #{args.title}
tags: 
- tag
description: Enter description here
---
Content goes here
EOS
    end
    sh "open #{path} -a bbedit"
  end
end

task :generate => :clear do
    sh 'jekyll'
end

task :clear do
    sh 'rm -rf _site/*'
end

task :commit, [:message] do |t, args|

  sh 'git add blog/*'
  sh 'git add recipes/*'
  sh 'git add travel/*'
  sh 'git commit --all -m #{args.message}'
  sh 'git push origin master'

end

task :deploy => :generate do
    sh 'rsync -rpcvzgo --delete _site/ klm:/var/www/vhosts/marran.com/httpdocs  | grep -v -e 'DS_Store' -e 'Thumbs' | sort'
end
