require 'yaml'
require 'erb'
require 'base64'
require 'securerandom'
require 'net/scp'
require 'net/ssh/multi'

require 'aws-sdk'
require_relative 'aws_ripper/aws_conn'
require_relative 'aws_ripper/base'

module AwsRipper
  class Config
    attr_accessor :hostname, :port, :protocol, :urls, :users_amount,
      :regions, :instance_type, :http_method

    def initialize
      load_conf = YAML::load_file(File.join(File.dirname(
        File.expand_path(__FILE__)), '..', 'config.yml'))

      @hostname          = load_conf['hostname']
      @port              = load_conf['port']
      @protocol          = load_conf['protocol']
      @urls              = load_conf['urls']
      @users_amount      = load_conf['users_amount']
      @regions           = load_conf['regions']

      instance_type_conf = load_conf['instance_type']
      @instance_type     = instance_type_conf ? instance_type_conf : 't2.micro'

      http_method_conf   = load_conf['http_method']
      @http_method       = http_method_conf ? http_method_conf : 'GET'
    end
  end
end
