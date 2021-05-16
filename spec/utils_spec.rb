# frozen_string_literal: true

require 'spec_helper'

describe 'errors' do
  it 'stringifies keys' do
    original = {
      a: 3,
      b: 4,
      'c' => 5,
      D: 6
    }
    expected = {
      'a' => 3,
      'b' => 4,
      'c' => 5,
      'D' => 6
    }
    expect(original.stringify_keys).to eq(expected)

    original.stringify_keys!

    expect(original).to eq(expected)
  end

  it 'symbolizes keys' do
    original = {
      'a' => 3,
      'b' => 4,
      :c => 5,
      'D' => 6,
      :E => 7
    }
    expected = {
      a: 3,
      b: 4,
      c: 5,
      D: 6,
      E: 7
    }

    expect(original.symbolize_keys).to eq(expected)

    original.symbolize_keys!

    expect(original).to eq(expected)
  end

  it 'transforms to camel case' do
    expect('SnakE_cAsE'.snake_to_camel).to eq('SnakeCase')
    expect('SnakE_cAsE'.snake_to_camel(lower: true)).to eq('snakeCase')

    expect('cat'.snake_to_camel).to eq('Cat')
    expect('cAT'.snake_to_camel).to eq('Cat')
    expect('CaT'.snake_to_camel).to eq('Cat')
    expect('cat'.snake_to_camel(lower: true)).to eq('cat')
    expect('cAT'.snake_to_camel(lower: true)).to eq('cat')
    expect('CaT'.snake_to_camel(lower: true)).to eq('cat')
  end

  it 'checks type' do
    expect { 'cat'.must_be! String }.not_to raise_error
    expect { { a: 3 }.must_be! [Array, Hash] }.not_to raise_error
    expect { 'cat'.must_be! Array }.to raise_error(RuntimeError, 'assert failed: `cat\' must be of type Array')
    expect do
      'cat'.must_be! [Array, Hash]
    end.to raise_error(RuntimeError, 'assert failed: `cat\' must be of type [Array, Hash]')
    expect { 'cat'.must_be! Array, ArgumentError, 'argument error' }.to raise_error(ArgumentError, 'argument error')
  end
end
