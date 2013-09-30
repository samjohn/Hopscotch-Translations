require 'spec_helper'

describe ForeignWord do

  describe "localizable_string" do
    context "the word is translated" do
      it "should return the correct string" do
        foreign_word = ForeignWord.new(translatable_string: "Foo",
                                       translated_string: "Bar")
        expected_string = "\"Foo\" = \"Bar\";"
        expect(foreign_word.localizable_string).to eq(expected_string)
      end
    end

    context "the word has not been translated" do
      it "should return an empty string" do
        foreign_word = ForeignWord.new(translatable_string: "Foo")
        expect(foreign_word.localizable_string).to eq("")
      end
    end
  end

  describe "gengo_hash" do
    it "should create the correct hash" do
      language = "cs"
      word = "foo"
      comment = "bar"
      foreign_word = ForeignWord.new(translatable_string: word, language: language)
      foreign_word.better_receive(:comment).and_return(comment)

      hash = {
        type: "text",
        slug: language,
        comment: comment,
        body_src: word,
        lc_src: "en",
        lc_tgt: language,
        tier: "standard",
        auto_approve: 1
      }

      expect(foreign_word.gengo_hash).to eq(hash)
    end
  end

  describe "needs_translation_job?" do
    context "there is a gengo job already associated" do
      it "should return false" do
        foreign_word = ForeignWord.new(translatable_string: "foo", language:"cs")
        foreign_word.gengo_job = GengoJob.new

        expect(foreign_word.needs_translation_job?).to be_false
      end
    end

    context "there is no gengo job" do
      let(:foreign_word) { ForeignWord.new(translatable_string: "oooo", language:"cs") }

      it "should return true" do
        expect(foreign_word.needs_translation_job?).to be_true
      end

      context "the word to translate is too short" do
        it "should return false" do
          foreign_word.translatable_string = "."
          expect(foreign_word.needs_translation_job?).to be_false
        end
      end
    end
  end
end
