#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'json'

class PhoneMLBuilder
  METHODS = [:speak, :play, :input, :record, :transfer, :goto, :hangup]
  def self.start; yield(o = PhoneMLBuilder.new); o.json; end
  def initialize; @data = {'phoneml' => []}; end
  def data; @data['phoneml']; end
  def json; @data.to_json; end
  def hangup; data << {'hangup' => {"$" => ""}}; end
  def method_missing(sym, arg, *rest, &block)if METHODS.include?(sym);h={"$"=>arg};rest.each{|r|h.merge!(r)};data<<{sym.to_s=>h};else super;end;end
end

get "/" do
  <<-DOC
  <h1>Simon</h1>
  get  <a href="/simon.json">/simon.json</a><br>
  DOC
end

def guess_url
  uri = URI.parse(request.url)
  uri.scheme + "://" + uri.host + ":#{uri.port}" + "/simon/guess/"
end

get "/simon.json" do
  content_type :json

  PhoneMLBuilder.start do |j|
    j.speak "Welcome to Simon. To play, enter the digits you hear."
    #j.goto guess_url+rand(10).to_s, '@method'=>'post'
    j.goto guess_url, '@method'=>'post'
  end
end

post "/calls/create.json" do
  content_type :json
  p params
  puts "call for #{params[:dnid]}"
  PhoneMLBuilder.start do |j|
    j.speak "Welcome"
    j.transfer "Sip/590"
    j.hangup
  end
end

post "/simon.json" do
  content_type :json

  PhoneMLBuilder.start do |j|
    j.speak "Welcome to Simon. To play, enter the digits you hear."
    #j.goto guess_url+rand(10).to_s, '@method'=>'post'
    j.goto guess_url, '@method'=>'post'
  end
end

post "/simon/guess/:number?" do
  content_type :json

  number = params[:number]
  guess  = params[:callerinput]

  if number.nil? || number == guess
    number ||= ''
    number += rand(10).to_s
    number_size = number.size || 0
    url = guess_url + number
    PhoneMLBuilder.start do |j|
      j.speak number.split(//).join(" ")
      j.input url, '@options' => "[#{number_size} DIGITS]"
    end
  else
    PhoneMLBuilder.start do |j|
      number ||= ''
      number_size = number.size - 1
      j.speak "That is incorrect. You got #{number_size} digit#{number_size>1||number_size==0 ? 's' : ''} correct."
      j.goto guess_url.sub(/\/guess\//,'.json')
    end
  end
end

