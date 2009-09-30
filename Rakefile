require 'rubygems'
require 'ptolemy'
 
Ptolemy::Mapper.map_directory = File.dirname(__FILE__) + "/tmp"

namespace :mappings do

  def format_mapping(length, source, target)
    "\t%-#{length}s => %s" % [source, target]
  end 

  desc "compare the source rules of a specific map definition with the target rules of another"
  task :compare do
    s_key = ARGV[1]
    t_key = ARGV[2]
    Ptolemy::Mapper.load_maps
    Ptolemy::Tools.compare(s_key, t_key) do |length, source, target|
      puts format_mapping(length, source, target)
    end
  end
  
  desc "iterate through a specific map definition and spit out mapping rules"
  task :definition do
    key = ARGV[1].to_sym
    puts "Map definition for: '#{key.to_s}'\n\n"
    Ptolemy::Mapper.load_maps
    Ptolemy::Tools.list_definition(key) do |length, source, target|
      puts format_mapping(length, source, target)
    end
    puts "\n\n"
  end

  desc "list all map definition keys"
  task :keys do
    Ptolemy::Mapper.load_maps
    Ptolemy::Tools.keys
  end

  desc "iterate through a specific map definition and spit out source rules"
  task :sources do
    key = ARGV[1].to_sym
    puts "Map definition sources: '#{key.to_s}'\n\n"
    Ptolemy::Mapper.load_maps
    Ptolemy::Tools.list_sources(key) do |source|
      puts source
    end
  end

  desc "iterate through a specific map definition and spit out target rules"
  task :targets do
    key = ARGV[1].to_sym
    puts "Map definition targets: '#{key.to_s}'\n\n"
    Ptolemy::Mapper.load_maps
    Ptolemy::Tools.list_targets(key) do |target|
      puts target
    end
  end

  desc "translate a single mapping rule for a specific definition"
  task :translate_rule do
    definition = ARGV[1].to_sym
    source_path = ARGV[2].to_sym
    source = {:code => "LMP"}
    puts "Map translation of rule '#{rule}' for definition '#{definition}'\n\n"
    Ptolemy::Mapper.load_maps
    puts Ptolemy::Tools.translate(definition, source_path, source)
  end

end
