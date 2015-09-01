Hopscotch-Translations
======================

App for interacting with gengo to translate Hopscotch localizable.strings files


# Note: if you are experiencing errors, the first thing to check is whether you are out of money on Gengo

### Getting Started
1. Run `./hs_do_translations` from the iPad app's directory.
2. Wait for stuff to be translated. Check Gengo.com
3. Run `./hs_get_translations` from the iPad app's directory

### Translating Release Notes
* Get heroku access from Sam and set up heroku as a remote 
* Add the release notes to the translations website (form at the end of the english words list)
* `heroku run rake gengo:translate`
* Wait for translations to finish
* Check on https://gengo.com/c/dashboard/ that the translations are finished (get username and password from Sam)
* `heroku run rake gengo:sync_all`


### Setting up translations locally.
* Make sure you set up config/application.yml (Ask Sam for help)
* 

### Common Errors
* `Bad entry in file Hopscotch/Helpers/HSHelp.m (line = 56): Argument is not a literal string.` Ignore this error. We are taking care of those translations separately.
* If you see:
`Gengo::Exception: Gengo::Exception
/app/vendor/bundle/ruby/2.0.0/gems/gengo-0.0.5/lib/gengo-ruby/api_handler.rb:161:in `send_to_gengo'
/app/vendor/bundle/ruby/2.0.0/gems/gengo-0.0.5/lib/gengo-ruby/api_handler.rb:255:in `postTranslationJobs'
`
It means you are probably out of money on Gengo and need to add money before continuing.
