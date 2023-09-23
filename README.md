# KururunBot: Kururun! Kuru-kuru, kururun! Kururun!

KururunBot is a Ruby Twitter bot that posts images of Kururun to Twitter every
hour.

## How to use for your own Twitter bot

- Clone the repository locally
- Fill `config.yml` with the necessary tokens and secrets (requires Twitter
  developer account and application)
- Delete the `README.md` files in `media/` and `media/priority`, and put images
  and GIFs in them
- Install Bundler with `gem install bundler` if it's not already installed, and
  run `bundle install`
- Run `ruby kururun_bot.rb`
