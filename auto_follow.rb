#!/usr/bin/env ruby

require 'yaml'
require File.join(File.dirname(__FILE__),'twitter_account')

class AutoFollower
  
  def self.run
    new
  end

  def initialize
    accounts.each do |username,password|
      account = TwitterAccount.new(username,password)
      account.auto_follow_and_remove!
    end
  end

  def accounts
    @accounts ||= configuration_for :accounts
  end

  private
  
  def configuration_for(name)
    YAML.load_file(File.join(File.dirname(__FILE__),'config',"#{name}.yml"))
  end

end

AutoFollower.run