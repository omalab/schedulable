source "https://rubygems.org"

# Declare your gem's dependencies in schedulable.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

git_source(:omalab) do |repo_name|
  repo_name = "omalab/#{repo_name}" unless repo_name.include?('/')
  "https://#{ENV['GITHUB_CREDENTIALS']}@github.com/#{repo_name}.git"
end

git_source(:gitlab) do |repo_name|
  "http://oauth:#{ENV['GITLAB_TOKEN']}@git.audienti.club:10080/#{repo_name}.git"
end

gem 'ice_cube', git: 'git://github.com/joelmeyerhamme/ice_cube.git', branch: 'master'
gem 'simple_form'
gem 'rails-i18n', '~> 4.0.0' # For 4.0.x
gem "date_picker", github: 'benignware/date_picker'
gem 'database_cleaner'
gem 'sqlite3'
gem 'factory_girl_rails', "~> 4.0"
gem 'turbolinks', :git => 'git://github.com/rails/turbolinks.git'