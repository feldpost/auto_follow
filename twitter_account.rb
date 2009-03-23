#!/usr/bin/env ruby

require 'rubygems'
require 'logger'
gem 'mbbx6spp-twitter4r', '>=0.3.1'
require 'twitter'
require 'yaml'

class TwitterAccount

  attr_accessor :client, :username

  def initialize(username,password)
    @username = username
    @client = Twitter::Client.new(:login => username, :password => password)
  end

  def followers
    @followers ||= items_across_pages(:followers).map {|f| f.screen_name}
  end

  def friends
    @friends ||= items_across_pages(:friends).map {|f| f.screen_name}
  end

  def followers_who_are_not_friends
    @followers_who_are_not_friends ||= followers.reject {|f| friends.include?(f) }
  end

  def friends_to_be_added
    @followers_to_be_added_as_friends ||= followers_who_are_not_friends.reject {|f| blacklisted_users.include?(f) }
  end
  
  def friends_to_be_removed
    friends.find_all {|f| blacklisted_users.include?(f) }
  end

  def blacklisted_users
    @blacklisted_users ||= configuration_for(:blacklist) || []
  end

  def auto_follow!
    friends_to_be_added.each do |follower|
      log_and_run(:add,follower)
    end
  end
  
  def auto_remove!
    friends_to_be_removed.each do |friend|
      log_and_run(:remove,friend)
    end
  end
  
  def auto_follow_and_remove!
    auto_remove!
    auto_follow!
  end

  private
  
  def log
    @log ||= Logger.new(File.join(File.dirname(__FILE__),'log',"auto_follow.log"))
  end
  
  def log_and_run(action,screen_name)
    @client.friend(action,screen_name)
    log.info "Account #{username}: Automatically #{action == :add ? 'followed' : 'removed'} user '#{screen_name}'"
  end

  def configuration_for(name)
    YAML.load_file(File.join(File.dirname(__FILE__),'config',"#{name}.yml"))
  end

  def items_across_pages(name,per_page=100)
    page = 1
    items = []
    loop do
      items_per_page = @client.my(name,:page => page)
      items += items_per_page
      if items_per_page.size >= per_page
        page += 1
        next
      else
        break
      end
    end
    items
  end

end