FROM ruby:3.5.0-preview1-slim

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  sqlite3 \
  libsqlite3-dev \
  libyaml-dev \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local force_ruby_platform true && \
    bundle config set --local without 'development' && \
    bundle install

# Copy application files
COPY . .

# Create database if it doesn't exist
RUN bundle exec rake db:migrate

# Expose port
EXPOSE 9292

# Start the web server
CMD ["rackup", "-o", "0.0.0.0"]
