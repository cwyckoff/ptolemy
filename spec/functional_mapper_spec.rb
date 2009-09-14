require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Ptolemy

  describe "Mapper" do

    before(:each) do
@namespace_pmy = <<-EOT
  namespace "foo" do
     define "bar" do
      direction :from => :hash, :to => :xml

      map :from => "name/first", :to => "event/first_name"
      map :from => "name/last", :to => "event/last_name"
    end
   end 
EOT

@define_pmy = <<-EOT
   define "baz" do

    direction :from => :hash, :to => :xml
     map :from => "name/first", :to => "event/first_name"
    map :from => "name/last", :to => "event/last_name"

  end
EOT
    end

    describe "#load" do

      context "if definition is namespaced" do

        it "should create namespaced definitions" do

          Mapper.load_str(@namespace_pmy)
          Mapper.namespaces.should_not be_empty
        end

      end 

      context "if definition is not namespaced" do

        it "should create non-namespaced definitions" do
          Mapper.load_str(@define_pmy)
          Mapper.definitions.should_not be_empty
        end
        
      end

    end

    describe "#translate" do

      it "should translate definition" do
        # given
        Mapper.reset
        Mapper.load_str(@define_pmy)
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
      
    end 

    describe "#translate_namespace" do

      it "should translate definition" do
        # given
        Mapper.reset
        Mapper.load_str(@namespace_pmy)
        hash = {:name => {:first => "Sherlock", :last => "Holmes"}}

        # expect
        Mapper.translate_namespace(:foo, :bar, hash).to_s.should == <<-EOX
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
