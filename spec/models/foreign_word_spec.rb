require 'spec_helper'

describe ForeignWord do
  describe ".create_foreign_word_from_data" do
    before do
      english = EnglishWord.create("translatable_string" => "Dismiss")
      expect(english.reload).to be
    end

    let(:line) { "\"Dismiss\" = \"Убрать\";" }
    let(:language) {"ru" }
    it "should create a foreign word based on the line in the file" do
      foreign_word = ForeignWord.create_foreign_word_from_data(line, language)
      foreign_word.reload
      expect(foreign_word.language).to eq(language)
      expect(foreign_word.translatable_string).to eq("Dismiss")
    end

    it "should create a related submission with the correct translated string" do
      foreign_word = ForeignWord.create_foreign_word_from_data(line, language)
      foreign_word.reload
      submission = foreign_word.submissions.first

      expect(submission.translated_string).to eq("Убрать")
    end
  end

  describe ".untranslated" do

    it  "should return an activeRecord::Relation" do
      expect(ForeignWord.untranslated).to be_kind_of(ActiveRecord::Relation)
    end

    context 'there are no untranslated ForeignWords' do
      it "should return an empty list" do
        expect(ForeignWord.untranslated.count).to eq(0)
      end
    end

    context 'there are untranslated ForeignWords' do
      before do
        english = EnglishWord.create("translatable_string" => "Dismiss")
        expect(english.reload).to be

        english = EnglishWord.create("translatable_string" => "second word")
        expect(english.reload).to be
      end

      let(:line) { "\"Dismiss\" = \"Убрать\";" }
      let(:language) {"ru" }

      it "should return only the foreign words without submissions" do
        foreign_word_translated = ForeignWord.create_foreign_word_from_data(line, language)
        foreign_word_untranslated = ForeignWord.create(translatable_string: "second word", language: "el")
        expect(ForeignWord.untranslated.map(&:translatable_string)).to include(foreign_word_untranslated.translatable_string)
        expect(ForeignWord.untranslated.map(&:translatable_string)).not_to include(foreign_word_translated.translatable_string)
      end
    end
  end

  describe "#translated_string" do
    before do
      english = EnglishWord.create("translatable_string" => "Baz")
      expect(english.reload).to be
    end

    context "there are no submissions related to the foreign word" do
      it "should return nil" do
        foreign_word = ForeignWord.create(:translatable_string => 'Baz', :language => 'es')
        expect(foreign_word.translated_string).to be_nil
      end
    end

    context "there is one submission" do
      it "should return the submission" do
        foreign_word = ForeignWord.create(:translatable_string => 'Baz', :language => 'es')
        s = Submission.create(:translated_string => 'Lunch', :foreign_word => foreign_word)
        expect(foreign_word.translated_string).to eq('Lunch')
      end
    end

    context "there are many submissions" do
      it "should return the most recent submission" do
        foreign_word = ForeignWord.new(:translatable_string => 'Baz', :language => 'es')
        submission1 = foreign_word.submissions.build(:translated_string => "Lunch", :created_at => 1.day.ago)
        submission2 = foreign_word.submissions.build(:translated_string => "Brunch", :created_at => Time.now)
        submission3 = foreign_word.submissions.build(:translated_string => "Dinner", :created_at => 3.days.ago)
        foreign_word.save

        expect(foreign_word.reload.translated_string).to eq('Brunch')
      end
    end
  end

  describe "translated_string=" do
    before do
      english = EnglishWord.create("translatable_string" => "Baz")
      expect(english.reload).to be
    end

    it  "should create a submission for the foreign word" do
      foreign_word = ForeignWord.new(:translatable_string => 'Baz', :language => 'es')
      foreign_word.translated_string = "Qux"
      expect(foreign_word.submissions.first.translated_string).to eq("Qux")
    end
  end

  describe "localizable_string" do
    before do
      english = EnglishWord.create("translatable_string" => "Foo")
      expect(english.reload).to be
    end

    let(:line) { "\"Foo\" = \"Bar\";" }
    let(:language) {"pt" }
    context "the word is translated" do
      it "should return the correct string" do
        foreign_word = ForeignWord.create_foreign_word_from_data(line, language)
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
        EnglishWord.create(translatable_string: foreign_word.translatable_string)
        expect(foreign_word.needs_translation_job?).to be_true

        foreign_word.gengo_job = GengoJob.new

        expect(foreign_word.needs_translation_job?).to be_false
      end
    end

    context "the word is not valid" do
      it  "should return false" do
        foreign_word = ForeignWord.new(translatable_string: "foo", language:"cs")
        expect(foreign_word.needs_translation_job?).to be_false
      end
    end

    context "there is no gengo job" do
      let(:foreign_word) { ForeignWord.new(translatable_string: "oooo", language:"cs") }

      it "should return true" do
        EnglishWord.create(translatable_string: foreign_word.translatable_string)
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
