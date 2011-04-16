require 'spec_helper'

describe "Resque Extensions" do
  before do
    ResqueSpec.reset!
  end

  let(:first_name) { 'Les' }
  let(:last_name) { 'Hill' }

  describe "Resque" do
    before do
      Resque.enqueue(Person, "abc", "def")
      Resque.enqueue(Person, "xyz", "lmn")
      Resque.enqueue(Person, "xyz", "lmn")
    end

    describe "#enqueue" do

      context "queues" do
        before do
          Resque.enqueue(Person, first_name, last_name)
        end

        it "adds to the queue hash" do
          ResqueSpec.queue_for(Person).should_not be_empty
        end

        it "sets the klass on the queue" do
          ResqueSpec.queue_for(Person).last.should include(:class => Person.to_s)
        end

        it "sets the arguments on the queue" do
          ResqueSpec.queue_for(Person).last.should include(:args => [first_name, last_name])
        end
      end

      context "hooks" do
        it "calls the after_enqueue hook" do
          expect {
            Resque.enqueue(Person, first_name, last_name)
          }.to change(Person, :enqueues).by(1)
        end

        context "when inline" do
          it "calls the before_perform hook" do
            expect {
              with_resque { Resque.enqueue(Person, first_name, last_name) }
            }.to change(Person, :befores).by(1)
          end

          it "calls the around_perform hook" do
            expect {
              with_resque { Resque.enqueue(Person, first_name, last_name) }
            }.to change(Person, :befores).by(1)
          end

          it "calls the after_perform hook" do
            expect {
              with_resque { Resque.enqueue(Person, first_name, last_name) }
            }.to change(Person, :befores).by(1)
          end

          context "a failure occurs" do
            it "calls the on_failure hook" do
              expect {
                with_resque { Resque.enqueue(Place, last_name) } rescue nil
              }.to change(Place.failures, :size).by(1)
            end
          end
        end
      end
    end
  end

end
