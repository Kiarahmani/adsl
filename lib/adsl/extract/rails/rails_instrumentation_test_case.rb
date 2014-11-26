require 'minitest/unit'
require 'minitest/autorun'
require 'adsl/util/test_helper'
require 'adsl/extract/rails/active_record_metaclass_generator'
require 'adsl/extract/rails/rails_test_helper'

class ADSL::Extract::Rails::RailsInstrumentationTestCase < MiniTest::Unit::TestCase
  def setup
    assert_false class_defined? :ADSLMetaAsd, :ADSLMetaKme, 'Mod::ADSLMetaBlah'
    initialize_test_context
  end

  def teardown
    unload_class :Asd, :Kme, 'Mod::Blah'
  end

  def initialize_metaclasses
    ADSL::Extract::Rails::ActiveRecordMetaclassGenerator.new(Asd).generate_class
    ADSL::Extract::Rails::ActiveRecordMetaclassGenerator.new(Kme).generate_class
    ADSL::Extract::Rails::ActiveRecordMetaclassGenerator.new(Mod::Blah).generate_class
  end

  def create_rails_extractor(invariant_string = '')
    ADSL::Extract::Rails::RailsExtractor.new :ar_classes => ar_classes, :invariants => invariant_string
  end
  
  def ar_class_names
    ['Asd', 'Kme', 'Mod::Blah']
  end

  def ar_classes
    ar_class_names.map(&:constantize)
  end
end
