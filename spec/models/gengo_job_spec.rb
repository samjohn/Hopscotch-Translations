require 'spec_helper'

describe GengoJob do
  let(:job) { GengoJob.create(job_id: job_id, status: GengoJob::STATUS_APPROVED) }
  let(:job_id) { "401936" }
  let(:getTranslationJob) { "getTranslationJob" }

  describe "sync_with_gengo_and_foreign_word" do
    let(:gengo) { GENGO_SANDBOX }
    let(:translatable_string) { "Variables" }
    let(:translated_string) { "Variables Translation" }

    let(:job_response) {
      {"opstat"=>"ok",
       "response"=>
       {"job"=>
        {"job_id"=>job_id,
         "order_id"=>"171084",
         "slug"=>"cs",
         "body_src"=> translatable_string,
         "lc_src"=>"en",
         "lc_tgt"=>"cs",
         "unit_count"=>"1",
         "tier"=>"standard",
         "credits"=>"0.05",
         "currency"=>"USD",
         "eta"=>25344,
         "ctime"=>1380571437,
         "callback_url"=>"http://hopscotchtranslations.herokuapp.com/gengo_responses",
         "auto_approve"=>"1"}}}
    }

    before do
      EnglishWord.create(translatable_string: translatable_string, comment: "Bar")
    end

    context "job is available" do
      before do
        job_response["response"]["job"]["status"] = GengoJob::STATUS_AVAILABLE
      end

      it "should update the jobs status based on gengo" do
        gengo.better_receive(getTranslationJob).and_return(job_response)
        job.sync_with_gengo_and_foreign_word(gengo)
        job.reload.status.should == GengoJob::STATUS_AVAILABLE
      end

      context "foreign word does not exist" do
        it "should create a new foreign word" do
          gengo.better_receive(getTranslationJob).and_return(job_response)
          job.sync_with_gengo_and_foreign_word(gengo)

          foreign_word = job.reload.foreign_word
          expect(foreign_word.language).to eq("cs")
          expect(foreign_word.translatable_string).to eq(translatable_string)
          expect(foreign_word.translated_string).to be_nil
          expect(foreign_word.gengo_job).to eq(job)
        end
      end

      context "foreign word exists" do
        let(:foreign_word) {
          ForeignWord.create(translatable_string: translatable_string, language: "cs")
        }

        context "there is no previous job-foreign_word relationship" do
          it "should set the job's foreign word" do
            gengo.better_receive(getTranslationJob).and_return(job_response)
            expect(foreign_word).to be_persisted
            job.sync_with_gengo_and_foreign_word(gengo)
            expect(job.reload.foreign_word).to eq(foreign_word)
          end
        end
      end

      it "should not set the job to completed at the end" do
        gengo.better_receive(getTranslationJob).and_return(job_response)
        job.sync_with_gengo_and_foreign_word(gengo)
        expect(job.reload.completed).to be_false
      end
    end

    context "job is approved" do
      before do
        job_response["response"]["job"]["status"] = GengoJob::STATUS_APPROVED
        job_response["response"]["job"]["body_tgt"] = translated_string

        gengo.better_receive("getTranslationJob").
          with(id: job_id).
          and_return(job_response)
      end

      it "should set the job to completed at the end" do
        job.sync_with_gengo_and_foreign_word(gengo)
        expect(job.reload.completed).to be_true
      end

      it "should update the foreign word translated string" do
        job.sync_with_gengo_and_foreign_word(gengo)
        foreign_word = job.reload.foreign_word
        expect(foreign_word.translated_string).to eq(translated_string)
      end

    end
  end

  describe "sync_with_foreign_word" do
    let(:gengo) { GENGO_SANDBOX }
    let(:translatable_string) { "Variables" }
    let(:translated_string) { "Variables Translation" }
    let(:language) { "es" }

    let(:job_response) {
      {"opstat"=>"ok",
       "response"=>
       {"job"=>
        {"job_id"=> job_id,
         "order_id"=>"171084",
         "slug"=>"cs",
         "body_src"=> translatable_string,
         "body_tgt"=> translated_string,
         "lc_src"=>"en",
         "lc_tgt"=>language,
         "unit_count"=>"1",
         "tier"=>"standard",
         "credits"=>"0.05",
         "currency"=>"USD",
         "eta"=>25344,
         "ctime"=>1380571437,
         "callback_url"=>"http://hopscotchtranslations.herokuapp.com/gengo_responses",
         "auto_approve"=>"1"}}}
    }

    before do
      EnglishWord.create(translatable_string: translatable_string, comment: "Bar")
    end

    context "the job has not matched with a foreign word" do
      before do
        gengo.better_receive(:getTranslationJob).with(id: job_id).and_return(job_response)
      end

      it "should pull down its data and find a foreign word to match" do
        foreign_word = ForeignWord.create(translatable_string: translatable_string, language: language)
        job.sync_with_foreign_word(gengo)

        expect(job.reload.foreign_word).to eq(foreign_word)
        expect(foreign_word.reload.translated_string).to eq(translated_string)

      end
    end

    context "the job has matched up with a foreign word" do
      context "the foreign word is untranslated" do
        before do
          gengo.better_receive(:getTranslationJob).with(id: job_id).and_return(job_response)
        end

        it "should update that foreign word's translated string" do
          foreign_word = ForeignWord.create(translatable_string: translatable_string, language: language)
          foreign_word.gengo_job = job
          foreign_word.save
          expect(foreign_word.translated_string).to be_nil

          job.sync_with_foreign_word(gengo)

          expect(foreign_word.translated_string).to eq(translated_string)
        end
      end

      context "the foreign word is translated" do
        before do
          gengo.should_not_receive(:getTranslationJob).with(id: job_id)
        end

        it "should update that foreign word's translated string" do
          foreign_word = ForeignWord.create(translatable_string: translatable_string, language: language)
          foreign_word.translated_string = "foo"
          foreign_word.gengo_job = job
          foreign_word.save
          expect(foreign_word.translated_string).to eq("foo")

          job.sync_with_foreign_word(gengo)

          expect(foreign_word.translated_string).to eq("foo")
        end
      end
    end
  end

end
