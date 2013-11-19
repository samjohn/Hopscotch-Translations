require "spec_helper"

describe EnglishWord do
  describe ".delete_all_app_strings" do
    it "should only delete strings where non_app_string is not true" do
      app_string = "foo"
      english = EnglishWord.create("translatable_string" => app_string)

      non_localizable_string = "Dismiss"
      english_non_localizable = EnglishWord.create("translatable_string" => non_localizable_string, non_app_string: true)

      expect(EnglishWord.count).should eq(2)

      EnglishWord.delete_all_app_strings

      expect(EnglishWord.count).should eq(1)
      expect(english_non_localizable.reload).to be
    end
  end
end
