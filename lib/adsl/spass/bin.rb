require 'tempfile'
require 'colorize'
require 'adsl/parser/adsl_parser.tab'
require 'adsl/spass/spass_ds_extensions'
require 'adsl/spass/util'
require 'adsl/util/general'
require 'adsl/util/csv_hash_formatter'

module ADSL
  module Spass
    module Bin
      include Spass::Util

      def output(term_msg, csv)
        if @verification_output == :terminal
          if term_msg
            print term_msg
            STDOUT.flush
          end
        elsif @verification_output == :csv
          @csv_output << csv if csv
        else
          raise "Unknown verification output #{@verification_output}"
        end
      end

      def filter_by_name(elems, names)
        return elems if names.nil?
        filtered = elems.select{ |elem| names.map{ |name| elem.name.include? name}.include? true }
      end

      def verify(input, options={})
        parser = ADSL::ADSLParser.new
        ds_spec = parser.parse input

        stop_on_incorrect = options[:halt_on_error]
        check_satisfiability = options[:check_satisfiability]
        timeout = options[:timeout]
        actions = filter_by_name ds_spec.actions, options[:actions]
        invariants = filter_by_name ds_spec.invariants, options[:invariants]

        @csv_output = ::Util::CSVHashFormatter.new

        @verification_output = options[:csv_output] ? :csv : :terminal
        do_stats = @verification_output == :csv

        if check_satisfiability
          begin
            output "Checking for satisfiability...", nil
            
            translation = nil
            translation_time = Time.time_execution do
              translation = ds_spec.translate_action nil
            end

            result, stats = exec_spass translation, timeout, true
            if do_stats
              stats[:translation_time] = translation_time
              stats[:action] = '<unsatisfiability>'
              stats[:result] = result.to_s
            end

            if result == :correct
              output "\rSatisfiability check #{ 'failed!'.red }", stats
              return
            elsif result == :inconclusive
              output "\rSatisfiability check #{ 'unconclusive'.yellow }        ", stats
            else
              output "\rSatisfiability check #{ 'passed'.green }.         ", stats
            end
          ensure
            output "\n", nil
          end
        end

        actions.each do |action|
          invariants.each do |invariant|
            output "Verifying action '#{action.name}' with invariant '#{invariant.name}'...", nil
            begin
              translation = nil
              translation_time = Time.time_execution do
                translation = ds_spec.translate_action action.name, invariant
              end
              result, stats = exec_spass translation, timeout, true
              if do_stats
                stats[:translation_time] = translation_time
                stats[:action] = action.name
                stats[:invariant] = invariant.name
                stats[:result] = result.to_s
              end

              case result
              when :correct
                output "\rAction '#{action.name}' with invariant '#{invariant.name}': #{ 'correct'.green }     ", stats
              when :incorrect
                output "\rAction '#{action.name}' with invariant '#{invariant.name}': #{ 'incorrect'.red }     ", stats
                return if stop_on_incorrect
              when :inconclusive
                output "\rAction '#{action.name}' with invariant '#{invariant.name}': #{ 'inconclusive'.yellow } ", stats
              else
                raise "Unknown exec_spass result: #{result}"
              end
            rescue => e
              # puts translation
              raise e
            ensure
              output "\n", nil
            end
          end
        end
      ensure
        puts @csv_output.to_s if @verification_output == :csv
        @csv_output = nil
      end

      def exec_spass(spass_code, timeout=-1, include_stats = false)
        tmp_file = Tempfile.new "spass_temp"
        tmp_file.write spass_code
        tmp_file.close
        arg_combos = ["", "-Sorts=0"]
        output = process_race(*arg_combos.map{ |a| "SPASS #{a} -TimeLimit=#{timeout} #{tmp_file.path}" })
        result = /^SPASS beiseite: (.+)\.$/.match(output)[1]

        stats = include_stats ? pack_stats(spass_code, output) : nil
        verdict = nil

        case result
        when 'Proof found'
          verdict = :correct
        when 'Completion found'
          verdict = :incorrect
        else
          verdict = :inconclusive
        end
        return stats.nil? ? verdict : [verdict, stats]
      ensure
        tmp_file.delete unless tmp_file.nil?
      end

      def pack_stats(spass_code, spass_output)
        spass_output = spass_output.split("\n").last(10).join("\n")
        stats = {}
        stats[:translation_time] = nil # should be set externally

        identifiers = /predicates\s*\[([^\]]*)\]/.match(spass_code)[1].scan(/\w+/)
        stats[:spass_predicate_count] = identifiers.length

        formulae = spass_code.scan(/formula\s*\([^\.]+\)\./)
        stats[:spass_formula_count] = formulae.length
        stats[:average_formula_length] = formulae.inject(0){ |total, formula| total += formula.length} / formulae.length

        times = spass_output.scan(/(\d):(\d\d):(\d\d)\.(\d\d)/)
        raise if times.length != 6
        times = times.map{ |time| time[3].to_i*10 + time[2].to_i*1000 + time[1].to_i*60*1000 + time[0].to_i*60*60*1000 }
        stats[:spass_preparation_time] = times[1..2].sum 
        stats[:spass_proof_lookup_time] = times[3..5].sum

        stats[:proof_clause_count] = /^SPASS derived (\d+) clauses.*$/.match(spass_output)[1].to_i
        
        stats[:memory] = /^\s*SPASS allocated (\d+) KBytes.*$/.match(spass_output)[1].to_i

        stats
      end
    end
  end
end