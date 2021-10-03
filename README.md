# KururunBot: Kururun! Kuru-kuru, kururun! Kururun!

KururunBot is a Ruby Twitter bot that posts images of Kururun to Twitter every
hour and responds to mentions and replies with text responses.

## How to use for your own Twitter bot

- Clone the repository locally
- Fill `config.yml` with the necessary tokens and secrets (requires Twitter
  developer account and application)
- Delete the `README.md` files in `media/` and `media/priority`, and put images
  and GIFs in them
- Change `responses.yml` to any responses you want
- Install Bundler with `gem install bundler` if it's not already installed, and
  run `bundle install`
- Run `ruby kururun_bot.rb`
