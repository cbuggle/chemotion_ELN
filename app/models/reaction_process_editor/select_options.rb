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
      @all_ord_equipment ||= options_for(OrdKit::Equipment::EquipmentType.constants)
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

    private

    def options_for(string_array)
      string_array.map do |string|
        { value: string.to_s, label: string.to_s.titlecase }
      end
    end
  end
end
