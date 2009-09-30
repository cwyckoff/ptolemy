spec = Gem::Specification.new do |s|
  s.name = 'ptolemy'
  s.version = '0.0.2'
  s.date = '2009-09-30'
  s.summary = 'Ptolemy dynamic and scalable mapping tool'
  s.email = "github@cwyckoff.com"
  s.homepage = "http://github.com/cwyckoff/ptolemy"
  s.description = 'Ptolemy dynamic and scalable mapping tool'
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc", "--title", "Ptolemy - A Mapping Tool for the Ages"]
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE"]
  s.authors = ["Chris Wyckoff"]
  s.add_dependency('libxml-ruby')
  
  s.files = ["init.rb",
	     "lib/ptolemy.rb",
             "lib/ptolemy/map_condition.rb",
             "lib/ptolemy/mappers/base_map.rb",
             "lib/ptolemy/mappers/xml_map.rb",
             "lib/ptolemy/mappers/hash_map.rb",
             "lib/ptolemy/map_factory.rb",
             "lib/ptolemy/mapper.rb",
             "lib/ptolemy/path_translator.rb",
             "lib/ptolemy/map_rule.rb",
             "lib/ptolemy/map_definition.rb",
             "lib/ptolemy/tools.rb",
             "lib/ptolemy/core_ext/libxml_node.rb",
             "lib/ptolemy/core_ext/enumerable.rb"]
end
