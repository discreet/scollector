require 'rubygems'
require 'json'
require 'faraday'

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.8.7')
  fail("Ruby >= 1.8.7 is required")
end

repo_dir = '/var/www/html/repos'
bosun_dir = '/var/www/html/repos/bosun'
latest = Faraday.get 'https://api.github.com/repos/bosun-monitor/bosun/releases/latest'

release_ver = JSON.parse(latest.body)['tag_name']
binary_url  = JSON.parse(latest.body)['assets'].map { |i| i['browser_download_url'] }.select { |i| i =~ /(linux.*64)|(windows.*64)/ }
release_dir = "#{bosun_dir}/#{release_ver}"

Dir.mkdir(repo_dir) unless File.exists?(repo_dir)
Dir.mkdir(bosun_dir) unless File.exists?(bosun_dir)
Dir.mkdir(release_dir) unless File.exists?(release_dir)
Dir.chdir release_dir

if (Dir.entries("#{bosun_dir}/#{release_ver}") - %w{ . .. }).empty?
  binary_url.each do |url|
    system("/usr/bin/curl -LO #{url}")
  end
end
