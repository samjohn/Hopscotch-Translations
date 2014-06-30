Hopscotch-Translations
======================

App for interacting with gengo to translate Hopscotch localizable.strings files


### Getting Started
- Add the english Localizable.strings to s3
- Make sure the permissions allow reading by anyone
- `heroku run rake db:seed` to seed your database from the Localizable.strings files in s3
- `heroku run rake gengo:translate` to translate all the new words that are not translated yet
- wait for stuff to be translated
- `heroku run rake gengo:sync_all`
- `heroku run rake localizable_strings:write`
- Now your translations should be in the AWS bucket
- everything should be translated now, if not start reading the code! 

### Translating Release Notes
* Get heroku access from Sam and set up heroku as a remote 
* Add the release notes to the translations website (form at the end of the english words list)
* `heroku run rake gengo:translate`
* Wait for translations to finish
* Check on gengo.com that the translations are finished (get username and password from Sam)
* `heroku run rake gengo:sync_all`
