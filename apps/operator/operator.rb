#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'sinatra'
require 'haml'
#require 'rack-flash'
#require 'sinatra/redirect_with_flash'
#require 'sinatra_more'
require 'sequel'
#require 'model_helper'
#include SinatraMore::AssetTagHelpers


enable :sessions
ASTERISK = '/opt/depot/asterisk-1.4.24.1/sbin/asterisk'
ASTERISK_ROOT = '/opt/depot/asterisk-1.4.24.1'

Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :schema
Sequel::Model.plugin :hook_class_methods

if /darwin/ =~ RUBY_PLATFORM
  set :host, "127.0.0.1"
else
  set :host, "0.0.0.0"
  set :port, 3000
end

$debug = false
if $debug
  require 'irb'
  require 'irb/completion'
end

ROOT = File.dirname(File.expand_path(__FILE__))
file = "#{ROOT}/../../shared/db/zanelle.db"
uri  = ENV['DATABASE_URL'] || "sqlite://#{ROOT}/../../shared/db/zanelle.db"
FileUtils.touch(file)
Sequel.connect(uri)

require '../../shared/models/identity'
require '../../shared/models/did'
require '../../shared/models/call_handler_group'
require '../../shared/models/ring_set'
require '../../shared/models/number'

error do
  err = request.env['sinatra.error']
  s = []
  s << err.to_s
  s += err.backtrace
  ["Application Error", s].flatten.join("<br />")
end


get "/" do
  @title = "Dr Lain Phone Controller"
  @pvoffice = get_state('pvoffice')
  @sroffice = get_state('sroffice')
  @notice   = session[:notice]
  session[:notice] = nil
  haml :index
end

get "/about" do
  @title = "Total Practice IT: About Us"
  haml :about
end

get "/admin" do
  @identity            = Identity[1].name || 'Click here to define an identity'
  @dids                = Did.all
  @call_handler_groups = CallHandlerGroup.all
  @ring_sets           = RingSet.all
  @numbers             = Number.all
#  @ring_sets           = RingSet.all
  haml :admin
end

# Yeah, I know, this is bad. Should be PUT
get '/chg/delete/:id' do
  CallHandlerGroup[params[:id]].delete
  redirect '/admin'
end

post "/call_handler_group" do
  add_chg(params[:chg])
  redirect '/admin'
end

post "/call_handler_group/:id" do
  edit_chg(params[:chg], params[:id])
  redirect '/admin'
end

post "/did/:id" do
  add_did(params[:did])
  redirect '/admin'
end

get "/did/delete/:id" do
  Did[params[:id]].delete
  redirect '/admin'
end

post "/did/edit/:id" do
#  Did[]
end

get "/help" do
  haml :help
end

post "/identity" do
  update_identity(params[:identity]) if params[:identity]
  redirect '/admin'
end

get "/info" do
  haml :info
end

get "/messages" do
  haml :messages
end

post "/number" do
  p params
  add_number(params[:number])
  redirect '/admin'
end

post "/ring_set" do
  add_ring_set(params[:ring_set])
  redirect '/admin'
end


post "/update" do
  #{"PV"=>"Open", "SR"=>"Open"}
  set_state('pvoffice', params[:PV])
  set_state('sroffice', params[:SR])
#  response.headers['X-Message'] = "Phone System Updated"
#  flash[:notice] = "Phone System Updated"
  session[:notice] = 'Phone System Updated'
  redirect '/'
end

get "/voicemail" do
  @vmail = get_vm_stats(599)
  haml :voicemail
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html


  def add_did(h)
    numbers = get_numbers(h[:pri_number])
    numbers.each do |number|
      Did.create(:pri_number=>number, :number => h[:number]+' '+number, :description => h[:description]) if Did.filter(:pri_number=>number).all.empty?
    end
  end
  
  def add_chg(h)
    name = h[:name]
    CallHandlerGroup.create(:name=>name) if CallHandlerGroup.filter(:name=>name).all.empty?
  end

  def add_number(h)
    numbers = get_numbers(h[:number])
    is_sip = h.has_key?(:is_sip) ? true : false
    numbers.each do |number|
      Number.create(:number=>number, :is_sip => is_sip) if Number.filter(:number=>number).all.empty?
    end
  end

  def add_ring_set(h)
    name = h[:name]
    RingSet.create(:name=>name) if RingSet.filter(:name=>name).all.empty?
  end
  
  def edit_chg(h, id)
    name = h[:name]
    item = CallHandlerGroup[id]
#    puts ":=> item = #{item.inspect}"
    return if item.nil?
    item.update(:name=>name) if CallHandlerGroup.filter(:name=>name).all.empty?
  end
  
  def get_numbers(str)
    str.split(/[,\s]/).reject{|i| i.empty?}.compact.reject{|n| /[^\d]/ =~ n}
  end
  
  def parse_voicemail(file)
    data = File.read(file)
    data.grep(/callerid|origdate/).map do |line|
      h line
    end
#; ; Message Information file ; [message] origmailbox=699 context=inbound macrocontext= exten=3700 priority=3 callerchan=DAHDI/1-1 callerid="Unavailable" <5129499683>  origdate=Mon Oct 11 06:47:33 PM CDT 2010 origtime=1286840853 category= duration=4 
  end

  def get_vm_stats(ext)
    root = "/opt/depot/asterisk-1.4.24.1/var/spool/asterisk/voicemail/internal/#{ext}/INBOX"
    files = Dir[root+"/*.txt"]
    files.map do |file|
      parse_voicemail file
    end
  end
  
  def get_state(key='office')
    `#{ASTERISK} -rx 'database get #{key} test_state '`.strip.sub(/^Value:\s+/,'')
  end

  def set_state(key, value)
    `#{ASTERISK} -rx 'database put #{key} test_state #{value}'`.strip.sub(/^Value:\s+/,'')
  end

  
  def option(value, model_value=nil)
    if model_value && model_value == value
      %Q[<option value="#{value}" selected="selected">#{value}</option>]
    else
      %Q[<option value="#{value}">#{value}</option>]
    end
  end

  def checkbox(options, checked=false)
    start = "<input"
    start += " checked" if checked
    options.merge!({:type => "checkbox"})
    opts = options.map { |h,k| "#{h}='#{k}'" }
    [start, opts, "/>"].flatten.join(" ")
  end

  def radio(name, value, text, checked='')
    selected = checked == value ? 'checked' : ''
    start = %Q{<input type="radio" name="#{name}" value="#{value}" #{selected}/> #{text}}
    # radio
    #   name=
    #   value=
    #   align=
    #   tabindex=
    # checked
  end
  
  def update_identity(h)
    name = h[:name]
    if (i = Identity[1])
      i.update(:name => name)
    else
      Identity.create(:name => name)
    end
  end
  
end

