
  require 'rubygems'
  require 'sinatra'
  require 'yaml'
  require 'json'
  require 'net/http'
  require 'rest-client'

  set :requests, 0
  set :bind, '0.0.0.0'
  set :protection, :except => :frame_options

  ev = JSON.pretty_generate(ENV.to_hash)

  get '/' do
     puts ev
     settings.requests += 1
     begin
       app_info = ENV['VCAP_APPLICATION'] ? JSON.parse(ENV['VCAP_APPLICATION']) : Hash.new
       ENV['APP_NAME'] = app_info["application_name"] ? app_info["application_name"] : "unknown"
       ENV['APP_INSTANCE'] = app_info["instance_index"] ? app_info["instance_index"].to_s : "unknown"
       ENV['APP_MEM'] = app_info["limits"] ? app_info["limits"]["mem"].to_s : " "
       ENV['APP_DISK'] = app_info["limits"] ? app_info["limits"]["disk"].to_s : " "
       ENV['APP_IP'] = IPSocket.getaddress(Socket.gethostname)
       ENV['APP_PORT'] = app_info["port"] ? app_info["port"].to_s : "unknown"
       ENV['SERVICE_JSON'] = ENV['VCAP_SERVICES'] ? JSON.pretty_generate(JSON.parse(ENV['VCAP_SERVICES'])) : "n/a"
       ENV['EVERYTHING'] = ev
     rescue Exception => err
       puts err.to_s
     end

     erb :'index'
  end

  get '/tile' do
    settings.requests += 1
    app_info = ENV['VCAP_APPLICATION'] ? JSON.parse(ENV['VCAP_APPLICATION']) : Hash.new
    ENV['APP_NAME'] = app_info["application_name"] ? app_info["application_name"] : "unknown"
    ENV['APP_INSTANCE'] = app_info["instance_index"] ? app_info["instance_index"].to_s : "-1"
    ENV['REQ_COUNT'] = settings.requests.to_s
    services = ENV['VCAP_SERVICES'] ? JSON.parse(ENV['VCAP_SERVICES']) : {}
    if services['cleardb'] or services['p-mysql'] then
      ENV['DB_HTML'] = "<img src='/img/db.png' width='32px' height='32px' alt='db'></img>"
    end
    if ENV['OCC_BUG'] then
      r = Random.new
      x = r.rand(10)
      if x > 6 then
        ENV['BUG_HTML'] = "<img src='/img/bug.png' width='32px' heigh='32px' alt='bug'></img>"
      else
        ENV['BUG_HTML'] = ""
      end

    end


    erb :'index2'
  end


  get '/tiles' do
    erb :'tiles'
  end

  get '/tile-demo' do
    erb :'tile-demo'
  end


  get '/killSwitch' do
    Kernel.exit!
  end

  get '/load' do
    i = 0
    puts (File.read("banner.txt"))
    myStr = "Kill the CPU!!!"
    buff = ""
    while i < 50000  do
      buff += myStr.to_s
      buff.reverse!
      i += 1
    end
    settings.requests += 1
    "<h2>I'm healthy2!</h2>"
  end

  get '/health' do
    content_type 'application/json'
    {:status => 'UP'}.to_json
  end

  get '/greet/:name/:num' do
    g = {'name' => params['name'], 'num' => params['num']}
    g.to_json

  end

  get '/info' do
    {}.to_json
  end

  get '/javafortune' do
    content_type 'application/json'
    RestClient::get("http://localhost:#{ENV['eureka_port'] || 8087}/fortunes/random")
  end

  get '/pythonfortune' do
    content_type 'application/json'
    RestClient::get("http://localhost:#{ENV['eureka_port'] || 8087}/python-demo/javafortune")
  end

  get '/nodefortune' do
    content_type 'application/json'
    RestClient::get("http://localhost:#{ENV['eureka_port'] || 8087}/node-demo/javafortune")
  end

  get '/gofortune' do
    content_type 'application/json'
    RestClient::get("http://localhost:#{ENV['eureka_port'] || 8087}/go-demo/javafortune")
  end

  get '/dockerfortune' do
    content_type 'application/json'
    RestClient::get("http://localhost:#{ENV['eureka_port'] || 8087}/docker-demo/javafortune")
  end

  get '/endoftheworld' do
    content_type 'application/json'
    RestClient::get("http://localhost:#{ENV['eureka_port'] || 8087}/python-demo/endoftheworld")
  end


