# wikirate-ccc
Widget to search for supply chain data on wikirate.org.

## options

You can add the following parameters to the url:

* show help how to embed the widget: `embed-info=show`
* change background color: `background=%23550044`

Example:
  
http://ccc.wikirate.org/?embed-info=show&background=%23550000

## developer setup
The site is developed with [Middleman](https://middlemanapp.com). It depends on Ruby and the 
RubyGems package manager. If you don't have that you can follow these [instructions](https://middlemanapp.com/basics/install/). 
 
 
### installation 
```shell
git clone https://github.com/wikirate/wikirate-ccc
cd wikirate-ccc
bundle install
```

### build site
```
bundle exec middleman build
```

### run local server
```
bundle exec middleman server
```  

The command returns a url where you can access the site.
Middleman automatically picks up source changes and refreshes
the site in the browser.

### deploy to wikirate server
``` 
bundle exec cap production deploy
```

