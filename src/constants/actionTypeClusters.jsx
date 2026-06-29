export const actionTypeClusters = [[
  {
    id: 'add',
    label: 'Dosing',
    actions: [
      {
        id: 'add_material',
        createLabel: 'Add',
        activity: {
          activity_name: "ADD"
        }
      },
      {
        id: 'add_transfer',
        createLabel: 'Transfer',
        activity: {
          activity_name: 'TRANSFER',
        }
      },
    ]
  },

  {
    id: 'remove_exchange',
    label: 'Exchange / Remove',
    actions: [
      {
        id: 'remove_exchange_sample',
        createLabel: 'Evaporate',
        activity: {
          activity_name: 'EVAPORATION',
        }
      },
      {
        id: 'remove_exchange_sample',
        createLabel: 'Gas Exchange',
        activity: {
          activity_name: 'GAS_EXCHANGE',
        }
      },
    ]
  },
  {
    id: 'combine',
    label: 'Combine',
    actions: [
      {
        id: 'mixing',
        createLabel: 'Mixing',
        activity: { activity_name: 'MIXING' }
      },
      {
        id: 'merge_samples',
        createLabel: 'Merge Samples',
        activity: { activity_name: 'MERGE_SAMPLES' }
      }
    ]
  },
  {
    id: 'time',
    label: 'Time',
    actions: [
      {
        id: 'time_wait',
        createLabel: 'Wait',
        activity: { activity_name: 'WAIT' }
      }
    ]
  },
  {
    id: 'intermediate',
    label: 'Save Sample',
    actions: [
      {
        id: 'intermediate_save',
        createLabel: 'Intermediate',
        activity: {
          activity_name: 'SAVE',
          workup: {
            intermediate_type: 'CRUDE',
            target_amount: { unit: 'ml' },
            purity: { value: 1, unit: 'PURITY' }
          }
        }
      }
    ]
  },
],
[
  // column 2
  {
    id: 'analysis',
    label: 'Analysis',
    actions: [
      {
        id: 'analysis_chromatography',
        createLabel: 'Chromatography',
        activity: {
          activity_name: 'ANALYSIS_CHROMATOGRAPHY',
          workup: {
            automation_control: { status: 'HALT' }
          },
        }
      },
      {
        id: 'analysis_spectroscopy',
        createLabel: 'Spectroscopy',
        activity: {
          activity_name: 'ANALYSIS_SPECTROSCOPY',
        }
      },
      {
        id: 'analysis_elemental',
        createLabel: 'Elemental Analysis',
        activity: {
          activity_name: 'ANALYSIS_ELEMENTAL',
        }
      },
    ]
  },

  {
    id: 'purification',
    label: 'Separate / Purify',
    actions: [
      {
        id: 'filtration',
        createLabel: 'Filtration',
        activity: {
          activity_name: 'FILTRATION',
          workup: {
            filtration_mode: 'KEEP_PRECIPITATE'
          }
        }
      },
      {
        id: 'extraction',
        createLabel: 'Extraction',
        activity: {
          activity_name: 'EXTRACTION',
          workup: {
            phase: 'ORGANIC'
          }
        }
      },
      {
        id: 'chromatography',
        createLabel: 'Chromatography',
        activity: {
          activity_name: 'CHROMATOGRAPHY',
          workup: {
            automation_control: { status: 'HALT' }
          },
        }
      },
      {
        id: 'crystallization',
        createLabel: 'Crystallization',
        activity: {
          activity_name: 'CRYSTALLIZATION',
        }
      },
      {
        id: 'centrifugation',
        createLabel: 'Centrifugation',
        activity: {
          activity_name: 'CENTRIFUGATION',
        }
      },
    ]
  },

]]
