require 'mkmf'

java_home = ENV["JAVA_HOME"]
unless java_home
  %w(
    /usr/lib/jvm/java-6-openjdk
  ).each do |path|
    if File.directory?(path)
      java_home = path
      $stderr << "Warning: Automatically guessed #{path} as Java home, might not be correct.\n"
    end
  end
  abort("JAVA_HOME needs to be defined.") unless java_home
end
puts("Java home: #{java_home}")

java_lib_path = ENV["JAVA_LIB"]
unless java_lib_path
  libjvm = "libjvm.so"
  [
    "#{java_home}/lib",
    "#{java_home}/lib/*/client",
    "#{java_home}/lib/*/server",
    "#{java_home}/jre/lib",
    "#{java_home}/jre/lib/*/client",
    "#{java_home}/jre/lib/*/server"
  ].each do |glob|
    Dir.glob(glob).each do |path|
      if File.exist?(File.join(path, libjvm))
        java_lib_path ||= path 
        break
      end
    end
  end
  abort("Could not determine Java library path (need #{libjvm})") unless java_lib_path
end
puts("Java library path: #{java_lib_path}")

java_include_paths = Dir.glob("#{java_home}/include/**/.").map { |s| s.gsub(/\/\.$/, '') }
puts("Java include paths: #{java_include_paths.join(', ')}")
java_include_paths.each do |path|
  $INCFLAGS << " -I#{path}"
end

dir_config("hdfs")
find_library("jvm", nil, java_lib_path)
find_library("hdfs", nil, java_lib_path)
have_library("c", "main")
create_makefile("hdfs")
