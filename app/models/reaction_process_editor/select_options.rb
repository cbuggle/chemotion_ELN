# frozen_string_literal: true

require 'singleton'

module ReactionProcessEditor
  class SelectOptions
    include Singleton
    # This is just hardcoded definining the available equipment (in the RPE UI) depending on action type.
    # These are subsets of OrdKit::Equipment::EquipmentType. It's important to use only constants fron
    # the ORD (else ORD export will eventually write 'UNSEPCIFIED').
    #
    # We define this backend as some of it is retrieved directly from ORD constants which are unknown in RPE UI.

    def all_ord_equipment
      @all_ord_equipment ||= options_for(OrdKit::Equipment::EquipmentType.constants)
    end

    def action_type_equipment
      @action_type_equipment ||= {
        ADD: all_ord_equipment,
        SAVE: [],
        TRANSFER: [],
        CONDITION: {
          EQUIPMENT: all_ord_equipment,
          TEMPERATURE: temperature_equipment_options,
          PH: ph_adjust_equipment_options,
          PRESSURE: options_for(['REACTOR']),
          IRRADIATION: options_for(OrdKit::IlluminationConditions::IlluminationType.constants),
          MOTION: options_for(%w[STIRRER SHAKER HEATING_SHAKER TUBE BALL_MILLING]),
        },
        REMOVE: options_for(%w[PUMP TUBE COIL]),
        PURIFY: options_for(%w[FILTER SEPARATION_FILTER EXTRACTOR SPE_COLUMN FSPE_COLUMN
                               FLASH_COLUMN DISTILLATION_APPARATUS SEPARATION_FUNNEL BUCHNER_FUNNEL]),
      }.deep_stringify_keys
    end

    def global_default_conditions
      # Hardcoded Default conditions are stored backend as we enable user- and reaction specific
      # conditions. Conveniently sort of misplaced in "SelectOptions".
      @global_default_conditions ||= {
        TEMPERATURE: { value: '21', unit: 'CELSIUS', additional_information: '' },
        PRESSURE: { value: '1013', unit: 'MBAR' },
        PH: { value: 7, unit: 'PH', additional_information: '' },
      }.deep_stringify_keys
    end

    def addition_speed_type
      @addition_speed_type ||= options_for(OrdKit::ReactionInput::AdditionSpeed::AdditionSpeedType.constants)
    end

    def preparation_types
      @preparation_types ||= options_for(%w[DISSOLVED HOMOGENIZED TEMPERATURE_ADJUSTED
                                            DEGASSED]) + [{ value: 'DRIED', label: 'Drying' }]
    end

    private

    # options for can be used where all value.to_titlecase yields a useful label (e.g. DISSOLVED -> Dissolved)
    # but some dont't which we then need to define explizitly hardcoded.
    def options_for(string_array)
      string_array.map do |string|
        { value: string.to_s, label: string.to_s.titlecase }
      end
    end

    def temperature_equipment_options
      [{ label: 'Unspecified', value: 'UNSPECIFIED' },
       { label: 'Custom', value: 'CUSTOM' },
       { label: 'Room Temperature', value: 'AMBIENT' },
       { label: 'Temp of Oil Bath', value: 'OIL_BATH' },
       { label: 'Water Bath', value: 'WATER_BATH' },
       { label: 'Sand Bath', value: 'SAND_BATH' },
       { label: 'Ice Bath', value: 'ICE_BATH' },
       { label: 'Dry Aluminium Plate', value: 'DRY_ALUMINUM_PLATE' },
       { label: 'Microwave', value: 'MICROWAVE' },
       { label: 'Dry Ice Bath', value: 'DRY_ICE_BATH' },
       { label: 'Air Fan', value: 'AIR_FAN' },
       { label: 'Liquid Nitrogen', value: 'LIQUID_NITROGEN' },
       { label: 'Measurement in Reaction', value: 'MEASUREMENT_IN_REACTION' },
       { label: 'Temp of other contact Media', value: 'CONTACT_MEDIUM' }]
    end

    def ph_adjust_equipment_options
      [{ label: 'pH Electrode', value: 'PH_ELECTRODE' },
       { label: 'pH Stripe', value: 'PH_STRIPE' },
       { label: 'Other', value: 'PH_OTHER' }]
    end
  end
end
