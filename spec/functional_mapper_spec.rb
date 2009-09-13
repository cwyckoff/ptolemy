require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Ptolemy

  describe "Mapper" do

    describe "#load" do

      it "should create namespaced definitions" do
bbl = <<-EOT
  namespace "foo" do

     define "bar" do
      direction :from => :hash, :to => :xml

      map :from => "name/first", :to => "event/first_name"
      map :from => "name/last", :to => "event/last_name"
    end

   end 
EOT

        require 'ruby-debug'; Debugger.start; debugger
        Mapper.load(bbl)
        Mapper.namespaces.should_not be_empty
      end

    end

    it "should create non-namespaced definitions" do
bbl = <<-EOT

   define "baz" do

    direction :from => :hash, :to => :xml
     map :from => "name/first", :to => "event/first_name"
    map :from => "name/last", :to => "event/last_name"

  end

EOT
      require 'ruby-debug'; Debugger.start; debugger
      Mapper.load(bbl)
      Mapper.definitions.should_not be_empty
    end

  end 
end
