# OSX-Shoes 

This is a OSX only project that packages a **Tight** Shoes project into a more 
user friendly OSX format. It attempts to hide the use of Shoes as
the platform. Basically it merges your app into a copy of Shoes, delete's
built in Shoes ext's and gems and merges in any Gem's you specify that you've
installed in your OSX Shoes.

The result is a distribution file (.bz)  with just enough Shoes. No manual. No irb. No debug, no
samples and the static directory is minimal. No need for Cobbler or packaging. 
No clever shy files. 

At some point in the future there might be a GUI (packaged Shoes.app) to create the yaml,
and run the build for you. Don't wait for that, it's only eye candy and if it is written
probably doesn't do what you want. 

## Requirements 

* Shoes OSX installed - 
* osx's version of ruby. Doesn't matter what version.
* bsdtar OR 
* to create a dmg, we've included a copy of [create_dmg](https://github.com/andreyvit/create-dmg)
  Note: that package is not maintained. 
* later versions may use pkgbuild - which might require XCode and friends.
  PLEASE read http://thegreyblog.blogspot.com/2014/06/os-x-creating-packages-from-command_2.html


## Contents 

Git clone or download and unpack the zip.
Inside is the ytm/ directory which is a sample application and there is ytm-merge.rb 
and ytm.yaml. There is a merge-osx.rb which does all the work. You'll probably
want to modify it to load the yaml file for your app. 
There is a min-shoes.rb which will be copied and modified to call your starting script
instead of shoes.rb

Perhaps you're thinking "I need to know a lot about OSX packaging". Yes, you do.
This more of an example than it is a _works for every_ application.  

## Usage 

`$ ruby ytm-merge.rb`


The **sample** just loads ytm.yaml and calls the Shoes module function
PackShoes::merge_osx in merge-lin.rb passing the opts{hash} from the ytm.yaml settings and goes
to work building a .deb (or .rpm .. or) 

The .yaml for the example is 

```
shoes_at: /Users/ccoupe/build/xmavericks/Shoes.app/Contents/MacOS
target_ruby: '2.2.4'
target_ruby_arch: x86_64-darwin-13 # mavericks 10.9
app_name: Ytm
app_version: 'Demo'
app_loc: /Users/ccoupe/build/osx-shoes/ytm/
app_start: ytm.rb
app_png: ytm.png
app_icns: /Users/ccoupe/Projects/icons/ytm/ytm.icns
purpose: 'Compute Yield to Maturity'
publisher: 'Right Wing Conspiracy'
website: 'https://github.com/Shoes3/shoes3'
osx_identifier: 'com.mvmanila'
maintainer: 'ccoupe@cableone.net'
license: /Users/ccoupe/build/osx-shoes/ytm/Ytm.license
license_tag: 'open source'
category: Office
linux_where: /usr/local  # this less likely to cause problems
create_menu: true
include_exts:
# - ftsearch
# - chipmunk
include_gems:
# - sqlite3
# - nokogiri-1.6.7.1
 - ffi-1.9.10
 - rubyserial-0.2.4
```

Remember - That is just a demo!  Give it a try to see how it works. 

 Some of those yaml settings are based on the Linux version of this script
 
 app_loc: is where your app to package is and app_start: is the starting script
 in app_loc. app_png is your app icon in png format in app_loc. Yes, you need an icon,
 after all your trying to hide Shoes.

 If you want to include Shoes exts, ftsearch and chipmunk you would list them here.
 or delete those two lines (keep the include_exts: line)
 Unless you really do need chipmunk you shouldn't add it like I show above. Since you're not
 going to get a manual, you don't need ftsearch so delete those two lines.
 
 Gem are fun. You can include Shoes built in gems like sqlite and nokogiri as shown above
 and you can include gems you have installed in the Shoes (tshoes) that is running the script
 like ffi and rubyserial in the example. If you can't install the Gems in Shoes, then you can't include them.
 We don't automatically include dependent gems. You'll have to do that yourself with
 proper entries in your yaml file as I've shown above, 'rubyserial' requires 'ffi' for example
 
### app_name, app_version:

Read the merge-osx.rb script. It's not that big and it's yours to do what
you want.

Don't put any spaces in app_name unless your willing to fix things.
app_version isn't used in the OSX variation currently.


### Could I rewrite osx-merge.rb & ytm-merge.rb in python or bash ?

Of course you could! We're just moving files around and creating some text files
so #{app_dir} is something you can feed to whatever you want. 

