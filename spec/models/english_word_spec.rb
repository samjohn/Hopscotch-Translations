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

  describe ".create_word_from_line" do
    it "should take the first set of words rather than the second" do
      line = "/* Please leave in the \\n (and don't add any spaces!) it will be replaced with a line break. Also leave in the %@, it will be replaced with the proper url and email so that the final text will read: You can see or delete your data any time, just email us at: privacy@gethopscotch.com. Your parents can read more here: https://gethopscotch.com/privacy-policy */\" • At Hopscotch, you are in charge of your data. This includes your username, your code and how you use the app\\n• You can see or delete your data at any time. Just email us at %@\\n• You and your parents can get more details here: %@\" = \" • At Hopscotch, you are in charge of your data. This includes your username, your code and how you use the app\\n• You can see or delete your data at any time. Just email us at %1$@\\n• You and your parents can get more details here: %2$@\""
      EnglishWord.create_word_from_line(line)
      word = EnglishWord.last
      expect(word.translatable_string).to eq(" • At Hopscotch, you are in charge of your data. This includes your username, your code and how you use the app\\n• You can see or delete your data at any time. Just email us at %@\\n• You and your parents can get more details here: %@")
    end
  end
end
