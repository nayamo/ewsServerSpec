#!/bin/env ruby
# -*- coding: utf-8 -*-

require 'spec_helper'


describe 'locate,wgetのインストールの確認' do
	["mlocate", "wget"].each do |pkg|
		describe package(pkg) do
		  it { should be_installed }
		end
	end
end

describe 'libxml,libxsltのインストールの確認'  do
	["libxml2", "libxml2-devel", "libxslt", "libxslt-devel"].each do |pkg|
		describe package(pkg) do
		  it { should be_installed }
		end
	end
end

describe 'gem packageのインストールの確認'  do
	['rbenv-rehash', 'bundler'].each do |gem_pkg|
		describe command("/usr/local/rbenv/shims/gem search '^#{gem_pkg}$'") do
		  it { should return_stdout /^#{gem_pkg} (.*)$/ }
		end
	end
end

describe 'ntpdateコマンドのインストールの確認'  do
	describe package("ntpdate") do
	  it { should be_installed }
	end
end

describe '時間設定が cronに登録されているか確認' do
	describe cron do
	  it { should have_entry '*/30 * * * * /usr/sbin/ntpdate 10.0.0.62' }
	end
end
describe 'タイムゾーンがJSTか確認'  do
	describe command('date') do
	  it { should return_stdout /JST/ }
	end
end
describe 'td-agentのインストールの確認' do
	describe package("td-agent") do
	  it { should be_installed }
	end
end

describe 'zabbix-agentのインストールの確認' do
	describe package("zabbix-agent") do
	  it { should be_installed }
	end
end


describe 'apacheのインストールの確認' do
	describe package("httpd") do
	  it { should be_installed }
	end
end
describe 'apacheの起動の確認' do
	describe service('httpd') do
	  it { should be_running }
	end
end
describe 'apacheのログのフォーマットファイルの生成を確認' do
	describe file('/etc/httpd/conf.d/log_format.conf') do
		it { should be_file }
		it { should be_mode 644 }
		it { should be_owned_by 'root' }
		it { should be_grouped_into 'root' }
	end
end

describe 'logwatchのインストールのインストールの確認' do
	describe package("logwatch") do
	  it { should be_installed }
	end
end


describe 'ssmtpのインストールのインストールの確認' do
	describe package("ssmtp") do
	  it { should be_installed }
	end
end
describe 'ssmtpの設定ファイルの確認' do
	describe file('/etc/ssmtp/ssmtp.conf') do
		it { should be_file }
		it { should be_mode 644 }
		it { should be_owned_by 'root' }
		it { should be_grouped_into 'root' }
	end
	describe file('/etc/ssmtp/revaliases') do
		it { should be_file }
		it { should be_mode 644 }
		it { should be_owned_by 'root' }
		it { should be_grouped_into 'root' }
	end
end

describe 'MTAの切り換えの確認' do
	describe command('ls -la /etc/alternatives/mta') do
		it { should return_stdout /\/etc\/alternatives\/mta -> \/usr\/sbin\/sendmail.ssmtp/ }
	end
end

describe 'ログのローテートの設定ファイルの確認' do
	describe file('/etc/logrotate.conf') do
		it { should be_file }
		it { should be_mode 644 }
		it { should be_owned_by 'root' }
		it { should be_grouped_into 'root' }
	end
end

describe '不要なサービスが停止されているか確認' do
	['ip6tables', 'netfs', 'restorecond'].each do |pkg|
		describe service(pkg) do
		  it { should_not be_running }
		end
	end
end

describe 'iptablesの内容 を saveしたか（ファイルの存在確認だけ）' do
	describe file('/etc/sysconfig/iptables') do
		it { should be_file }
	end
end

describe 'iptables が起動しているか確認' do
	describe service('iptables') do
	  it { should be_running }
	end
end


describe 'エフェメラルディスクがマウントされているか確認' do
	describe file('/mnt/data') do
	  it do
	    should be_mounted.with(
	      :device  => '/dev/xvdf',
	      :type    => 'ext4'
	    )
	  end
	end
end

describe 'swapが確保されているか確認' do
	describe command('swapon -s |grep /mnt/data/swap.img') do
	  its(:stdout) { should match /\/mnt\/data\/swap.img/ }
	end
end

describe 'SELinuxが通信を遮断しない設定になっているか確認' do
	describe file('/etc/selinux/config') do
		it { should be_file }
		its(:content) { should match /^SELINUX=disabled$/ }
	end
	describe command("getenforce") do
	  it { should return_stdout /^(Permissive|Disabled)$/ }
	end
end

# カーネルパラメータのチェック
describe 'Linux kernel parameters' do
	describe 'Exec-Shieldの設定の確認' do
		context linux_kernel_parameter('kernel.exec-shield') do
			its(:value) { should be == 3 }
		end
	end
end



