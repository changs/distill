require 'rack'
require_relative 'web'

use Rack::Static, urls: ['/style.css', '/script.js'], root: 'public'

run DistillApp.new
