require 'active_record'
require 'yaml'
require 'erb'
require_relative 'models/feed'
require_relative 'models/content'

# Load database configuration and establish connection
db_config = YAML.load_file('db/config.yml', aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])
ActiveSupport.to_time_preserves_timezone = :zone

class DistillApp
  def call(env)
    request = Rack::Request.new(env)

    case request.path
    when '/'
      render_index
    when /^\/content\/(\d+)$/
      content_id = $1.to_i
      render_content(content_id)
    when /^\/content\/(\d+)\/toggle_read$/
      if request.post?
        content_id = $1.to_i
        toggle_read(content_id, request)
      else
        [405, {'content-type' => 'text/html'}, ['<h1>Method Not Allowed</h1>']]
      end
    else
      [404, {'content-type' => 'text/html'}, ['<h1>Not Found</h1>']]
    end
  end

  private

  def render_index
    @feeds = Feed.includes(:contents).all
    @title = 'Feed Reader'
    html = render_template('views/index.erb', 'views/layout.erb')
    [200, {'content-type' => 'text/html; charset=utf-8'}, [html]]
  end

  def render_content(content_id)
    @content = Content.find_by(id: content_id)

    return [404, {'content-type' => 'text/html; charset=utf-8'}, ['<h1>Content Not Found</h1>']] unless @content

    @title = @content.title
    html = render_template('views/content.erb', 'views/layout.erb')
    [200, {'content-type' => 'text/html; charset=utf-8'}, [html]]
  end

  def toggle_read(content_id, request)
    content = Content.find_by(id: content_id)

    return [404, {'content-type' => 'text/html; charset=utf-8'}, ['<h1>Content Not Found</h1>']] unless content

    content.update(read: !content.read)
    [303, {'location' => request.referer || '/'}, []]
  end

  def render_template(template_path, layout_path = nil)
    template = ERB.new(File.read(template_path), trim_mode: '-')
    @content_for_layout = template.result(binding)

    if layout_path
      layout_erb = File.read(layout_path).gsub('<%= yield %>', '<%= @content_for_layout %>')
      layout = ERB.new(layout_erb, trim_mode: '-')
      layout.result(binding)
    else
      @content_for_layout
    end
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def raw(text)
    text.to_s
  end
end
