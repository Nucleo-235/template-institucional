def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

gsub_file "Gemfile", /.*$/,''
gsub_file "Gemfile", /^$\n/, ''

add_source 'https://rubygems.org'

insert_into_file 'Gemfile', "\nruby ENV['CUSTOM_RUBY_VERSION'] || '2.2.4'", 
                 after: "source 'https://rubygems.org'\n"

gem 'rails', '4.2.5'
gem 'pg'
gem 'actionmailer'
gem 'active_model_serializers'
gem 'http_accept_language'
gem 'globalize', '~> 5.0.0'
gem 'responders'

# workers
gem 'redis'
gem 'redis-namespace'
gem 'sidekiq', '~> 3.2.6'

# backend libs
gem 'kaminari'
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'carrierwave_backgrounder'
gem 'high_voltage', '~> 2.2.1' # gem para paginas estaticas
# gem 'easing', '~> 0.1.0' # para ter calculos de easing no back-end

# front-end engine
gem 'slim'
gem 'slim-rails'

# front-end libs
gem 'uglifier', '>= 1.3.0'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'sass-rails', '>= 3.2'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-easing-rails'
gem 'font-awesome-rails'
gem 'bourbon'
gem 'noty-rails'

# view helpers/generators
gem 'simple_form'
gem 'mail_form'
gem 'country_select'
gem 'cocoon' #nested forms
gem 'best_in_place', '~> 3.0.1'
gem 'redcarpet', '>= 3.0.0'
gem 'inplace_editing'# , :git => 'git://github.com/hrangel/inplace_editing.git'
gem 'localizable_value'# , :git => 'git://github.com/hrangel/localizable_value.git'

# users & auth
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-instagram'
gem 'omniauth-twitter'
gem 'omniauth-linkedin'
gem 'omniauth-google-oauth2'

# mail, analytics & logs
gem 'madmimi'
gem 'google-analytics-rails'
gem 'rollbar'

gem_group :development do
  gem 'annotate', '>=2.6.0'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'spring'
  gem 'xray-rails'
  gem 'rails-erd', github: 'paulwittmann/rails-erd', branch: 'mavericks'
  gem 'letter_opener'
end

gem_group :test do
  gem 'shoulda-matchers'
end

gem_group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'better_errors'
  gem 'binding_of_caller'
end

gem_group :production do
  gem 'rails_12factor'
end

gsub_file "config/application.rb", /config.active_record.raise_in_transactional_callbacks = true\n/,''
inject_into_file 'config/application.rb', :after => "class Application < Rails::Application" do 
  <<-eos

    config.i18n.default_locale = 'pt-BR'
    config.i18n.available_locales = ['pt-BR', :en, :es]
    config.time_zone = 'Brasilia'

    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.assets.precompile += %w(.svg .eot .woff .ttf .css .js)

    config.generators do |g|
      g.assets         false
      g.helper         false
      g.test_framework nil
    end

    config.active_record.raise_in_transactional_callbacks = true
eos
end


app_name.gsub!('-', '_')

# sets database to postgresql
gsub_file "config/database.yml", /adapter: sqlite3/, "adapter: postgresql\n\s\sencoding: unicode"
gsub_file "config/database.yml", /database: db\/development.sqlite3/, "database: #{app_name}_development"
gsub_file "config/database.yml", /database: db\/test.sqlite3/,        "database: #{app_name}_test"
gsub_file "config/database.yml", /database: db\/production.sqlite3/,  "database: #{app_name}_production"

run 'bundle install'

rake "db:reset", :env => 'test'
rake "db:reset", :env => 'development'
rake "db:create", :env => 'test'
rake "db:create", :env => 'development'

# Clean up Assets
# ==================================================
# Use SASS extension for application.css
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss"
# Remove the require_tree directives from the SASS and JavaScript files.
# It's better design to import or require things manually.
run "sed -i '' /require_tree/d app/assets/javascripts/application.js"
run "sed -i '' /require_tree/d app/assets/stylesheets/application.css.scss"
# Add bourbon to stylesheet file
run "echo >> app/assets/stylesheets/application.css.scss"
run "echo '@import \"bourbon\";' >>  app/assets/stylesheets/application.css.scss"
run "echo '@import \"bootstrap-sprockets\";' >>  app/assets/stylesheets/application.css.scss"
run "echo '@import \"bootstrap\";' >>  app/assets/stylesheets/application.css.scss"
run "echo '@import \"font-awesome\";' >>  app/assets/stylesheets/application.css.scss"

# Add bourbon to jquery, bootstrap and best_in_place to javascript file
run "echo '//= require jquery' >> app/assets/javascripts/application.js"
run "echo '//= require bootstrap-sprockets' >> app/assets/javascripts/application.js"
run "echo '//= require best_in_place' >> app/assets/javascripts/application.js"
run "echo '//= require jquery_ujs' >> app/assets/javascripts/application.js"
run "echo '//= require best_in_place' >> app/assets/javascripts/application.js"
run "echo '//= require inplace_editing' >> app/assets/javascripts/application.js"
run "echo '
$(document).ready(function() {
  /* Activating Best In Place */
  jQuery(\".best_in_place\").best_in_place();
});
' >> app/assets/javascripts/application.js"


generate 'simple_form:install --bootstrap'

# Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
# ===================================================
run "cat << EOF >> .gitignore
# See https://help.github.com/articles/ignoring-files for more about ignoring files.
#
# If you find yourself ignoring temporary files generated by your text editor
# or operating system, you probably want to add a global ignore instead:
#   git config --global core.excludesfile '~/.gitignore_global'

# Ignore bundler config.
/.bundle

# Ignore the default SQLite database.
/db/*.sqlite3
/db/*.sqlite3-journal
/db/schema.rb

# Ignore all logfiles and tempfiles.
/log/*.log
/tmp

.DS_Store
/public/uploads

# vagrant
/.vagrant
/Vagrantfile
/puppet
/bootstrap.sh

#sublime
*.sublime-project
*.sublime-workspace
EOF"

# Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
# ===================================================
app_name.gsub!('_', '-')
run "cat << EOF >> #{app_name}.sublime-project
{
  \"folders\":
  [
    {
      \"follow_symlinks\": true,
      \"path\": \".\"
    }
  ]
}
EOF"

# setup tests
generate "rspec:install"

# authentication and authorization setup
generate "devise:install" 
generate "devise User" 
generate "devise:views"
run 'rails g migration add_extra_fields_to_user type:string name:string'
run 'rails g model Admin --parent User'
rake "db:migrate", :env => 'test'
rake "db:migrate", :env => 'development'

# gera primeiro controller e pagina inicial
generate "controller Pages home --skip-routes"
route "root to: 'pages#home'"

# sets as slim
run 'gem install html2slim'
run 'for file in app/views/devise/**/*.erb; do erb2slim $file ${file%erb}slim && rm $file; done'
run 'for file in app/views/**/*.erb; do erb2slim $file ${file%erb}slim && rm $file; done'

# clean up rails defaults 
remove_file 'public/index.html' 
remove_file 'rm public/images/rails.png'

# carrierwave
app_name.gsub!('-', '.')
run "cat << EOF >> config/initializers/carrierwave.rb
CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :aws
    config.aws_bucket =  \"#{app_name}.live\"
  elsif (Rails.env.development? && Rails.application.secrets.aws_access_key_id.present?)
    config.storage = :aws
    config.aws_bucket =  \"#{app_name}.dev\"
  else
    config.storage = :file
    config.aws_bucket =  \"#{app_name}\"
  end
  config.aws_acl    =  :public_read

  config.aws_credentials = {
    access_key_id:      Rails.application.secrets.aws_access_key_id,    # required
    secret_access_key:  Rails.application.secrets.aws_secret_access_key,    # required
    region: \"sa-east-1\"
  }
end
EOF"

copy_file "template_file_size_validator.rb", "lib/file_size_validator.rb"
inside('app') do 
  run "mkdir uploaders" 
end
#run "cp ../../template_user_image_uploader.rb app/uploaders/user_image_uploader.rb"
copy_file "template_user_image_uploader.rb", "app/uploaders/user_image_uploader.rb"

gsub_file "app/models/user.rb", /class User < ActiveRecord::Base/,  "require 'file_size_validator'

class User < ActiveRecord::Base"

gsub_file "app/models/admin.rb", /class Admin < User/,  "class Admin < User
  def self.create_admin_if_new(email, name)
    admin = Admin.find_by(email: email)
    if !admin
      admin = Admin.new(name: name, email: email, password: \"12345678\", password_confirmation: \"12345678\")
      # admin.skip_confirmation!
      admin.save!
    end
  end
  "
copy_file "db.rake", "lib/tasks/db.rake"
rake "db:load_nucleo_admins", :env => 'development'

gsub_file "app/models/user.rb", /include DeviseTokenAuth::Concerns::User/,  "include DeviseTokenAuth::Concerns::User

  mount_uploader :image, UserImageUploader
  validates :image, allow_blank: true, file_size: { maximum: 3.megabytes.to_i,  message: \"O arquivo enviado é muito grande. Tamanho máximo 3 MB.\"}"

gsub_file "app/controllers/application_controller.rb", /protect_from_forgery with: :exception/,  "protect_from_forgery with: :exception
  before_action :set_locale
  before_action :persist_locale
  before_action :set_editor_config
  before_action :set_localizable_page

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  private
    def redirect_to_locale_if_not_set
        if params[:locale]
          I18n.locale = params[:locale]
          # current_user_or_visitor.update(locale: I18n.locale.to_s)
        else
          locale = request_locale || I18n.default_locale
          redirect_to url_for(request.params.merge({ locale: locale }))
        end
      end

    def get_locale
      # params[:locale] || visitor_locale || request_locale || I18n.default_locale
      params[:locale] || request_locale || I18n.default_locale
    end

    def set_locale
      I18n.locale = get_locale
    end

    def persist_locale
      # current_user_or_visitor.update(locale: I18n.locale.to_s) if params[:locale]
    end

    def request_locale
      extra_locales = [:pt]
      locale = http_accept_language.preferred_language_from(I18n.available_locales + extra_locales)
      locale = 'pt-BR' if locale == :pt || locale.to_s.downcase == 'pt-pt' || locale.to_s.downcase == 'pt-br'
      locale
    end

    def set_editor_config
      @can_edit = current_user && current_user.type == Admin.name # or true
      @inplace_editing_mode = (@can_edit ? 'edit' : 'read')
    end

    def set_localizable_page
      @global_page = LocalizableValue::LocalizedPage.global_page

      route_control = controller_name ? controller_name : 'root'
      route_action = action_name ? action_name : 'home'
      @current_page = LocalizableValue::LocalizedPage.current_page(route_control, route_action)
    end"

gsub_file "app/controllers/pages_controller.rb", /class PagesController < ApplicationController/,  "class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_locale, only: [:home]
  skip_before_action :persist_locale, only: [:home]
  before_action :redirect_to_locale_if_not_set, only: [:home]"

gsub_file "config/initializers/devise.rb", /config.sign_out_via = :delete/,  "config.sign_out_via = :get"

gsub_file "config/routes.rb", /root to: 'pages#home'/,  "scope \"(:locale)\", locale: /pt-BR|en|es/ do
    root to: 'pages#home'
  end"

run 'annotate'

rake "localizable:setup", :env => 'development'

generate 'rollbar'
gsub_file "config/initializers/rollbar.rb", /if Rails.env.test?
    config.enabled = false
  end/,  "if Rails.env.test? || !ENV['ROLLBAR_ACCESS_TOKEN']
    config.enabled = false
  else
    config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  end"