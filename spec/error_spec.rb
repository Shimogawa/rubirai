# frozen_string_literal: true

require 'spec_helper'

describe 'errors' do
  it 'should create RubiraiError with specific message' do
    expect { raise Rubirai::RubiraiError, 'message' }
      .to raise_error(Rubirai::RubiraiError, 'message') do |err|
      expect(err).to be_a_kind_of(RuntimeError)
    end
  end

  it 'should create HttpResponseError with specific message' do
    expect { raise Rubirai::HttpResponseError, '404' }.to raise_error(
      Rubirai::HttpResponseError,
      'Http Error: 404'
    ) do |err|
      expect(err).to be_a_kind_of(Rubirai::RubiraiError)
    end
  end

  it 'should create MiraiError with specific message' do
    expect { raise Rubirai::HttpResponseError, '404' }
      .to raise_error(Rubirai::RubiraiError, 'Http Error: 404') do |err|
      expect(err).to be_a_kind_of(Rubirai::RubiraiError)
    end
  end
end
