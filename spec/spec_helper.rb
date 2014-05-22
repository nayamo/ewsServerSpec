require 'serverspec'
require 'pathname'
require 'json'
require 'pp'
require 'net/ssh'

include SpecInfra::Helper::Ssh
include SpecInfra::Helper::DetectOS

RSpec.configure do |c|
  if ENV['ASK_SUDO_PASSWORD']
    require 'highline/import'
    c.sudo_password = ask("Enter sudo password: ") { |q| q.echo = false }
  else
    c.sudo_password = ENV['SUDO_PASSWORD']
  end
  c.before :all do
    block = self.class.metadata[:example_group_block]
    if RUBY_VERSION.start_with?('1.8')
      file = block.to_s.match(/.*@(.*):[0-9]+>/)[1]
    else
      file = block.source_location.first
    end
    host_json = JSON.parse( File.read( File.dirname(__FILE__)+'/../json/ssh/host.json' ) )
    host = host_json['host']
    if c.host != host
      c.ssh.close if c.ssh
      c.host  = host
      options = Net::SSH::Config.for(c.host)
      options[:key_data] = File.read( host_json['ssh_key'] ) if host_json['ssh_key']
      user    = options[:user] || Etc.getlogin
      c.ssh   = Net::SSH.start(host, user, options)
    end
  end
end
