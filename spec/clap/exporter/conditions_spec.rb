# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clap condition exporters' do
  before do
    ReactionProcessEditor::Ontology.create!(
      ontology_id: 'NCIT:C70669',
      label: 'Automation',
      name: 'Automation mode',
    )
  end

  describe Clap::Exporter::Conditions::ReactionConditionsExporter do
    it 'exports populated condition controls' do
      conditions = described_class.new(
        {
          'TEMPERATURE' => { 'value' => '21', 'unit' => 'CELSIUS', 'additional_information' => 'AMBIENT' },
          'PRESSURE' => { 'value' => '1013', 'unit' => 'MBAR' },
          'PH' => { 'value' => '7', 'additional_information' => 'PH_ELECTRODE' },
          'MOTION' => { 'motion_type' => 'STIR_BAR', 'speed' => { 'value' => '350' }, 'motion_mode' => 'NCIT:C70669' },
          'IRRADIATION' => {
            'value' => '365',
            'unit' => 'NM',
            'additional_information' => 'LED',
            'power' => { 'value' => '10', 'unit' => 'WATT' },
            'power_is_ramp' => true,
            'power_end' => { 'value' => '20', 'unit' => 'WATT' },
          },
          'WAVELENGTHS' => { 'is_range' => true, 'peaks' => [{ 'value' => '365', 'unit' => 'NM' }] },
          'MS_PARAMETER' => 'scan range',
        },
      ).to_clap

      expect(conditions.to_h).to include(
        temperature_control: { temperature: { value: 21.0, unit: :CELSIUS }, temperature_control_type: :AMBIENT },
        pressure_control: { pressure: { value: 1013.0, unit: :MBAR } },
        ph_control: { ph: 7.0, measurement_type: :PH_ELECTRODE },
        motion_control: {
          type: :STIR_BAR,
          speed: { value: 350.0, unit: :RPM },
          motion_mode: { id: 'NCIT:C70669', label: 'Automation', name: 'Automation mode' },
        },
        irradiation_control: {
          type: :LED,
          peak_wavelength: { value: 365.0, unit: :NANOMETER },
          power: { value: 10.0, unit: :WATT },
          power_is_ramp: true,
          power_end: { value: 20.0, unit: :WATT },
        },
        wavelengths: { is_range: true, peaks: [{ value: 365.0, unit: :NANOMETER }] },
        generic: [{ name: 'MS_PARAMETER', conditions: 'scan range' }],
      )
    end

    it 'returns nil without condition workup' do
      expect(described_class.new(nil).to_clap).to be_nil
    end
  end

  describe Clap::Exporter::Conditions::PressureControlExporter do
    it 'omits blank pressure values' do
      expect(described_class.new({ 'value' => '', 'unit' => 'MBAR' }).to_clap.pressure).to be_nil
    end
  end

  describe Clap::Exporter::Conditions::TemperatureControlExporter do
    it 'falls back for unknown temperature control types' do
      control = described_class.new({ 'value' => '21', 'unit' => 'CELSIUS', 'additional_information' => 'bad' }).to_clap

      expect(control.temperature_control_type).to eq(:UNSPECIFIED)
    end
  end

  describe Clap::Exporter::Conditions::ReactionConditionLimitsExporter do
    it 'exports duration and nested conditions' do
      limits = described_class.new(
        {
          'duration' => 30_000,
          'TEMPERATURE' => { 'value' => '40', 'unit' => 'CELSIUS', 'additional_information' => 'OIL_BATH' },
        },
      ).to_clap

      expect(limits.to_h).to eq(
        duration: { value: 30.0, unit: :SECOND },
        conditions: {
          temperature_control: {
            temperature: { value: 40.0, unit: :CELSIUS },
            temperature_control_type: :OIL_BATH,
          },
        },
      )
    end
  end
end
