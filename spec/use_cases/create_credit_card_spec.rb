require 'rails_helper'

module Magnetik
  RSpec.describe CreateCreditCard do
    describe '#perform' do
      let(:stripe_helper) { StripeMock.create_test_helper }
      before  { StripeMock.start }
      after   { StripeMock.stop }

      before :each do
        @card_token = StripeMock.generate_card_token(last4: "9191", exp_year: 2020, exp_month: 1)
        @user = create(:user)
        @card_params = { name: 'My card' }
      end

      context 'user has a customer' do
        before :each do
          @customer = Stripe::Customer.create
          @user.update(stripe_customer_id: @customer.id)
        end

        it 'does not restrict max length' do
          old_length = Magnetik.max_name_length
          Magnetik.max_name_length = 4
          credit_card = create(:credit_card, name: '1234567890')
          credit_card.save!.tap do |success|
            expect(success).to eq(true)
          end
          Magnetik.max_name_length = old_length
        end

        it 'fetches a remote customer' do
          expect(Stripe::Customer).to receive(:retrieve) { @customer }
          CreateCreditCard.perform(@user, @card_token, @card_params)
        end

        it 'doesnt create a remote customer' do
          expect(Stripe::Customer).not_to receive(:create)
          CreateCreditCard.perform(@user, @card_token, @card_params)
        end

        it 'doesnt create a local customer' do
          expect do
            CreateCreditCard.perform(@user, @card_token, @card_params)
          end.to_not change(@user, :stripe_customer_id)
        end

        it 'creates a remote credit card' do
          @card = @customer.sources.create(:source => @card_token)

          expect(Stripe::Customer).to receive(:retrieve) { @customer }
          expect(@customer.sources).to receive(:create) { @card }

          CreateCreditCard.perform(@user, @card_token, @card_params)
        end
      end

      context 'user has no customer' do
        it 'creates a remote customer' do
          @customer = Stripe::Customer.create

          expect(Stripe::Customer).to receive(:create).with(hash_including({
            email: @user.email
          })) { @customer }

          CreateCreditCard.perform(@user, @card_token, @card_params)
        end

        it 'creates a remote customer with a nil email if the model doesnt have one' do
          @new_user = create(:customer)
          @customer = Stripe::Customer.create

          expect(Stripe::Customer).to receive(:create).with(hash_including({
            email: nil
          })) { @customer }

          CreateCreditCard.perform(@new_user, @card_token, @card_params)
        end

        it 'includes a customer description if the actor defines it' do
          @customer = Stripe::Customer.create

          expect(Stripe::Customer).to receive(:create).with(hash_including({
            description: 'Magnetik Customer'
          })) { @customer }

          CreateCreditCard.perform(@user, @card_token, @card_params)
        end

        it 'includes a nil description if the actor hasnt defined one' do
          @new_user = create(:customer)
          @customer = Stripe::Customer.create

          expect(Stripe::Customer).to receive(:create).with(hash_including({
            description: nil
          })) { @customer }

          CreateCreditCard.perform(@new_user, @card_token, @card_params)
        end

        it 'creates a local customer' do
          expect {
            CreateCreditCard.perform(@user, @card_token, @card_params)
          }.to change(@user, :stripe_customer_id)
        end

        it 'creates a remote credit card' do
          @customer = Stripe::Customer.create
          @card = @customer.sources.create(:source => @card_token)

          expect(Stripe::Customer).to receive(:create) { @customer }
          expect(@customer.sources).to receive(:create) { @card }
          CreateCreditCard.perform(@user, @card_token, @card_params)
        end
      end

      describe 'local card' do
        before do
          @t = Time.new(2015, 12, 25, 10, 30, 0)
          Timecop.freeze(@t)
        end

        after do
          Timecop.return
        end

        it 'creates a local credit card' do
          expect do
            CreateCreditCard.perform(@user, @card_token, @card_params)
          end.to change(CreditCard, :count).by(1)
        end

        it 'records the current time as the time the card was last validated' do
          @local_card = CreateCreditCard.perform(@user, @card_token, @card_params).local_card

          expect(@local_card.last_validated_at).to eq @t
        end

        it 'merges in the card params whe creating the local card' do
          @local_card = CreateCreditCard.perform(@user, @card_token, @card_params).local_card

          expect(@local_card.name).to eq('My card')
        end
      end
    end
  end
end