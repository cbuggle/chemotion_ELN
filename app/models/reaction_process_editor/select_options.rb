require 'singleton'

module ReactionProcessEditor
  class SelectOptions
    include Singleton
    # This is just hardcoded definining the available equipment (in the RPE UI) depending on action type.
    # These are subsets of OrdKit::Equipment::EquipmentType. It's important to use only constants fron
    # the ORD (else ORD export will eventually write 'UNSEPCIFIED').
    #
    # We define this backend as some of it is retrieved from ORD constants which are unavailable in RPE UI.

    def all_ord_equipment
       @all_ord_equipment ||= OrdKit::Equipment::EquipmentType.constants.map do |equipment|
        { value: equipment.to_s, label: equipment.to_s.titlecase }
      end
    end

    def action_type_equipment
      @action_type_equipment ||= {
        ADD: all_ord_equipment,
        SAVE: [],
        TRANSFER: [],
        CONDITION: {
          EQUIPMENT: all_ord_equipment,
          TEMPERATURE: options_for(
            %w[HEATING_MANTLE BLOW_DRYER OIL_BATH ICE_BATH
               ALUMINIUM_BLOCK WATER_BATH SAND_BATH],
          ),
          PH: options_for(['PIPET']),
          PRESSURE: options_for(['REACTOR']),
          IRRADIATION: options_for(%w[ULTRA_SOUND_BATH UV_LAMP LED]),
          MOTION: options_for(%w[STIRRER SHAKER HEATING_SHAKER TUBE BALL_MILLING]),
        },
        REMOVE: options_for(%w[PUMP TUBE COIL]),
        PURIFY: options_for(%w[FILTER SEPARATION_FILTER EXTRACTOR
                               SPE_COLUMN FSPE_COLUMN FLASH_COLUMN DISTILLATION_APPARATUS SEPARATION_FUNNEL BUCHNER_FUNNEL]),
        }.deep_stringify_keys
    end

    def global_default_conditions
      # Hardcoded Default conditions are stored backend as we enable user- and reaction specific
      # conditions.
      @global_default_conditions ||= {
        TEMPERATURE: { value: '21', unit: 'CELSIUS', additional_information: '' },
        PRESSURE: { value: '1013', unit: 'MBAR' },
        PH: { value: 7, unit: 'PH', additional_information: '' },
        IRRADIATION: { value: nil, unit: nil, additional_information: '' },
        MOTION: { mode: nil, value: nil, unit: nil },
        EQUIPMENT: { value: nil },
      }.deep_stringify_keys

       {
        TEMPERATURE: { value: nil, unit: 'CELSIUS', additional_information: '' },
        PRESSURE: { value: nil, unit: nil },
        PH: { value: 7, unit: 'PH', additional_information: '' },
        IRRADIATION: { value: nil, unit: nil, additional_information: '' },
        MOTION: { mode: nil, value: nil, unit: nil },
        EQUIPMENT: { value: nil },
      }.deep_stringify_keys
    end

    private

    def options_for(string_array)
      string_array.map do |string|
        { value: string, label: string.titlecase }
      end
    end
  end
end
