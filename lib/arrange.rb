require 'ransack'
require 'arrange/engine'
require 'arrange/config'
require 'arrange/utility'


module Arrange
  def self.config(&block)
    @config ||= Config
    if block_given?
      block.call @config
    else
      @config
    end
  end
end
