Hopscotch-Translations
======================

App for interacting with gengo to translate Hopscotch localizable.strings files


### Getting Started
- Add the english Localizable.strings to s3, make sure the permissions allow reading by anyone
- run rake db:seed to seed your database from the Localizable.strings files in s3
- run rake db:translate to translate all the new words that are not translated yet
- wait for stuff to be translated
- run rake gengo:sync_all
- everything should be translated now, if not start reading the code! 
