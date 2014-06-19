# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/models.rb

after_bundler do
  say_wizard "recipe running after 'bundle install'"
  ### DEVISE ###
  if prefer :authentication, 'devise'
    if rails_4_1?
      # prevent logging of password_confirmation
      gsub_file 'config/initializers/filter_parameter_logging.rb', /:password/, ':password, :password_confirmation'
    end
    generate 'devise:install'
    generate 'devise_invitable:install' if prefer :devise_modules, 'invitable'
    generate 'devise user' # create the User model
    ## DEVISE AND ACTIVE RECORD
    generate 'migration AddNameToUsers name:string'
    copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/' unless rails_4?
    if (prefer :devise_modules, 'confirmable') || (prefer :devise_modules, 'invitable')
      gsub_file 'app/models/user.rb', /:registerable,/, ":registerable, :confirmable,"
      generate 'migration AddConfirmableToUsers confirmation_token:string confirmed_at:datetime confirmation_sent_at:datetime unconfirmed_email:string'
    end
    run 'bundle exec rake db:migrate'
  end
  ### OMNIAUTH ###
  if prefer :authentication, 'omniauth'
    if rails_4_1?
      copy_from_repo 'config/initializers/omniauth.rb', :repo => 'https://raw.github.com/RailsApps/rails-omniauth/master/'
    else
      copy_from_repo 'config/initializers/omniauth.rb', :repo => 'https://raw.github.com/RailsApps/rails3-mongoid-omniauth/master/'
    end
    gsub_file 'config/initializers/omniauth.rb', /twitter/, prefs[:omniauth_provider] unless prefer :omniauth_provider, 'twitter'
    generate 'model User name:string email:string provider:string uid:string'
    run 'bundle exec rake db:migrate'
    copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails-omniauth/master/'
  end
  ### AUTHORIZATION ###
  if prefer :authorization, 'pundit'
    generate 'migration AddRoleToUsers role:integer'
    copy_from_repo 'app/models/user.rb', :repo => 'https://raw.github.com/RailsApps/rails-devise-pundit/master/'
    if (prefer :devise_modules, 'confirmable') || (prefer :devise_modules, 'invitable')
      gsub_file 'app/models/user.rb', /:registerable,/, ":registerable, :confirmable,"
      generate 'migration AddConfirmableToUsers confirmation_token:string confirmed_at:datetime confirmation_sent_at:datetime unconfirmed_email:string'
    end
  end
  if prefer :authorization, 'cancan'
    generate 'cancan:ability'
    generate 'rolify Role User'
  end
  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: models"' if prefer :git, true
end # after_bundler

__END__

name: models
description: "Add models needed for starter apps."
author: RailsApps

requires: [setup, gems]
run_after: [setup, gems]
category: mvc
