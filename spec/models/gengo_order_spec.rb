require 'spec_helper'

describe GengoOrder do
  let(:order) {GengoOrder.create(order_id: "171084")}

  describe "update_or_create_job_with_id_and_status" do
    context "job exists" do
      it "should update the jobs status" do
        job = order.gengo_jobs.build(job_id: "job_id", status: "old_status")
        job.save

        order.update_or_create_job_with_id_and_status("job_id", "new_status")

        expect(job.reload.status).to eq("new_status")
      end
    end

    context "job does not exist" do
      it "should create a new job with the status and id" do
        expect(order.gengo_jobs.count).to eq(0)
        order.update_or_create_job_with_id_and_status("foo_job", "my_stat")

        expect(order.gengo_jobs.count).to eq(1)

        job = order.gengo_jobs.first

        expect(job.job_id).to eq("foo_job")
        expect(job.status).to eq("my_stat")
      end
    end
  end

  describe "create_jobs_from_gengo" do
    before do
      fake_gengo_order = {"opstat"=>"ok", "response"=>
      {"order"=>
       {"order_id"=>"171084",
        "total_credits"=>"6.75",
        "total_units"=>"135",
        "currency"=>"USD",
        "as_group"=>1,
        "jobs_available"=> ["401944", "401943", "401942"],
         "jobs_pending"=>[],
         "jobs_reviewable"=>[],
         "jobs_approved"=>["401936", "401935", "401934", "401933"],
         "jobs_revising"=>[],
         "jobs_queued"=>"0",
         "total_jobs"=>"42"} } }

      expect(order.gengo_jobs.count).to eq(0)
      gengo = GENGO_SANDBOX
      gengo.better_receive(:getTranslationOrderJobs).
        with(order_id: order.order_id).
        and_return(fake_gengo_order)
      order.create_jobs_from_gengo(gengo)
    end

    it "should create jobs from the gengo response" do
      expect(order.gengo_jobs.count).to eq(7)
    end

    it "should create approved jobs" do
      expect(order.gengo_jobs.approved.count).to eq(4)
    end

    it "should create " do
      expect(order.gengo_jobs.available.count).to eq(3)
    end
  end

end
