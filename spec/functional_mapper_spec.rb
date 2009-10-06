require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Ptolemy

  describe "Mapper" do

    describe "#load" do

      context "if definition is namespaced" do

        it "should create namespaced definitions" do
          Mapper.reset
          Mapper.load_str(NAMESPACED_DEFINITION)
          Mapper.namespaces.should_not be_empty
        end

      end 

      context "if definition is not namespaced" do

        it "should create non-namespaced definitions" do
          Mapper.load_str(DEFINITION)
          Mapper.definitions.should_not be_empty
        end
        
      end

    end

    describe "#translate" do

      it "should translate definition" do
        # given
        Mapper.reset
        Mapper.load_str(DEFINITION)
        hash = {:name => {:first => "Sherlock", :last => "Holmes"}}

        # expect
        Mapper.translate(:contact, hash).to_s.should == <<-EOX
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
          Mapper.load_str(NAMESPACED_DEFINITION)
          hash = {:name => {:first => "Sherlock", :last => "Holmes"}}

          # expect
          Mapper[:event].translate(:contact, hash).to_s.should == <<-EOX
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
          Mapper.load_str(NESTED_NAMESPACED_DEFINITION)
          hash = {:name => {:first => "Sherlock", :last => "Holmes"}}

          # expect
          Mapper[:event][:contact].translate(:personal, hash).to_s.should == <<-EOX
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
