require 'rack'
require_relative 'web'

use Rack::Static, urls: ['/style.css'], root: 'public'

run DistillApp.new
