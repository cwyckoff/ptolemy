require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Ptolemy

  describe "Mapper" do

    before(:each) do
@namespace = <<-EOT
  namespace "foo" do
     define "bar" do
      direction "hash" => "xml"

      map "name/first" => "event/first_name"
      map "name/last" => "event/last_name"
    end
   end 
EOT

@nested_namespace = <<-EOT
namespace "foo" do
  namespace "bar" do
    define "baz" do
      direction "hash" => "xml"

      map "name/first" => "event/first_name"
      map "name/last" => "event/last_name"
    end
  end 
end 
EOT

@define = <<-EOT
   define "baz" do

    direction "hash" => "xml"
    map "name/first" => "event/first_name"
    map "name/last" => "event/last_name"

  end
EOT
    end

    describe "#load" do

      context "if definition is namespaced" do

        it "should create namespaced definitions" do

          Mapper.load_str(@namespace)
          Mapper.namespaces.should_not be_empty
        end

      end 

      context "if definition is not namespaced" do

        it "should create non-namespaced definitions" do
          Mapper.load_str(@define)
          Mapper.definitions.should_not be_empty
        end
        
      end

    end

    describe "#translate" do

      it "should translate definition" do
        # given
        Mapper.reset
        Mapper.load_str(@define)
        hash = {:name => {:first => "Sherlock", :last => "Holmes"}}

        # expect
        Mapper.translate(:baz, hash).to_s.should == <<-EOX
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<event>
  <first_name>Sherlock</first_name>
  <last_name>Holmes</last_name>
</event>
EOX
      end

      describe "namespacing" do

        it "should translate namespaced definition" do
          # given
          Mapper.reset
          Mapper.load_str(@namespace)
          hash = {:name => {:first => "Sherlock", :last => "Holmes"}}

          # expect
          Mapper[:foo].translate(:bar, hash).to_s.should == <<-EOX
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<event>
  <first_name>Sherlock</first_name>
  <last_name>Holmes</last_name>
</event>
EOX
        end
        
        it "should translate nested namespaced definition" do
          # given
          Mapper.reset
          Mapper.load_str(@nested_namespace)
          hash = {:name => {:first => "Sherlock", :last => "Holmes"}}

          # expect
          Mapper[:foo][:bar].translate(:baz, hash).to_s.should == <<-EOX
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<event>
  <first_name>Sherlock</first_name>
  <last_name>Holmes</last_name>
</event>
EOX
        end
        
      end
    end 
  end 
end
