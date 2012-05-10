require 'spec_helper'
require 'parsers/java'

module Jockey
  module Parsers
    describe Java do
      it 'extracts inline comments' do
        code = <<-ECODE
          class Foo extends Boo {
            //very helpful comment
            public static void trololo(String moo) {
              System.out.println("Trololo");
            }
          }
        ECODE

        java = Java.new(code)
        java.comments.should match_source_code "very helpful comment"
        java.code.should match_source_code(<<-SOURCE)
          class Foo extends Boo {
            //
            public static void trololo(String moo) {
              System.out.println("Trololo");
            }
          }
        SOURCE
      end

      it 'separates inline comments from code' do
        code = <<-ECODE
          class Foo extends Boo {
            public static void trololo(String moo) {
              System.out.println("Trololo"); //very helpful comment
            }
          }
        ECODE

        java = Java.new(code)
        java.comments.should match_source_code("very helpful comment")
        java.code.should match_source_code(<<-SOURCE)
          class Foo extends Boo {
            public static void trololo(String moo) {
              System.out.println("Trololo"); //
            }
          }
        SOURCE
      end

      it 'extracts multiline comments' do
        code = <<-ECODE
          class Foo extends Boo {
            /*
            * very helpful
            */
            public static void trololo(String moo) {
              System.out.println("Trololo");
            }
          }
        ECODE

        java = Java.new(code)
        java.comments.should match_source_code("* very helpful */")
        java.code.should == <<-SOURCE
          class Foo extends Boo {
            /*
            public static void trololo(String moo) {
              System.out.println("Trololo");
            }
          }
        SOURCE
      end

      it 'extracts multiline comments camouflaged as a single line comment' do
        code = <<-ECODE
          class Foo extends Boo {
            /* very helpful */
            public static void trololo(String moo) {
              System.out.println("Trololo");
            }
          }
        ECODE

        java = Java.new(code)
        java.comments.should match_source_code("very helpful */")
        java.code.should == <<-SOURCE
          class Foo extends Boo {
            /*
            public static void trololo(String moo) {
              System.out.println("Trololo");
            }
          }
        SOURCE
      end

      it 'extracts javacode comments' do
        code = <<-ECODE
          class Foo extends Boo {
            /**
            * Very helpful.
            *
            * @return String buffalo
            */
            public static void trololo(String moo) {
              System.out.println("Trololo");
            }
          }
        ECODE

        java = Java.new(code)
        java.comments.should match_source_code(<<-COMMENTS)
            *
            * Very helpful.
            *
            * @return String buffalo
            */
        COMMENTS
        java.code.should == <<-SOURCE
          class Foo extends Boo {
            /*
            public static void trololo(String moo) {
              System.out.println("Trololo");
            }
          }
        SOURCE
      end

      it 'extracts multiple comment types' do
        code = <<-ECODE
          class Foo extends Boo {
            /*
            * Very helpful.
            */
            public static void trololo(String moo) {
              System.out.println("Trololo"); //this explains everything
            }
          }
        ECODE

        java = Java.new(code)
        java.comments.should match_source_code("* Very helpful. */this explains everything")
        java.code.should match_source_code(<<-SOURCE)
          class Foo extends Boo {
            /*
            public static void trololo(String moo) {
              System.out.println("Trololo"); //
            }
          }
        SOURCE
      end

      it 'is not confused by a string that looks like a comment' do
        code = <<-ECODE
          class Foo extends Boo {
            public static void trololo(String moo) {
              System.out.println("/* trololo */");
            }
          }
        ECODE

        java = Java.new(code)
        java.comments.should == ""
        java.code.should == <<-SOURCE
          class Foo extends Boo {
            public static void trololo(String moo) {
              System.out.println("/* trololo */");
            }
          }
        SOURCE
      end

      it 'is not confused by an escaped end of string with a comment' do
        code = <<-ECODE
          System.out.println(" hoho \\" /* trololo */");
        ECODE

        java = Java.new(code)
        java.comments.should == ""
        java.code.should == <<-SOURCE
          System.out.println(" hoho \\" /* trololo */");
        SOURCE
      end
    end
  end
end
