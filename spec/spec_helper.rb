require 'rubygems'
require 'spec'
require 'ruby-debug'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'ptolemy'

alias :running :lambda

[:get, :post, :action, :process].each do |action|
  eval %Q{
    def before_#{action}
      yield
      do_#{action}
    end
    alias during_#{action} before_#{action}
    def after_#{action}
      do_#{action}
      yield
    end
  }
end

NAMESPACED_DEFINITION = <<-EOT
  namespace "event" do
     define "contact" do
      direction "hash" => "xml"

      map "name/first" => "event/first_name"
      map "name/last" => "event/last_name"
    end
   end 
EOT

NESTED_NAMESPACED_DEFINITION = <<-EOT
namespace "event" do
  namespace "contact" do
    define "personal" do
      direction "hash" => "xml"

      map "name/first" => "event/first_name"
      map "name/last" => "event/last_name"
    end
  end 
end 
EOT

DEFINITION = <<-EOT
   define "contact" do

    direction "hash" => "xml"
    map "name/first" => "event/first_name"
    map "name/last" => "event/last_name"

  end
EOT
