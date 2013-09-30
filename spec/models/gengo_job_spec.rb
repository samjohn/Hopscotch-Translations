require 'spec_helper'

describe GengoJob do
  let(:job) { GengoJob.create(job_id: "401936", status: GengoJob::STATUS_APPROVED) }

  describe "sync_with_gengo_and_foreign_word" do
    let(:gengo) { GENGO_SANDBOX }
    let(:translatable_string) { "Variables" }
    let(:translated_string) { "Variables Translation" }

    let(:job_response) {
      {"opstat"=>"ok",
       "response"=>
       {"job"=>
        {"job_id"=>"401936",
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
        job.sync_with_gengo_and_foreign_word(gengo)
        job.reload.status.should == GengoJob::STATUS_AVAILABLE
      end

      context "foreign word does not exist" do
        it "should create a new foreign word" do
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
            expect(foreign_word).to be_persisted
            job.sync_with_gengo_and_foreign_word(gengo)
            expect(job.reload.foreign_word).to eq(foreign_word)
          end
        end
      end

      it "should not set the job to completed at the end" do
        job.sync_with_gengo_and_foreign_word(gengo)
        expect(job.reload.completed).to be_false
      end
    end

    context "job is approved" do
      before do
        job_response["response"]["job"]["status"] = GengoJob::STATUS_APPROVED
        job_response["response"]["job"]["body_tgt"] = translated_string

        gengo.better_receive("getTranslationJob").
          with(id: job.job_id).
          and_return(job_response)
      end

      it "should set the job to completed at the end" do
        job.sync_with_gengo_and_foreign_word(gengo)
        expect(job.reload.completed).to be_true
      end
    end
  end

end
