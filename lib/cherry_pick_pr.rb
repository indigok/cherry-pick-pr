#!/usr/bin/env ruby

require "json"
require "open-uri"
require "securerandom"

if ENV["GITHUB_EVENT_NAME"] == "pull_request"
  payload = JSON.parse(File.read(ENV["GITHUB_EVENT_PATH"]))
  commits = JSON.parse(open(payload["pull_request"]["commits_url"]).read)

  puts payload
  puts payload["pull_request"].keys
  puts payload["head"]
  if payload["pull_request"]["head"]["repo"]["fork"]
    `git remote add forked-branch "#{payload["pull_request"]["head"]["repo"]["clone_url"]}"`
    `git fetch forked-branch`
    puts "forked-branch"
    puts "#{payload["pull_request"]["head"]["repo"]["clone_url"]}"

    `git remote add base-branch "#{payload["pull_request"]["base"]["repo"]["clone_url"]}"`
    `git fetch base-branch`
    puts "base-branch"
    puts "#{payload["pull_request"]["base"]["repo"]["clone_url"]}"
  end
  
  branch_name = "cherry-pick-#{SecureRandom.hex(10)}"
  `git checkout -b "#{branch_name}"` 

  commits.each do |commit|
    `git config user.email "#{commit["commit"]["author"]["email"]}"`
    `git config user.name "#{commit["commit"]["author"]["name"]}"`
    `git cherry-pick "#{commit["sha"]}"`
    end
  `git push --set-upstream origin "#{branch_name}"`
  `echo ::set-output name=branch_name::"#{branch_name}"`
end
