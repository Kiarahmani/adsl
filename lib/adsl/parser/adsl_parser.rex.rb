#--
# DO NOT MODIFY!!!!
# This file is automatically generated by rex 1.0.5
# from lexical definition file "./lib/adsl/parser/adsl_parser.rex".
#++

require 'racc/parser'
require 'adsl/parser/ast_nodes'
require 'adsl/util/numeric_extensions'

class ADSL::Parser::ADSLParser < Racc::Parser
  require 'strscan'

  class ScanError < StandardError ; end

  attr_reader   :lineno
  attr_reader   :filename
  attr_accessor :state

  def scan_setup(str)
    @ss = StringScanner.new(str)
    @lineno =  1
    @state  = nil
  end

  def action
    yield
  end

  def scan_str(str)
    scan_setup(str)
    do_parse
  end
  alias :scan :scan_str

  def load_file( filename )
    @filename = filename
    open(filename, "r") do |f|
      scan_setup(f.read)
    end
  end

  def scan_file( filename )
    load_file(filename)
    do_parse
  end


  def next_token
    return if @ss.eos?
    
    # skips empty actions
    until token = _next_token or @ss.eos?; end
    token
  end

  def _next_token
    text = @ss.peek(1)
    @lineno  +=  1  if text == "\n"
    token = case @state
    when nil
      case
      when (text = @ss.scan(/\/\/[^\n\z]*/))
        ;

      when (text = @ss.scan(/\#[^\n\z]*/))
        ;

      when (text = @ss.scan(/\/\*(?:[^\*]*(?:\*+[^\/]+)?)*\*\//))
        ;

      when (text = @ss.scan(/authenticable\b/))
         action { [:authenticable, lineno] }

      when (text = @ss.scan(/usergroup\b/))
         action { [:usergroup, lineno] }

      when (text = @ss.scan(/class\b/))
         action { [:class, lineno] }

      when (text = @ss.scan(/extends\b/))
         action { [:extends, lineno] }

      when (text = @ss.scan(/inverseof\b/))
         action { [:inverseof, lineno] }

      when (text = @ss.scan(/create\b/))
         action { [:create, lineno] }

      when (text = @ss.scan(/derefcreate\b/))
         action { [:derefcreate, lineno] }

      when (text = @ss.scan(/delete\b/))
         action { [:delete, lineno] }

      when (text = @ss.scan(/foreach\b/))
         action { [:foreach, lineno] }

      when (text = @ss.scan(/flatforeach\b/))
         action { [:flatforeach, lineno] }

      when (text = @ss.scan(/unflatforeach\b/))
         action { [:unflatforeach, lineno] }

      when (text = @ss.scan(/currentuser\b/))
         action { [:currentuser, lineno] }

      when (text = @ss.scan(/inusergroup\b/))
         action { [:inusergroup, lineno] }

      when (text = @ss.scan(/allofusergroup\b/))
         action { [:allofusergroup, lineno] }

      when (text = @ss.scan(/foreach\b/))
         action { [:foreach, lineno] }

      when (text = @ss.scan(/either\b/))
         action { [:either, lineno] }

      when (text = @ss.scan(/if\b/))
         action { [:if, lineno] }

      when (text = @ss.scan(/else\b/))
         action { [:else, lineno] }

      when (text = @ss.scan(/action\b/))
         action { [:action, lineno] }

      when (text = @ss.scan(/or\b/))
         action { [:or, lineno] }

      when (text = @ss.scan(/subset\b/))
         action { [:subset, lineno] }

      when (text = @ss.scan(/oneof\b/))
         action { [:oneof, lineno] }

      when (text = @ss.scan(/tryoneof\b/))
         action { [:tryoneof, lineno] }

      when (text = @ss.scan(/allof\b/))
         action { [:allof, lineno] }

      when (text = @ss.scan(/forall\b/))
         action { [:forall, lineno] }

      when (text = @ss.scan(/exists\b/))
         action { [:exists, lineno] }

      when (text = @ss.scan(/in\b/))
         action { [:in, lineno] }

      when (text = @ss.scan(/invariant\b/))
         action { [:invariant, lineno] }

      when (text = @ss.scan(/rule\b/))
         action { [:roole, lineno] }

      when (text = @ss.scan(/true\b/))
         action { [:true, lineno] }

      when (text = @ss.scan(/false\b/))
         action { [:false, lineno] }

      when (text = @ss.scan(/!=/))
         action { [text, lineno] }

      when (text = @ss.scan(/(?:!|not)\b/))
         action { [:not, lineno] }

      when (text = @ss.scan(/and\b/))
         action { [:and, lineno] }

      when (text = @ss.scan(/equal\b/))
         action { [:equal, lineno] }

      when (text = @ss.scan(/empty\b/))
         action { [:empty, lineno] }

      when (text = @ss.scan(/isempty\b/))
         action { [:isempty, lineno] }

      when (text = @ss.scan(/implies\b/))
         action { [:implies, lineno] }

      when (text = @ss.scan(/unknown\b/))
         action { [:unknown, lineno] }

      when (text = @ss.scan(/permit\b/))
         action { [:permit, lineno] }

      when (text = @ss.scan(/read\b/))
         action { [:read, lineno] }

      when (text = @ss.scan(/edit\b/))
         action { [:edit, lineno] }

      when (text = @ss.scan(/assoc\b/))
         action { [:assoc, lineno] }

      when (text = @ss.scan(/deassoc\b/))
         action { [:deassoc, lineno] }

      when (text = @ss.scan(/\.\./))
         action { [text, lineno] }

      when (text = @ss.scan(/[{}:\(\)\.,]/))
         action { [text, lineno] }

      when (text = @ss.scan(/\+=/))
         action { [text, lineno] }

      when (text = @ss.scan(/\-=/))
         action { [text, lineno] }

      when (text = @ss.scan(/==/))
         action { [text, lineno] }

      when (text = @ss.scan(/<=>/))
         action { [text, lineno] }

      when (text = @ss.scan(/<=/))
         action { [text, lineno] }

      when (text = @ss.scan(/=>/))
         action { [text, lineno] }

      when (text = @ss.scan(/=/))
         action { [text, lineno] }

      when (text = @ss.scan(/\+/))
         action { [text, lineno] }

      when (text = @ss.scan(/\*/))
         action { [text, lineno] }

      when (text = @ss.scan(/[0-9]+(?:\.[0-9]+)?/))
         action { [:NUMBER, { :value => text.to_f,   :lineno => lineno }] }

      when (text = @ss.scan(/((?<![\\])['"])((?:.(?!(?<![\\])\1))*.?)\1/))
         action { [:STRING, { :value => text[1..-2], :lineno => lineno }] }

      when (text = @ss.scan(/(?:int|string|real|decimal|bool)\b/))
         action { [:BASIC_TYPE, [text, lineno]] }

      when (text = @ss.scan(/`(?:[^\\]*(?:\\[^`])?)*`/))
         action { [:JS, {:js => text, :lineno => lineno}] }

      when (text = @ss.scan(/\w+/))
         action { [:IDENT, ADSL::Parser::ASTIdent.new(:lineno => lineno, :text => text)] }

      when (text = @ss.scan(/\s/))
        ;

      when (text = @ss.scan(/./))
         action { [:unknown_symbol, [text, lineno]] }

      else
        text = @ss.string[@ss.pos .. -1]
        raise  ScanError, "can not match: '" + text + "'"
      end  # if

    else
      raise  ScanError, "undefined state: '" + state.to_s + "'"
    end  # case state
    token
  end  # def _next_token

end # class
