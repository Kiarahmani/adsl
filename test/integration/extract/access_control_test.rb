require 'minitest/unit'
require 'minitest/autorun'
require 'adsl/extract/bin'
require 'adsl/extract/rails/rails_instrumentation_test_case'
require 'adsl/util/test_helper'

class ADSL::Extract::AccessControlRailsVerificationTest < ADSL::Extract::Rails::RailsInstrumentationTestCase
  include ADSL::Extract::Bin
  
  def setup
    super
    define_cancan_suite
    Ability.class_exec do
      def initialize(user)
        if user.is_admin
          can :manage, :all
        else
          can :manage, Asd, :user_id => user.id
          can :manage, User, :user_id => user.id
        end
      end
    end
  end

  def verify_options_for(action)
    {
      :output => :silent,
      :check_satisfiability => false,
      :halt_on_error => true,
      :timeout => 40,
      :action => action
    }
  end

  def test_verify__create_not_allowed_by_ability
    AsdsController.class_exec do
      def create
        Asd.new
      end
    end
    
    ast = create_rails_extractor.adsl_ast

    assert_false verify :ast => ast, :verify_options => verify_options_for('AsdsController__create')
  end
  
  def test_verify__create_not_allowed_by_ability_but_checked
    AsdsController.class_exec do
      def create
        raise unless can?(:create, Mod::Blah)
        Mod::Blah.new
      end
    end
    
    ast = create_rails_extractor.adsl_ast

    assert verify :ast => ast, :verify_options => verify_options_for('AsdsController__create')
  end
  
  def test_verify__create_allowed_by_dumb_cancan_check
    AsdsController.class_exec do
      def create
        # this check passes because this is a class-level check
        raise unless can? :create, Asd
        Asd.new
      end
    end
    
    ast = create_rails_extractor.adsl_ast

    assert_false verify :ast => ast, :verify_options => verify_options_for('AsdsController__create')
  end

  def test_verify__dereference_in_permission
    AsdsController.class_exec do
      def destroy
        current_user.asds.delete_all
      end
    end
    
    ast = create_rails_extractor.adsl_ast

    assert verify :ast => ast, :verify_options => verify_options_for('AsdsController__destroy')
  end

end
