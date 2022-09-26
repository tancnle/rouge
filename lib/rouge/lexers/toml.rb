# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class TOML < RegexLexer
      title "TOML"
      desc 'the TOML configuration format (https://github.com/toml-lang/toml)'
      tag 'toml'

      filenames '*.toml', 'Pipfile', 'poetry.lock'
      mimetypes 'text/x-toml'

      # bare keys and quoted keys
      identifier = %r/(?:\S+|"[^"]+"|'[^']+')/

      state :basic do
        mixin :whitespace

        rule %r/(true|false)/, Keyword::Constant

        rule %r/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, Literal::Date

        rule %r/[+-]?\d+(?:_\d+)*\.\d+(?:_\d+)*(?:[eE][+-]?\d+(?:_\d+)*)?/, Num::Float
        rule %r/[+-]?\d+(?:_\d+)*[eE][+-]?\d+(?:_\d+)*/, Num::Float
        rule %r/[+-]?(?:nan|inf)/, Num::Float

        rule %r/0x\h+(?:_\h+)*/, Num::Hex
        rule %r/0o[0-7]+(?:_[0-7]+)*/, Num::Oct
        rule %r/0b[01]+(?:_[01]+)*/, Num::Bin
        rule %r/[+-]?\d+(?:_\d+)*/, Num::Integer
      end

      state :root do
        mixin :whitespace

        rule %r/(?<!=)\s*\[.*?\]+/, Name::Namespace

        mixin :key
        mixin :value
      end

      state :key do
        rule %r/(#{identifier})(\s*)(=)/ do
          groups Name::Property, Text::Whitespace, Punctuation
        end
      end

      state :value do
        # rule %r/\n/, Text, :pop!

        mixin :content
      end

      state :content do
        mixin :basic

        rule %r/"""/, Str, :mdq
        rule %r/"/, Str, :dq
        rule %r/'''/, Str, :msq
        rule %r/'/, Str, :sq
        mixin :esc_str
        rule %r/\,/, Punctuation
        rule %r/\[/, Punctuation, :array
        rule %r/\{/, Punctuation, :inline
      end

      state :dq do
        rule %r/"/, Str, :pop!
        rule %r/\n/, Error, :pop!
        mixin :esc_str
        rule %r/[^\\"\n]+/, Str
      end

      state :mdq do
        rule %r/"""/, Str, :pop!
        mixin :esc_str
        rule %r/[^\\"]+/, Str
        rule %r/"+/, Str
      end

      state :sq do
        rule %r/'/, Str, :pop!
        rule %r/\n/, Error, :pop!
        rule %r/[^'\n]+/, Str
      end

      state :msq do
        rule %r/'''/, Str, :pop!
        rule %r/[^']+/, Str
        rule %r/'+/, Str
      end

      state :esc_str do
        rule %r/\\[0t\tn\n "\\r]/, Str::Escape
      end

      state :array do
        mixin :value

        rule %r/\]/, Punctuation, :pop!
      end

      state :inline do
        mixin :key
        mixin :value

        rule %r/\}/, Punctuation, :pop!
      end

      state :whitespace do
        rule %r/\s+/, Text
        rule %r/#.*?$/, Comment
      end
    end
  end
end
