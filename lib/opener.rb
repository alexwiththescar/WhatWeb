require 'curl'
require 'uri'
require 'json'
module WhatWeb
class Opener

  class NoMoreTargets < Exception
  end


  attr_reader :opts
  attr_reader :file_pile
  def initialize(opts={})
    @opts=opts.clone
    
    
    @file_pile=WhatWeb::FilePile.new(opts)
    @input_file=File.open(opts[:input_file]) if opts[:input_file]
    @target_list=make_target_list(opts)
    @input_file_mutex=Mutex.new
    @opts[:timeout]||=30
  end

  def start_file_pile
    @file_pile.start
 end

  def open_next_target(read)
    tt=JSON.parse(read.gets)
    bm=Benchmark.start(:open_next_target) if opts[:benchmark]
    exit if tt["stop"]
    if tt["body"]
      t=Target.new(tt["body"])
      t.original_source=tt["source"]
      return t
    end
    t2=open(tt[:url])
    bm.finish if opts[:benchmark]
    return t2
  end


  def open(target)
    bm=Benchmark.start(:open_open) if opts[:benchmark]
		  r=::Curl::Easy.http_get(target) do |e|
			  e.header_in_body=true
			  e.follow_location=true
			  e.max_redirects=4
			  e.timeout=opts[:read_timeout]
			  e.connect_timeout=opts[:open_timeout]
			  e.resolve_mode = :ipv4
      end
      tm=Benchmark.start(:open_open) if opts[:benchmark]
      t=Target.new(r.body_str)
      tm.finish if opts[:benchmark]
      t.is_file=false
      t.is_url=true
      t.uri=URI.parse(target)
      t.original_source=target
    bm.finish if opts[:benchmark]
    return t
  end


  private


  def next_target
    t=@target_list.shift
    t=process_target(t) unless t.nil?
    return t
  end


  def process_target(x)
    if File.exist?(x)
      x
    else
      puts "NOT file exists #{x} '#{Dir.getwd}'"
      if opts[:url_pattern]
        x = opts[:url_pattern].gsub('%insert%',x)
      end
      x=opts[:url_prefix].to_s + x + opts[:url_suffix].to_s
      if x =~ (/^[a-z]+:\/\//)
	      x
      else
	      x.sub(/^/,"http://")
      end
    end	
  end

  def make_target_list(opts)
	url_list = opts[:argv]
        
	# add example urls to url_list if required. plugins must be loaded already
	if opts[:enable_example_urls]
		url_list += pluginlist.map {|name,plugin| plugin.examples unless plugin.examples.nil? }.compact.flatten
	end

        genrange=url_list.map do |x|
	  range=nil
	  if x =~ /^[0-9\.\-*\/]+$/ and not x =~ /^[\d\.]+$/
	    # check for nmap
	    error "Target ranges require nmap to be in the path" if `which nmap` == ""
	    range=`nmap -n -sL #{x} 2>&1 | egrep -o "([0-9]{1,3}\\.){3}[0-9]{1,3}"`
	    range=range.split("\n")
	  end
	  range
	end.compact.flatten
	
	url_list= url_list.select {|x| not x =~ /^[0-9\.\-*\/]+$/ or x =~ /^[\d\.]+$/ }
	url_list += genrange unless genrange.empty?
     
  if(@input_file)
  while(!@input_file.eof?) do
    s=@input_file.gets.strip
    if File.exists?(s)
      @file_pile.queue.push(s)
    else 
      url_list << s
    end
  end
  end

	url_list=url_list.flatten #.sort.uniq
  end

end
end