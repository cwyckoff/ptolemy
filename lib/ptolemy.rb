require 'rubygems'
require 'xml'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require "ptolemy/core_ext/enumerable"
require "ptolemy/core_ext/libxml_node"
require "ptolemy/map_rule"
require "ptolemy/map_definition"
require "ptolemy/map_factory"
require "ptolemy/path_translator"
require "ptolemy/mappers/base_map"
require "ptolemy/mappers/xml_map"
require "ptolemy/mappers/hash_map"
require "ptolemy/mapper"
require "ptolemy/map_condition"
require "ptolemy/tools"

