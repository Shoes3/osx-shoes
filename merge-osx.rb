
module PackShoes
 require 'fileutils'
 def PackShoes.rewrite a, before, hsh
    File.open(before) do |b|
      b.each do |line|
        a << line.gsub(/\#\{(\w+)\}/) {
          if hsh[$1] 
            hsh[$1]
          else
            '#{'+$1+'}'
          end
        }
      end
    end
  end
  
  def PackShoes.merge_osx opts
    # setup defaults if not in the opts
    rbvstr = opts['target_ruby'] ? opts['target_ruby'] : RUBY_VERSION
    rbmm = rbvstr[/\d.\d/].to_str
    # user gems can have a different arch from shoes (hypthen)
    tarch = opts['target_ruby_arch']
    flds = tarch.split('-')
    if flds.size == 2
      rbarch = tarch
      ver = flds[1][/\d\d/]
      puts "parse #{ver.inspect}"
      gemarch = flds[0]+'-darwin-'+ver
      puts "rbarch-1: #{rbarch} garch: #{gemarch}"
    else # assume 3
      gemarch = tarch
      rbarch = "#{flds[0]}-#{flds[1]}#{flds[2]}"
      puts "rbarch-2: #{rbarch} garch: #{gemarch}"
    end
    opts['publisher'] = 'shoerb' unless opts['publisher']
    opts['website'] = 'http://shoesrb.com/' unless opts['website']
    #opts['hkey_org'] = 'Hackety.org' unless opts['hkey_org']
    opts['linux_where'] = '/usr/local' unless opts['linux_where']
    toplevel = []
    Dir.chdir(DIR) do
      Dir.glob('*') {|f| toplevel << f}
    end
    exclude = %w(static CHANGELOG.txt cshoes.exe gmon.out README.txt
      samples package VERSION.txt)
    #exclude = []
    #packdir = 'packdir'
    app_dir = "#{opts['app_name']}.app"
    rm_rf app_dir
    mkdir_p "#{app_dir}/Contents/MacOS"
    mkdir_p "#{app_dir}/Contents/Resources/English.lproj"
    packdir = "#{app_dir}/Contents/MacOS"
    # create the resource and sub icons
    app_name = opts['app_name']
    icon_name = File.basename(opts['app_icns'])
    cp opts['app_icns'], "#{app_dir}/"
    cp opts['app_icns'], "#{app_dir}/Contents/Resources/"
    vers =[0, 1]
    File.open(File.join(app_dir, "Contents", "PkgInfo"), 'w') do |f|
      f << "APPL????"
    end
    File.open(File.join(app_dir, "Contents", "Info.plist"), 'w') do |f|
      f << <<END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleGetInfoString</key>
  <string>#{app_name} #{vers.join(".")}</string>
  <key>CFBundleExecutable</key>
  <string>#{app_name}-launch</string>
  <key>CFBundleIdentifier</key>
  <string>#{opts['osx_identifier']}.#{name}</string>
  <key>CFBundleName</key>
  <string>#{app_name}</string>
  <key>CFBundleIconFile</key>
  <string>#{icon_name}</string>
  <key>CFBundleShortVersionString</key>
  <string>#{vers.join(".")}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>IFMajorVersion</key>
  <integer>#{vers[0]}</integer>
  <key>IFMinorVersion</key>
  <integer>#{vers[1]}</integer>
</dict>
</plist>
END
    end
  File.open(File.join(app_dir, "Contents", "version.plist"), 'w') do |f|
      f << <<END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>BuildVersion</key>
  <string>1</string>
  <key>CFBundleVersion</key>
  <string>#{vers.join(".")}</string>
  <key>ProjectName</key>
  <string>#{app_name}</string>
  <key>SourceVersion</key>
  <string>#{Time.now.strftime("%Y%m%d")}</string>
</dict>
</plist>
END
    end
    File.open(File.join(packdir, "#{app_name}-launch"), 'wb') do |f|
      f << <<END
#!/bin/bash
APPPATH="${0%/*}"
unset DYLD_LIBRARY_PATH
cd "$APPPATH"
echo "[Pango]" > pangorc
DYLD_LIBRARY_PATH="$APPPATH" PANGO_RC_FILE="$APPPATH/pangorc" SHOES_RUBY_ARCH="#{opts['shoesruby']}" ./#{app_name}-bin 
END
    end
    chmod 0755, File.join("#{packdir}/#{app_name}-launch")
    # copy shoes
    (toplevel-exclude).each do |p|
      cp_r File.join(DIR, p), packdir
    end
    # do the license stuff
    licf = File.open("#{packdir}/COPYING.txt", 'w')
    if opts['license'] && File.exist?(opts['license'])
      IO.foreach(opts['license']) {|ln| licf.puts ln}
      rm_rf "{packdir}/#{File.basename(opts['license'])}"
    end
    IO.foreach("#{DIR}/COPYING.txt") {|ln| licf.puts ln}  
    licf.close
    # we do need some statics for console to work. 
    mkdir_p "#{packdir}/static"
    Dir.glob("#{DIR}/static/icon*.png") {|p| cp p, "#{packdir}/static" }
    if opts['app_png']
      cp "#{opts['app_loc']}/#{opts['app_png']}", "#{packdir}/static/app-icon.png"
    end
    # remove chipmonk and ftsearch unless requested
    exts = opts['include_exts'] # returns []
    if  !exts || ! exts.include?('ftsearch')
      puts "removing ftsearchrt"
      rm "#{packdir}/lib/ruby/#{rbmm}.0/#{rbarch}/ftsearchrt.bundle" 
      rm_rf "#{packdir}/lib/shoes/help.rb"
      rm_rf "#{packdir}/lib/shoes/search.rb"
    end
    if  !exts || ! exts.include?('chipmunk')
      puts "removing chipmunk"
      rm "#{packdir}/lib/ruby/#{rbmm}.0/#{rbarch}/chipmunk.bundle"
      rm "#{packdir}/lib/shoes/chipmunk.rb"
    end
    # get rid of some things in lib
    rm_rf "#{packdir}/lib/exerb"
    rm_rf "#{packdir}/lib/gtk-2.0" if File.exist? "#{packdir}/lib/gtk-2.0"
    # remove unreachable code in packdir/lib/shoes/ like help, app-package ...
    ['cobbler', 'debugger', 'irb', 'pack', 'app_package', 'packshoes',
      'remote_debugger', 'winject', 'envgem'].each {|f| rm "#{packdir}/lib/shoes/#{f}.rb" }
  
    # copy app contents (file/dir at a time)
    app_contents = Dir.glob("#{opts['app_loc']}/*")
    app_contents.each do |p|
     cp_r p, packdir
    end
    #create new lib/shoes.rb with rewrite
    newf = File.open("#{packdir}/lib/shoes.rb", 'w')
    rewrite newf, 'min-shoes.rb', {'APP_START' => opts['app_start'] }
    newf.close
    # create a new lib/shoes/log.rb with rewrite
    logf = File.open("#{packdir}/lib/shoes/log.rb", 'w')
    rewrite logf, 'min-log.rb', {'CONSOLE_HDR' => "#{opts['app_name']} Errors"}
    logf.close
    # copy/remove gems - tricksy - pay attention
    # remove the Shoes built-in gems if not in the list 
    incl_gems = opts['include_gems']
    rm_gems = []
    Dir.glob("#{packdir}/lib/ruby/gems/#{rbmm}.0/specifications/*gemspec") do |p|
      gem = File.basename(p, '.gemspec')
      if incl_gems.include?(gem)
        puts "Keeping Shoes gem: #{gem}"
        incl_gems.delete(gem)
      else
        rm_gems << gem
      end
    end
    sgpath = "#{packdir}/lib/ruby/gems/#{rbmm}.0"
    # sqlite is a special case so delete it differently - trickery
    if !incl_gems.include?('sqlite3')
      spec = Dir.glob("#{sgpath}/specifications/default/sqlite3*.gemspec")
      rm spec[0]
      rm_gems << File.basename(spec[0],'.gemspec')
    else
      incl_gems.delete("sglite3")
    end
    rm_gems.each do |g|
      puts "Deleting #{g}"
      rm_rf "#{sgpath}/specifications/#{g}.gemspec"
      rm_rf "#{sgpath}/extensions/#{rbarch}/#{rbmm}.0/#{g}"
      rm_rf "#{sgpath}/gems/#{g}"
    end
    # HACK ahead! Copy remaining Shoes gems gem.build_complete files
    # to different arch name because it's needed . Don't know why.
    bld = Dir.glob("#{sgpath}/extensions/#{rbarch}/#{rbmm}.0/*") do |p|
      nm = File.basename(p)
      puts "hack for #{nm}"
      cp_r "#{sgpath}/extensions/#{rbarch}/#{rbmm}.0/#{nm}", 
          "#{sgpath}/extensions/#{gemarch}/#{rbmm}.0"
    end

    # copy requested gems from user's GEMS_DIR - usually ~/.shoes/+gem
    incl_gems.delete('sqlite3') if incl_gems.include?('sqlite3')
    incl_gems.each do |name| 
      puts "Copy #{name}"
      cp "#{GEMS_DIR}/specifications/#{name}.gemspec", "#{sgpath}/specifications"
      # does the gem have binary?
      built = "#{GEMS_DIR}/extensions/#{gemarch}/#{rbmm}.0/#{name}/gem.build_complete"
      if File.exist? built
        mkdir_p "#{sgpath}/extensions/#{rbarch}/#{rbmm}.0/#{name}"
        cp "#{GEMS_DIR}/extensions/#{gemarch}/#{rbmm}.0/#{name}/gem.build_complete",
          "#{sgpath}/extensions/#{rbarch}/#{rbmm}.0/#{name}"
          
        mkdir_p "#{sgpath}/extensions/#{gemarch}/#{rbmm}.0/#{name}"
        cp "#{GEMS_DIR}/extensions/#{gemarch}/#{rbmm}.0/#{name}/gem.build_complete",
          "#{sgpath}/extensions/#{gemarch}/#{rbmm}.0/#{name}"
        
      end
      cp_r "#{GEMS_DIR}/gems/#{name}", "#{sgpath}/gems"
    end
    
    # hide shoes-bin and shoes launch script names
    puts "make_installer"
    after_install = "#{opts['app_name']}_install.sh"
    before_remove = "#{opts['app_name']}_remove.sh"
    where = opts['linux_where']
    Dir.chdir(packdir) do
      mv 'shoes-bin', "#{opts['app_name']}-bin"
      #chmod 0755, "#{opts['app_name']}"
      rm_rf 'shoes'
      rm_rf 'debug'
      rm_rf 'Shoes.desktop.tmpl'
      rm_rf 'Shoes.remove.desktop'
      rm_rf 'Shoes.remove.tmpl'
      rm_rf 'shoes-install.sh'
      rm_rf 'shoes-uninstall.sh'
      rm_rf 'Shoes.desktop'
    end
    # now we do fpm things - lets build a bash script for debugging
    arch = `uname -m`.strip
    File.open('fpm.sh','w') do |f|
      f << <<SCR
#!/bin/bash
fpm --verbose -t osxpkg -s dir -p #{app_name}.pkg -f -n #{opts['app_name']} \\
--osxpkg-identifier-prefix #{opts['osx_identifier']}  \\
--prefix /Applications -a #{arch} #{app_dir}
SCR
    end
    chmod 0755, 'fpm.sh'
    #puts "Please examine fpm.sh and then ./ftm.sh to build the .pkg"
    #`./fpm.sh`
    File.open('pkg.sh', 'w') do |f|
      f << <<SCR
pkgbuild --root #{app_dir} --identifier #{opts['osx_identifier']}.#{app_name} \\
--install-location /Applications #{app_name}.pkg
SCR
    end
    chmod 0755, 'pkg.sh'
    puts "Please examine pkg.sh and then ./pkg.sh to build the .pkg"
    `bsdtar -cjf #{app_name}.bz #{app_dir}`
  end
end

